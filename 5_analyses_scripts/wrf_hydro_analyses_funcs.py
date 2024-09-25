import xarray as xr
import numpy as np
import pandas as pd
import os
import sys
import glob
import xesmf as xe
from pyproj import Proj
import cartopy.crs as ccrs
from pyproj import Proj
import cartopy.feature as cfeature
import geopandas as gpd
import xesmf as xe
from matplotlib.lines import Line2D
import matplotlib.pyplot as plt
from matplotlib.patches import Patch
from scipy.stats import pearsonr
from datetime import datetime

#############################################
# soil moisture conversions
# copied from calc_seasonalmean_savenc.py
#############################################

# function to calculate total sm (in mm) from the layerwise soil moisture
def calc_tot_sm_inmm(da_vol_sm, soil_depth_mm = [100, 300, 600, 1000]):
    da_tot_sm = da_vol_sm.isel(soil_layers_stag=0)*soil_depth_mm[0] + \
    da_vol_sm.isel(soil_layers_stag=1)*soil_depth_mm[1] + \
    da_vol_sm.isel(soil_layers_stag=2)*soil_depth_mm[2] + \
    da_vol_sm.isel(soil_layers_stag=3)*soil_depth_mm[3]
    attrs_dict = da_vol_sm.attrs
    attrs_dict.update({'long_name': 'total depth of soil water'})
    attrs_dict.update({'units': 'mm'})
    da_tot_sm = da_tot_sm.assign_attrs(attrs_dict)
    return(da_tot_sm)

def two_layer_sm_inmm(da_vol_sm, soil_depth_mm = [100, 300]):
    da_tot_sm = da_vol_sm.isel(soil_layers_stag=0)*soil_depth_mm[0] + \
    da_vol_sm.isel(soil_layers_stag=1)*soil_depth_mm[1]
    attrs_dict = da_vol_sm.attrs
    attrs_dict.update({'long_name': 'depth of soil water in the top 2 layers'})
    attrs_dict.update({'units': 'mm'})
    da_tot_sm = da_tot_sm.assign_attrs(attrs_dict)
    return(da_tot_sm)

def calc_sm_inmm_bylayer(da_vol_sm, soil_depth_mm = [100, 300, 600, 1000]):
    da_sm_inmm = []
    da_sm_inmm.append(da_vol_sm.isel(soil_layers_stag=0)*soil_depth_mm[0])
    da_sm_inmm.append(da_vol_sm.isel(soil_layers_stag=1)*soil_depth_mm[1])
    da_sm_inmm.append(da_vol_sm.isel(soil_layers_stag=2)*soil_depth_mm[2])
    da_sm_inmm.append(da_vol_sm.isel(soil_layers_stag=3)*soil_depth_mm[3])
    da_sm_inmm_bylayer = xr.concat(da_sm_inmm, dim = 'soil_layers_stag')
    attrs_dict = da_vol_sm.attrs
    attrs_dict.update({'long_name': 'depth of soil water in mm'})
    attrs_dict.update({'units': 'mm'})
    da_sm_inmm_bylayer = da_sm_inmm_bylayer.assign_attrs(attrs_dict)
    return(da_sm_inmm_bylayer)

#############################################
# seasonal calcs
# copied from calc_seasonalmean_savenc.py
#############################################

def calc_seasonal_mean(path, var, time_sel, file_suffix = '_daily_mean.nc'):
    if var == 'SOIL_M_total':
        ds = xr.open_dataset(path + '/SOIL_M' + file_suffix)
        da = calc_tot_sm_inmm(ds['SOIL_M'])
    elif var == 'SOIL_M_2layer':
        ds = xr.open_dataset(path + '/SOIL_M' + file_suffix)
        da = two_layer_sm_inmm(ds['SOIL_M'])
    else:
        ds = xr.open_dataset(path + '/' + var + file_suffix)
        da = ds[var]
    da_seas_mean = da.sel(time = time_sel).groupby('time.season').mean().load()
    if var == 'SOIL_M':
        # convert the volumetric soil mositure to mm
        da_seas_mean = calc_sm_inmm_bylayer(da_seas_mean, soil_depth_mm = [100, 300, 600, 1000])
    return(da_seas_mean)

def calc_seasonal_accum(path, var, time_sel, file_suffix = '_concatTime.nc'):
    if var == 'SOIL_M_total':
        ds = xr.open_mfdataset(path + '/SOIL_M' + file_suffix[0:8] + '*')
        da = calc_tot_sm_inmm(ds['SOIL_M'])
    elif var == 'SOIL_M':
        # SOIL_M is saved in files by year due to it's size
        ds = xr.open_mfdataset(path + '/SOIL_M' + file_suffix[0:8] + '*')
        da = ds[var]
    elif var == 'SOIL_M_2layer':
        ds = xr.open_mfdataset(path + '/SOIL_M' + file_suffix[0:8] + '*')
        da = two_layer_sm_inmm(ds['SOIL_M'])
    else:
        ds = xr.open_dataset(path + '/' + var + file_suffix)
        da = ds[var]
    da_seas_gb = da.sel(time = time_sel).groupby('time.season')
    seas_list = list(da_seas_gb.groups.keys())
    da_list = []
    for seas in seas_list:
        da_seas_start = da_seas_gb[seas].isel(time = 0)
        da_seas_end = da_seas_gb[seas].isel(time = -1)
        da_seas_accum = da_seas_end - da_seas_start
        da_list.append(da_seas_accum)
    da_accum = xr.concat(da_list, dim = 'season').assign_coords({'season': seas_list})
    return(da_accum)


    
#############################################
# Read model and observed datasets
#############################################

def read_streamflow_textfile(filename, gauge_list=None, lat_gauge_list=None, lon_gauge_list=None):
    '''
    Function to read the streamflow text output. 
    The function arguments also include:
    gauge_list: a list of gauge numbers that match the "gauge" field in the frxst text file
    lat_gauge_list, lon_gauge_list: the lat-lons of the gauges identified from the fulldom hires file. 
    These are required because the lat-lons are not properly printed in the output text file
    '''
    # I identified column names from https://rdrr.io/github/mccreigh/rwrfhydro/src/R/read_modelout.R
    colnames = ["time_from_state", "time", "gauge", "lon", "lat", "q_cms", "q_cfs", "dpth_m"]
    df_frxst = pd.read_csv(filename, header = None, names=colnames, low_memory=False) #, index_col = None)

    # There is some problem with lat-lons in the streamflow output text file. Not sure if I should be bothered about this.
    # So I'm reassigning the lat-longs here.
    if gauge_list is not None:
        for gauge_no, lat, lon in zip(gauge_list, lat_gauge_list, lon_gauge_list):
            df_frxst['lon'][df_frxst['gauge']==gauge_no]=lon
            df_frxst['lat'][df_frxst['gauge']==gauge_no]=lat
    else:
        df_frxst['lon'] = np.nan
        df_frxst['lat'] = np.nan

    npTime = [np.datetime64(x) for x in df_frxst['time']]
    df_frxst['time'] = npTime
    df_frxst = df_frxst.set_index(['time', 'gauge'])
    ds_frxst = df_frxst.to_xarray()
    return ds_frxst

def read_agcd_data(agcd_files):
    '''
    Function to read AGCD data from files, and re-assign time dimension without hours
    '''
    ds_agcd = xr.open_mfdataset(agcd_files, concat_dim = 'time', combine = 'nested')
    time_new = ds_agcd['time'].dt.floor('D')
    ds_agcd = ds_agcd.assign_coords({'time':time_new})
    return ds_agcd
    
def read_model_prcp(prcp_accum_file, sel_hour=9):
    '''
    Read model forcing precipitation from accumulated file 
    Select values at a specific hour on each day and calculate daily values by differencing
    '''
    ds_mdl_prcp_acc = xr.open_dataset(prcp_accum_file)
    da_mdl_prcp_acc = ds_mdl_prcp_acc['ACCPRCP']
    da_mdl_prcp_acc = da_mdl_prcp_acc.sel(time=da_mdl_prcp_acc.time.dt.hour == sel_hour)
    da_mdl_prcp = da_mdl_prcp_acc.diff('time').rename('precip')
    
    time_new = da_mdl_prcp['time'].dt.floor('D')
    da_mdl_prcp = da_mdl_prcp.assign_coords({'time':time_new})
    return da_mdl_prcp
    
def get_agcd_prcp_forEvent(agcd_files, day_sel, time_window):
    ds_agcd = xr.open_mfdataset(agcd_files, concat_dim = 'time', combine = 'nested')
    time_new = ds_agcd['time'].dt.floor('D')
    ds_agcd = ds_agcd.assign_coords({'time':time_new})

    long_event_sel = [day_sel + np.timedelta64(int(x), 'D') for x in time_window]
    da_agcd = ds_agcd['precip'].sel(time = long_event_sel)
    return da_agcd

def get_model_prcp_forEvent(prcp_accum_file, day_sel, time_window):
    ds_mdl_prcp_acc = xr.open_dataset(prcp_accum_file)
    # need one more prior day from the model accprcp
    long_event_sel = [day_sel + np.timedelta64(int(x), 'D') for x in time_window]
    da_mdl_prcp_acc = ds_mdl_prcp_acc['ACCPRCP'].sel(time = long_event_sel)
    da_mdl_prcp = da_mdl_prcp_acc.diff('time')
    return da_mdl_prcp

def read_obs_streamflow(data_dir, stn_no, quiet=False):
    stn_file = data_dir + str(stn_no) + '_daily_ts.csv'
    df_stn = pd.read_csv(stn_file, header = 26)

    # get dates in format datetime64
    date_array = pd.date_range(df_stn['Date'][0], periods=len(df_stn), freq="D")
    df_stn['Date'] = date_array
    
    if not quiet:
        print('Station Number = ' + str(stn_no))
        print('start date = ' + str(df_stn['Date'].values[0]))
        print('end date = ' + str(df_stn['Date'].values[-1]))
        print('No.of nans in the data = ' + str(sum(np.isnan(df_stn['Flow (ML)'].values))))
        print('------------------------------------------------')

    df_stn = df_stn.set_index(['Date'])
    da_stn = df_stn.to_xarray().rename({'Flow (ML)': 'Flow'})
    return da_stn

def add_latlon_coords(da):
    X, Y = np.meshgrid(da.x.values, da.y.values)
    source = Proj(da.attrs['esri_pe_string'])
    lon, lat = source(X.flatten(), Y.flatten(), inverse=True)
    lon_2d = lon.reshape(X.shape)
    lat_2d = lat.reshape(Y.shape)

    da.coords['lat'] = (da.dims, lat_2d)
    da.coords['lon'] = (da.dims, lon_2d)
    return(da)

def calc_basin_avg(da, da_mask, gauge_list, dimName = 'station'):
    '''
    da_mask identifies the basins of the gauges. The grids in the basin are indicated by the gauge numbers.
    This function get values over the basins and averages them.
    This is not a weighted average because the grids are equal area (4km or 1km resolution)
    '''
    list_mean = []
    for i in gauge_list:
        # calc maked data
        da_mask_temp = np.where(da_mask == i, 1, np.nan)
        da_masked = da*da_mask_temp
        # avg over spatial dimensions
        dim_exclTime = list(set(da_masked.dims) - set(['time']))
        da_masked_mean = da_masked.mean(dim_exclTime)
        list_mean.append(da_masked_mean)
    da_avg = xr.concat(list_mean, dim = dimName).assign_coords({dimName: gauge_list})
    return da_avg

def identify_nearest_model_grid(site_lat_list, site_lon_list, model_lat2d, model_lon2d):
    '''
    site_lat_list, site_lon_list: lists containing the lat-lons of the observed locations to locate on the model grid
    model_lat2d, model_lon2d: 2d lat-lons of the model grid
    '''
    mdl_lat_list = []
    mdl_lon_list = []
    mdl_latInd_list = []
    mdl_lonInd_list = []
    for site_lat, site_lon in zip(site_lat_list, site_lon_list):
        abslat = np.abs(model_lat2d-site_lat)
        abslon = np.abs(model_lon2d-site_lon)
        c = np.maximum(abslon, abslat)
        lonInd, latInd = np.where(c == np.nanmin(c))
        mdl_lonInd_list.append(lonInd[0])
        mdl_latInd_list.append(latInd[0])
        
        mdllat = model_lat2d[lonInd[0], latInd[0]]
        mdllon = model_lon2d[lonInd[0], latInd[0]] 
        mdl_lat_list.append(mdllat)
        mdl_lon_list.append(mdllon)
    mdl_indices = {'lat': mdl_latInd_list, 'lon': mdl_lonInd_list}
    mdl_coords = {'lat': mdl_lat_list, 'lon': mdl_lon_list}
    return mdl_indices, mdl_coords

def read_modelData_atGrid(model_file, varname, model_lonInd_list, model_latInd_list, sm_lvl_isel_list=None, multiple_files=False):
    '''
    Returns a list containing data arrays of model output (as da) for each of the selected indices (lat-lon locations)
    '''
    if multiple_files:
        ds_mdl = xr.open_mfdataset(model_file)
    else:
        ds_mdl = xr.open_dataset(model_file)
    list_da_model = []
    if sm_lvl_isel_list is not None:
        for lonInd, latInd, sm_lvl_isel in zip(model_lonInd_list, model_latInd_list, sm_lvl_isel_list):
            list_da_model.append(ds_mdl[varname].isel(soil_layers_stag=sm_lvl_isel)[:,lonInd, latInd])
    else:
        for lonInd, latInd in zip(model_lonInd_list, model_latInd_list):
            list_da_model.append(ds_mdl[varname][:,lonInd, latInd])
    return(list_da_model)

#########################################################
# specific functions used for calibration event calcs
#########################################################

def exclude_eventDays(da, event_day, time_window):
    '''
    Function to exclude an event.
    Typically used to identify the next highest or lowest event from a data array
    event_day + time_window is the period to be exluded
    '''
    all_event_days = [event_day + np.timedelta64(x, 'D') for x in time_window]
    da_excluded = da.where(~np.isin(da.time, all_event_days), np.nan)
    return da_excluded

def exclude_eventDays_byStn(da_flow, da_eventDay_byStn, time_window):
    '''
    Function to apply exclude_eventDays by station
    '''
    station_list = da_flow.station.values
    stn_list = []
    for stn in station_list:
        da_stn = exclude_eventDays(da_flow.sel(station = stn), da_eventDay_byStn.sel(station = stn).values, time_window = time_window)
        stn_list.append(da_stn)
    da_flow_exclude = xr.concat(stn_list, dim = 'station').assign_coords({'station': station_list})
    return da_flow_exclude

def print_eventDay_info(list_event_days):
    '''
    The input list contains events identified at multiple stations. 
    This a utility function to print the information to identify events that ocuured at most stations
    '''
    print('EVENTS DAYS FROM LARGEST TO SMALLEST')
    station_list = list_event_days[0].station.values
    for da in list_event_days:
        print('stations:' +  str(station_list))
        print(da.values)
    print('-----------------------------------------------------------------')
    
    print('SORTED LIST OF EVENT DAYS AT EACH STATION')
    # concat max days into a dataarray
    da_event_days = xr.concat(list_event_days, dim = 'events')
    for istn in range(len(da_event_days.station.values)):
        print('station:' + str(da_event_days.station.values[istn]))
        #print(da_event_days.isel(station = istn).values)
        print(np.sort(da_event_days.isel(station = istn).values))
    print('-----------------------------------------------------------------')
    
    print('SORTED LIST OF ALL EVENT DAYS, ALL STATIONS')
    print(np.sort(da_event_days.values.flatten()))
    print('-----------------------------------------------------------------')
    return None

######################################################
# PLOTTING FUNCTIONS
######################################################

def apply_axis_legend_settings(ax, da, legend_loc = 2, draw_legend = True):
    if draw_legend:
        ax.legend(loc = legend_loc)
    ax.set_xlim((da.time[0], da.time[-1]))
    ax.set_xlabel('')
    ax.set_ylabel(da.name)

def plot_ctl_and_lat_timeseries(ax, da_ctl, da_lat, run_name, linewidth = 2, linestyle = '-', colors = ['black', 'green'],
                                mark_years = True, year_breaks = pd.date_range('2013-12-31', freq='Y', periods=4)):
    ax.plot(da_ctl.time.values, da_ctl.values, linewidth = linewidth, linestyle = linestyle, color = colors[0], label = 'CTL-' + run_name)
    ax.plot(da_lat.time.values, da_lat.values, linewidth = linewidth, linestyle = linestyle, color = colors[1], label = 'LAT-' + run_name)
    if mark_years:
        for xline in year_breaks:
            ax.axvline(xline, color = 'grey', linestyle = '--', linewidth = 0.5)

def calc_NSE(sim, obs):
    '''
    sim & obs are 1-D numpy arrays
    '''
    denominator = np.nansum((obs - np.nanmean(obs))**2)
    if denominator == 0:
        return(np.nan)
    else:
        numerator = np.nansum((obs - sim)**2)
        NSE = 1 - (numerator/denominator)
        return(NSE)
    
def plot_streamflow_events(da_obs, da_model, event_day, event_window, total_time_window, nrows, ncols, colors = ['black', 'royalblue'],
                          unit = 'GL', out_dir=None, out_figname=None, main_title=None, fig_format='pdf', ylim = None, varname = 'Streamflow', addLegend=True, fig_dpi=300, onlyEndXTicks=False):
    
    station_list = da_obs.station.values
    if len(station_list) < (ncols*nrows):
        unwanted_axes = list(range(len(station_list), ncols*nrows))
    else:
        unwanted_axes = None
    
    long_event_sel = [event_day + np.timedelta64(int(x), 'D') for x in total_time_window]
    event_start = event_day + np.timedelta64(int((-1*event_window) +1), 'D')
    event_end = event_day
    #print(long_event_sel)
    #print(long_event_sel[0:len(long_event_sel):4])
    
    da_obs_event = da_obs.sel(time = slice(long_event_sel[0], long_event_sel[-1])) #long_event_sel)
    da_mdl_event = da_model.sel(time = slice(long_event_sel[0], long_event_sel[-1])) #long_event_sel)
    
    fig, ax = plt.subplots(nrows=nrows,ncols=ncols,figsize=(15*ncols,4*nrows), sharex='col') #width, height
    fig.subplots_adjust(wspace=0.14, hspace=0.07)    
    ax = ax.flatten()
    
    if unwanted_axes is not None:
        for i in unwanted_axes:
            fig.delaxes(axs[i])
    
    for label, istn in zip(station_list, range(len(station_list))):    
        xval = da_obs_event.isel(station = istn).time.values
        ax[istn].plot(xval, da_obs_event.isel(station = istn).values, color=colors[0], linewidth=1, zorder=10, label = label, linestyle='solid', marker='o')
        ax[istn].plot(xval, da_mdl_event.isel(station = istn).values, color=colors[1], linewidth=1, zorder=10, linestyle='solid', marker='o')
        
        # for xline in [event_start, event_end]:
        #     ax[istn].axvline(xline, color = 'grey', linestyle = '--', linewidth = 0.5)
        ax[istn].axhline(0, color = 'black', linestyle = 'solid', linewidth = 0.5)
        
        legend_elements = [Line2D([0], [0], linewidth=1, linestyle='solid', color=colors[1], marker ='o', label='Model'),
                           Line2D([0], [0], linewidth=1, linestyle='solid', color=colors[0], marker='o', label='Observed,   at ' + str(station_list[istn]))]
        if addLegend:
            ax[istn].legend(handles=legend_elements, bbox_to_anchor=(0.1, 1), ncol=2, loc=2)
        
        # adding text about flow biases
        obs_val = da_obs_event.isel(station = istn).mean().values
        obs_val_arr = da_obs_event.isel(station = istn).values
        mdl_val = da_mdl_event.isel(station = istn).mean().values
        mdl_val_arr = da_mdl_event.isel(station = istn).values
        NSE = calc_NSE(mdl_val_arr, obs_val_arr)
        
        fontweight = 'normal'
        ax[istn].text(0.55, 0.8, varname, 
                           ha='left', va='center', transform=ax[istn].transAxes, fontweight='semibold', fontsize=14, color = 'black')
        ax[istn].text(0.55, 0.7, 'Obs =' + str(np.round(obs_val, 1)) + ' ' + unit, 
                           ha='left', va='center', transform=ax[istn].transAxes, fontweight=fontweight, fontsize=14, color = 'black')
        ax[istn].text(0.55, 0.6, 'Model =' + str(np.round(mdl_val, 1)) + ' ' + unit, 
                           ha='left', va='center', transform=ax[istn].transAxes, fontweight=fontweight, fontsize=14, color = 'black')
        if obs_val > 0:
            diff_perc = (mdl_val - obs_val)/obs_val*100
            if diff_perc > 5:
                diff_color = 'blue'
            elif diff_perc < -5:
                diff_color = 'red'
            else:
                diff_color = 'black'
            ax[istn].text(0.55, 0.5, 'Diff =' + str(int(diff_perc)) + '%', 
                               ha='left', va='center', transform=ax[istn].transAxes, fontweight=fontweight, fontsize=14, color = diff_color)
            
        if NSE>0:
            nse_col = 'forestgreen'
        else:
            nse_col = 'sienna'
        ax[istn].text(0.55, 0.4, 'NSE =' + str(round(NSE,2)), 
                               ha='left', va='center', transform=ax[istn].transAxes, fontweight=fontweight, fontsize=14, color = nse_col)
        
        if onlyEndXTicks:
            x_ticks = [long_event_sel[0], long_event_sel[-1]]
            ax[istn].set_xticks(x_ticks)
            ax[istn].set_xticklabels([str(x) for x in x_ticks])
        else:
            x_ticks = long_event_sel[0:len(long_event_sel):4]
            ax[istn].set_xticks(x_ticks)
            ax[istn].set_xticklabels([str(x) for x in x_ticks])
        ax[istn].set_ylabel(varname + ' (' + unit + ')')
        
        if ylim is not None:
            ax[istn].set_ylim(ylim)
        else:
            ydata = np.append(da_obs_event.isel(station = istn).values, da_mdl_event.isel(station = istn).values)
            ax[istn].set_ylim((0, 1.25*np.max(ydata)))
        
    if main_title is not None:
        plt.suptitle(main_title)    
    if out_dir is not None:
        if out_figname is not None:
            plt.savefig(out_dir + out_figname + '.' + fig_format, format = fig_format, dpi = fig_dpi, bbox_inches='tight')
        else:
            plt.savefig(out_dir + 'figure.' + fig_format, format = fig_format, dpi = fig_dpi)
    return fig, ax

def plot_streamflow(da_obs, da_model, nrows, ncols, xval = None, colors = ['black', 'royalblue'],
                    unit = 'GL', out_dir=None, out_figname=None, main_title=None, fig_format='pdf', ylim = None, varname = 'Streamflow', addLegend=True, fig_dpi=300):
    
    station_list = da_obs.station.values
    if len(station_list) < (ncols*nrows):
        unwanted_axes = list(range(len(station_list), ncols*nrows))
    else:
        unwanted_axes = None
        
    fig, ax = plt.subplots(nrows=nrows,ncols=ncols,figsize=(15*ncols,4*nrows), sharex='col') #width, height
    fig.subplots_adjust(wspace=0.14, hspace=0.07)    
    ax = ax.flatten()
    
    if unwanted_axes is not None:
        for i in unwanted_axes:
            fig.delaxes(axs[i])
    
    for label, istn in zip(station_list, range(len(station_list))):    
        if xval is None:
            xval = da_obs.isel(station = istn).time.values
        ax[istn].plot(xval, da_obs.isel(station = istn).values, color=colors[0], linewidth=1, zorder=10, label = label, linestyle='solid', marker='o')
        ax[istn].plot(xval, da_model.isel(station = istn).values, color=colors[1], linewidth=1, zorder=10, linestyle='solid', marker='o')
        ax[istn].axhline(0, color = 'black', linestyle = 'solid', linewidth = 0.5)
        
        legend_elements = [Line2D([0], [0], linewidth=1, linestyle='solid', color=colors[1], marker ='o', label='Model'),
                           Line2D([0], [0], linewidth=1, linestyle='solid', color=colors[0], marker='o', label='Observed,   at ' + str(station_list[istn]))]
        if addLegend:
            ax[istn].legend(handles=legend_elements, bbox_to_anchor=(0.1, 1), ncol=2, loc=2)
        
        # adding text about flow biases
        obs_val = da_obs.isel(station = istn).mean().values
        obs_val_arr = da_obs.isel(station = istn).values
        mdl_val = da_model.isel(station = istn).mean().values
        mdl_val_arr = da_model.isel(station = istn).values
        NSE = calc_NSE(mdl_val_arr, obs_val_arr)
        
        fontweight = 'normal'
        ax[istn].text(0.55, 0.8, varname, 
                           ha='left', va='center', transform=ax[istn].transAxes, fontweight='semibold', fontsize=14, color = 'black')
        ax[istn].text(0.55, 0.7, 'Obs =' + str(np.round(obs_val, 1)) + ' ' + unit, 
                           ha='left', va='center', transform=ax[istn].transAxes, fontweight=fontweight, fontsize=14, color = 'black')
        ax[istn].text(0.55, 0.6, 'Model =' + str(np.round(mdl_val, 1)) + ' ' + unit, 
                           ha='left', va='center', transform=ax[istn].transAxes, fontweight=fontweight, fontsize=14, color = 'black')
        if obs_val > 0:
            diff_perc = (mdl_val - obs_val)/obs_val*100
            if diff_perc > 5:
                diff_color = 'blue'
            elif diff_perc < -5:
                diff_color = 'red'
            else:
                diff_color = 'black'
            ax[istn].text(0.55, 0.5, 'Diff =' + str(int(diff_perc)) + '%', 
                               ha='left', va='center', transform=ax[istn].transAxes, fontweight=fontweight, fontsize=14, color = diff_color)
            
        if NSE>0:
            nse_col = 'forestgreen'
        else:
            nse_col = 'sienna'
        ax[istn].text(0.55, 0.4, 'NSE =' + str(round(NSE,2)), 
                               ha='left', va='center', transform=ax[istn].transAxes, fontweight=fontweight, fontsize=14, color = nse_col)
        
        ax[istn].set_ylabel(varname + ' (' + unit + ')')
        
        if ylim is not None:
            ax[istn].set_ylim(ylim)
        else:
            ydata = np.append(da_obs.isel(station = istn).values, da_model.isel(station = istn).values)
            ax[istn].set_ylim((0, 1.25*np.max(ydata)))
        
    if main_title is not None:
        plt.suptitle(main_title)    
    if out_dir is not None:
        if out_figname is not None:
            plt.savefig(out_dir + out_figname + '.' + fig_format, format = fig_format, dpi = fig_dpi, bbox_inches='tight')
        else:
            plt.savefig(out_dir + 'figure.' + fig_format, format = fig_format, dpi = fig_dpi)
    return fig, ax


def plot_timeseries_multipleSims_wObs(da_obs, da_model_list, nrows, ncols, model_names, model_colors, add_mdl_ax = True, time_sel = None, model_linewidth = None, model_linetype = None, obs_color = 'black', obs_linewidth=3,
                          unit = 'GL', out_dir=None, out_figname=None, main_title=None, fig_format='pdf', ylim_list = None, ylim_multiplier=None, varname = 'Streamflow', addLegend=True, legend_ncol=2, shadeRange=True, shade_color = 'grey', shade_alpha = 0.3, 
                                      print_bias = True, mean_and_perc_bias=False, print_NSE = True, print_corr=False, print_mdlMean=False, write_timeMean_err=False, fig_dpi=300): #, onlyEndXTicks=False):
    
    station_list = da_obs.station.values
    if len(station_list) < (ncols*nrows):
        unwanted_axes = list(range(len(station_list), ncols*nrows))
    else:
        unwanted_axes = None

    if time_sel is not None:                          
        da_obs = da_obs.sel(time = time_sel)
        da_model_list = [da_model.sel(time = time_sel) for da_model in da_model_list]
    
    fig, ax = plt.subplots(nrows=nrows,ncols=ncols,figsize=(15*ncols,4*nrows), sharex='col') #width, height
    fig.subplots_adjust(wspace=0.14, hspace=0.07)    
    ax = ax.flatten()
    
    if unwanted_axes is not None:
        for i in unwanted_axes:
            fig.delaxes(ax[i])
    if model_linetype is None:
        model_linetype = ['solid']*len(model_colors)
    if model_linewidth is None:
        model_linewidth = [1]*len(model_colors)
    
    for label, istn in zip(station_list, range(len(station_list))):    
        xval = da_obs.isel(station = istn).time.values
        ax[istn].plot(xval, da_obs.isel(station = istn).values, color=obs_color, linewidth=obs_linewidth, zorder=10, linestyle='solid', marker='o')
        if add_mdl_ax:
            ax_mdl = ax[istn].twinx()
        else:
            ax_mdl = ax[istn]
        for da_mdl, mdl_col, mdl_lty, mdl_lwd, mdl_label, iMdl in zip(da_model_list, model_colors, model_linetype, model_linewidth, model_names, range(len(da_model_list))): 
            # print(iMdl)
            # print(mdl_label)
            ax_mdl.plot(da_mdl.isel(station = istn).time.values, da_mdl.isel(station = istn).values, color=mdl_col, zorder=10, linestyle=mdl_lty, linewidth=mdl_lwd, marker='o', label=mdl_label)

            # metrics of the model run
            #obs_val = da_obs.isel(station = istn).mean().values
            obs_val_arr = da_obs.isel(station = istn).values
            #mdl_val = da_mdl.isel(station = istn).mean().values
            mdl_val_arr = da_mdl.isel(station = istn).values

            selIndex = ~(np.isnan(obs_val_arr) | np.isnan(mdl_val_arr))
            if len(selIndex)>0:
                obs_val_arr = obs_val_arr[selIndex]
                obs_val = np.mean(obs_val_arr)
                mdl_val_arr = mdl_val_arr[selIndex]
                mdl_val = np.mean(mdl_val_arr)
                NSE = calc_NSE(mdl_val_arr, obs_val_arr)
                diff_perc = (mdl_val - obs_val)/obs_val*100
            else:
                obs_val_arr = [np.nan]
                obs_val = np.nan
                mdl_val_arr = [np.nan]
                mdl_val= np.nan
                NSE = np.nan
                diff_perc = np.nan

            if write_timeMean_err is True:
                err_arr = [(mdl - obs)/obs*100 for mdl, obs in zip(mdl_val_arr, obs_val_arr)]
                diff_perc = np.mean(err_arr)

            if print_corr:
                corr = round(pearsonr(obs_val_arr, mdl_val_arr)[0], 2)
                corr_pval = round(pearsonr(obs_val_arr, mdl_val_arr)[1], 2)
                metrics_text = 'Correlation =' + str(corr) + '(p=' + str(corr_pval) + ')'
            else:
                if (print_bias) | (print_NSE) | (print_mdlMean):
                    if print_bias:
                        if mean_and_perc_bias:
                            metrics_text = 'Bias =' + str(round(mdl_val - obs_val, 1)) + '(' + str(int(diff_perc)) + '%)'
                        else:
                            metrics_text = 'Bias =' + str(int(diff_perc)) + '%'
                        if print_NSE:
                            metrics_text = metrics_text + ', NSE =' + str(round(NSE,2))
                    elif print_NSE:
                        metrics_text = 'NSE =' + str(round(NSE,2))
                    elif print_mdlMean:
                        # calculating the model mean independent of the availability of corresponding observations
                        mdl_val_arr = da_mdl.isel(station = istn).values
                        mdl_val_arr = mdl_val_arr[~np.isnan(mdl_val_arr)]
                        mdl_val = np.mean(mdl_val_arr)
                        metrics_text = 'Mean = ' + str(round(mdl_val,2))
            if (print_bias) | (print_NSE) | (print_corr) | (print_mdlMean):
                if iMdl<2:
                    ax[istn].text(0.3, 0.8 - 0.1*iMdl, metrics_text, 
                               ha='left', va='center', transform=ax[istn].transAxes, fontweight='bold', fontsize=16, color = mdl_col, zorder=15)
                else:
                    ax[istn].text(0.65, 0.8 - 0.1*(iMdl-2), metrics_text, 
                               ha='left', va='center', transform=ax[istn].transAxes, fontweight='bold', fontsize=16, color = mdl_col, zorder=15)
            
            # ax[istn].text(0.55, 0.7, 'NSE =' + str(round(NSE,2)), 
            #                ha='left', va='center', transform=ax[istn].transAxes, fontweight='normal', fontsize=14, color = 'black')
        
        ax[istn].axhline(0, color = 'black', linestyle = 'solid', linewidth = 0.5)

        # adding text about flow biases
        obs_val = da_obs.isel(station = istn).mean().values
        #mdl_val = da_mdl.isel(station = istn).mean().values
        # fontweight = 'normal'
        # ax[istn].text(0.75, 0.8, varname, 
        #                    ha='left', va='center', transform=ax[istn].transAxes, fontweight='semibold', fontsize=14, color = 'black')
        # ax[istn].text(0.75, 0.7, 'Obs =' + str(np.round(obs_val, 1)) + ' ' + unit, 
        #                    ha='left', va='center', transform=ax[istn].transAxes, fontweight=fontweight, fontsize=14, color = 'black')
        
        #legend_elements = [Line2D([0], [0], linewidth=1, linestyle='solid', color=model_colors[0], marker ='o', label='Model'),
        legend_elements = [Line2D([0], [0], linewidth=obs_linewidth, linestyle='solid', color=obs_color, marker='o', 
                                  label='Observed,   at ' + str(station_list[istn]) + ', ' + str(np.round(obs_val, 2)) + ' ' + unit)]
        if addLegend:
            legend1 = ax[istn].legend(handles=legend_elements, bbox_to_anchor=(0.5, 1), ncol=legend_ncol, loc=2, frameon=False)
            ax[istn].add_artist(legend1)
        
        if istn == len(station_list)-1:
            if addLegend:
                if add_mdl_ax:
                    # ax_mdl.legend(bbox_to_anchor=(-0.3, -0.1, 0, 0), ncol=2, loc=2, frameon=False)
                    ax_mdl.legend(bbox_to_anchor=(0.05, -0.1, 0, 0), ncol=legend_ncol, loc=2, frameon=False)
                else:                    
                    #ax[istn].legend(bbox_to_anchor=(0.05, 0.85), ncol=2, loc=2, frameon=False)
                    #ax[istn].legend(bbox_to_anchor=(-0.3, -0.1, 0, 0), ncol=2, loc=2, frameon=False)
                    ax[istn].legend(bbox_to_anchor=(0.05, -0.1, 0, 0), ncol=legend_ncol, loc=2, frameon=False)
                    #fig.legend(loc='center', bbox_to_anchor=(0.5, -0.2), ncol=2, frameon=False)

        if shadeRange:
            if len(da_model_list)>1:
                # get the min-max of the flow values to shade between
                da_mdl_concat = xr.concat([da_mdl.isel(station = istn) for da_mdl in da_model_list], dim='runs')
                da_mdl_min = da_mdl_concat.min('runs')
                da_mdl_max = da_mdl_concat.max('runs')
                ax_mdl.fill_between(da_mdl.isel(station = istn).time.values, da_mdl_min.values, da_mdl_max.values, color=shade_color, alpha=shade_alpha, zorder=9) 
                #, where=None, interpolate=False, step=None, *, data=None, **kwargs)
        
        # if onlyEndXTicks:
        #     x_ticks = [da_obs.time.values[0], da_obs.time.values[-1]]
        #     ax[istn].set_xticks(x_ticks)
        #     # print(x_ticks)
        #     ax[istn].set_xticklabels([np.datetime_as_string(x, unit='D') for x in x_ticks])
        # else:
        #     x_ticks = da_obs_event.time.values[0:len(long_event_sel):4]
        #     ax[istn].set_xticks(x_ticks)
        #     ax[istn].set_xticklabels([np.datetime_as_string(x, unit='D') for x in x_ticks])
        # ax[istn].set_ylabel(varname + ' (' + unit + ')')
        
        ax[istn].set_ylabel(varname + ' (' + unit + ')')
        
        if ylim_list is not None:
            ax[istn].set_ylim(ylim_list[istn])
        else:
            if add_mdl_ax:
                ydata1 = da_obs.isel(station = istn).values
                ydata2 = da_model_list[0].isel(station = istn).values
                if ylim_multiplier is not None:
                    ax[istn].set_ylim((ylim_multiplier[0]*np.nanmin(ydata1), ylim_multiplier[1]*np.nanmax(ydata1)))
                    ax_mdl.set_ylim((ylim_multiplier[0]*np.nanmin(ydata2), ylim_multiplier[1]*np.nanmax(ydata2)))
                else:
                    if np.nanmin(ydata1) >0:
                        ax[istn].set_ylim((0, 1.6*np.nanmax(ydata1)))
                        ax_mdl.set_ylim((0, 1.6*np.nanmax(ydata2)))
                    else:
                        ax[istn].set_ylim((1.25*np.nanmin(ydata1), 1.6*np.nanmax(ydata1)))
                        ax_mdl.set_ylim((1.25*np.nanmin(ydata2), 1.6*np.nanmax(ydata2)))
            else:
                ydata_mdl = [x.isel(station = istn).values for x in da_model_list]
                ydata = da_obs.isel(station = istn).values
                for i in range(len(ydata_mdl)):
                    ydata = np.append(ydata, ydata_mdl[i])
                #ydata = np.append(da_obs.isel(station = istn).values, da_model_list[0].isel(station = istn).values)
                if ylim_multiplier is not None:
                    ax[istn].set_ylim((ylim_multiplier[0]*np.nanmin(ydata), ylim_multiplier[1]*np.nanmax(ydata)))
                else:
                    if np.nanmin(ydata) >0:
                        ax[istn].set_ylim((0, 1.6*np.nanmax(ydata)))
                    else:
                        ax[istn].set_ylim((1.25*np.nanmin(ydata), 1.6*np.nanmax(ydata)))
        
    if main_title is not None:
        plt.suptitle(main_title)    
    if out_dir is not None:
        if out_figname is not None:
            plt.savefig(out_dir + out_figname + '.' + fig_format, format = fig_format, dpi = fig_dpi, bbox_inches='tight')
        else:
            plt.savefig(out_dir + 'figure.' + fig_format, format = fig_format, dpi = fig_dpi)
    return fig, ax

def calc_mdlObsCompare_stats(da_obs, da_model_list, model_names, unit='GL/month'):
    station_list = da_obs.station.values

    out_columns = ['Station', 'Model_Run_Name', 'Obs(' + unit + ')', 'Model(' + unit + ')', 'Model_Bias(' + unit + ')', 'Model_Bias(%)', 'NSE', 'Pearson_Corr', 'Corr_Pval'] 
    out_arr_stn = []
    out_arr_mdl_name = []
    out_arr_obs_val = []
    out_arr_mdl_val = []
    out_arr_bias = []
    out_arr_bias_perc = []
    out_arr_nse = []
    out_arr_corr = []
    out_arr_pval = []
    
    for istn in range(len(station_list)):
        for da_mdl, iMdl in zip(da_model_list, range(len(da_model_list))):
            # metrics of the model run
            obs_val_arr = da_obs.isel(station = istn).values
            mdl_val_arr = da_mdl.isel(station = istn).values
    
            # compare only values where both obs and mdl numbers are non-nan
            selIndex = ~(np.isnan(obs_val_arr) | np.isnan(mdl_val_arr))
            obs_val_arr = obs_val_arr[selIndex]
            obs_val = np.mean(obs_val_arr)
            mdl_val_arr = mdl_val_arr[selIndex]
            mdl_val = np.mean(mdl_val_arr)
    
            NSE = calc_NSE(mdl_val_arr, obs_val_arr)
            diff_perc = (mdl_val - obs_val)/obs_val*100
            diff = mdl_val - obs_val
            
            corr = round(pearsonr(obs_val_arr, mdl_val_arr)[0], 4)
            corr_pval = round(pearsonr(obs_val_arr, mdl_val_arr)[1], 4)
            
            # outputs for csv
            out_arr_stn.append(station_list[istn])
            out_arr_mdl_name.append(model_names[iMdl])
            out_arr_obs_val.append(round(obs_val, 4))
            out_arr_mdl_val.append(round(mdl_val, 4))
            out_arr_bias.append(round(diff, 5))
            out_arr_bias_perc.append(round(diff_perc, 5))
            out_arr_nse.append(round(NSE, 4))
            out_arr_corr.append(round(corr, 4))
            out_arr_pval.append(round(corr_pval, 4))
        
    df_out = pd.DataFrame(dict(zip(out_columns, [out_arr_stn, out_arr_mdl_name, out_arr_obs_val, out_arr_mdl_val, out_arr_bias, out_arr_bias_perc, out_arr_nse, out_arr_corr, out_arr_pval])))
    return df_out

# A function to add precipitation bars to the streamflow plot
def plot_prcp_daily_bars(fig, ax, da_prcp_obs, da_prcp_mdl, event_day, event_window, total_time_window, colors = ['black', 'royalblue'], alpha = 0.3,
                          unit = 'mm', out_dir=None, out_figname=None, fig_format='pdf', ylim = None, varname = 'Rainfall', 
                         data_names = ['AGCD', 'Model Forc.'], addLegend=True, fig_dpi=300):
    '''
    Function to add daily precip as bar plots on top of the streamflow.
    '''
    station_list = da_prcp_obs.station.values
    long_event_sel = [event_day + np.timedelta64(int(x), 'D') for x in total_time_window]
    
    da_obs_event = da_prcp_obs.sel(time = slice(long_event_sel[0], long_event_sel[-1])) #long_event_sel)
    da_mdl_event = da_prcp_mdl.sel(time = slice(long_event_sel[0], long_event_sel[-1])) #long_event_sel)
    
    for i in range(len(station_list)):
        ax_twin = ax[i].twinx()
        ax_twin.bar(x = da_obs_event.time.values, height = da_obs_event.isel(station = i).values, color = colors[0], alpha = alpha)
        ax_twin.bar(x = da_mdl_event.time.values, height = da_mdl_event.isel(station = i).values, color = colors[1], alpha = alpha)
        #ax_twin.invert_yaxis()

        # adding text about biases
        obs_val = da_obs_event.isel(station = i).mean().values
        mdl_val = da_mdl_event.isel(station = i).mean().values
        obs_val_arr = da_obs_event.isel(station = i).values
        mdl_val_arr = da_mdl_event.isel(station = i).values
        NSE = calc_NSE(mdl_val_arr, obs_val_arr)
        
        fontweight = 'normal'
        ax_twin.text(0.75, 0.8, varname, 
                           ha='left', va='center', transform=ax_twin.transAxes, fontweight='semibold', fontsize=14, color = 'black')
        ax_twin.text(0.75, 0.7, data_names[0] + ' =' + str(np.round(obs_val, 1)) + ' ' + unit, 
                           ha='left', va='center', transform=ax_twin.transAxes, fontweight=fontweight, fontsize=14, color = 'black')
        ax_twin.text(0.75, 0.6, data_names[1] + ' =' + str(np.round(mdl_val, 1)) + ' ' + unit, 
                           ha='left', va='center', transform=ax_twin.transAxes, fontweight=fontweight, fontsize=14, color = 'black')
        if obs_val > 0:
            diff_perc = (mdl_val - obs_val)/obs_val*100
            if diff_perc > 5:
                diff_color = 'blue'
            elif diff_perc < -5:
                diff_color = 'red'
            else:
                diff_color = 'black'
            ax_twin.text(0.75, 0.5, 'Diff =' + str(int(diff_perc)) + '%', 
                               ha='left', va='center', transform=ax_twin.transAxes, fontweight=fontweight, fontsize=14, color = diff_color)
        if NSE>0:
            nse_col = 'forestgreen'
        else:
            nse_col = 'sienna'
        ax_twin.text(0.75, 0.4, 'NSE =' + str(round(NSE,2)), 
                               ha='left', va='center', transform=ax_twin.transAxes, fontweight=fontweight, fontsize=14, color = nse_col)
        
        if ylim is not None:
            ax_twin.set_ylim(ylim)
        else:
            ydata = np.append(da_obs_event.isel(station = i).values, da_mdl_event.isel(station = i).values)
            ax_twin.set_ylim((0, 1.25*np.max(ydata)))
        ax_twin.set_ylabel(varname + ' (' + unit + ')')
        
        if addLegend:
            legend_elements = [Patch(facecolor=colors[0], edgecolor=None, alpha = alpha, label=data_names[0]),
                               Patch(facecolor=colors[1], edgecolor=None, alpha = alpha, label=data_names[1])]
            fig.legend(handles=legend_elements, loc='center', bbox_to_anchor=(0.5, 0.02), ncol=2, frameon=False)
        
        if out_dir is not None:
            if out_figname is not None:
                plt.savefig(out_dir + out_figname + '.' + fig_format, format = fig_format, dpi = fig_dpi, bbox_inches='tight')
                if fig_format != 'png':
                    # also save as png due to convenience for prelim plots
                    plt.savefig(out_dir + out_figname + '.png', format = 'png', dpi = fig_dpi, bbox_inches='tight')
            else:
                plt.savefig(out_dir + 'figure.' + fig_format, format = fig_format, dpi = fig_dpi)          
    return fig, ax


def add_prcp_bars(fig, ax, da_prcp_obs, da_prcp_mdl, xval=None, colors = ['black', 'royalblue'], alpha = 0.3, bar_width=1,
                          unit = 'mm', out_dir=None, out_figname=None, fig_format='pdf', ylim = None, varname = 'Rainfall', plot_type='bar', 
                         data_names = ['AGCD', 'Model Forc.'], addLegend=True, add_biasText=True, invertAxis=False, fig_dpi=300):
    '''
    Function to add daily precip as bar plots on top of the streamflow.
    plot_type can be 'bar' or 'fill'
    '''
    station_list = da_prcp_obs.station.values

    for i in range(len(station_list)):
        ax_twin = ax[i].twinx()
        if invertAxis:
            ax_twin.invert_yaxis()
        if xval is None:
            xval = da_prcp_obs.time.values
        if plot_type == 'bar':
            ax_twin.bar(x = xval, height = da_prcp_obs.isel(station = i).values, color = colors[0], alpha = alpha, width=bar_width)
        elif plot_type == 'fill':
            ax_twin.fill_between(xval, 0, da_prcp_obs.isel(station = i).values, color = colors[0], alpha = alpha)
        if xval is None:
            xval = da_prcp_mdl.time.values

        # print(len(xval))
        # print(len(da_prcp_mdl.isel(station = i).values))
        if plot_type == 'bar':
            ax_twin.bar(x = xval, height = da_prcp_mdl.isel(station = i).values, color = colors[1], alpha = alpha, width=bar_width)
        elif plot_type == 'fill':
            ax_twin.fill_between(xval, 0, da_prcp_mdl.isel(station = i).values, color = colors[1], alpha = alpha)


        if add_biasText:
            # adding text about biases
            obs_val = da_prcp_obs.isel(station = i).mean().values
            mdl_val = da_prcp_mdl.isel(station = i).mean().values
            obs_val_arr = da_prcp_obs.isel(station = i).values
            mdl_val_arr = da_prcp_mdl.isel(station = i).values
            NSE = calc_NSE(mdl_val_arr, obs_val_arr)
            
            fontweight = 'normal'
            ax_twin.text(0.75, 0.8, varname, 
                               ha='left', va='center', transform=ax_twin.transAxes, fontweight='semibold', fontsize=14, color = 'black')
            ax_twin.text(0.75, 0.7, data_names[0] + ' =' + str(np.round(obs_val, 1)) + ' ' + unit, 
                               ha='left', va='center', transform=ax_twin.transAxes, fontweight=fontweight, fontsize=14, color = 'black')
            ax_twin.text(0.75, 0.6, data_names[1] + ' =' + str(np.round(mdl_val, 1)) + ' ' + unit, 
                               ha='left', va='center', transform=ax_twin.transAxes, fontweight=fontweight, fontsize=14, color = 'black')
            if obs_val > 0:
                diff_perc = (mdl_val - obs_val)/obs_val*100
                if diff_perc > 5:
                    diff_color = 'blue'
                elif diff_perc < -5:
                    diff_color = 'red'
                else:
                    diff_color = 'black'
                ax_twin.text(0.75, 0.5, 'Diff =' + str(int(diff_perc)) + '%', 
                                   ha='left', va='center', transform=ax_twin.transAxes, fontweight=fontweight, fontsize=14, color = diff_color)
            if NSE>0:
                nse_col = 'forestgreen'
            else:
                nse_col = 'sienna'
            ax_twin.text(0.75, 0.4, 'NSE =' + str(round(NSE,2)), 
                                   ha='left', va='center', transform=ax_twin.transAxes, fontweight=fontweight, fontsize=14, color = nse_col)
        
        if ylim is not None:
            ax_twin.set_ylim(ylim)
        else:
            ydata = np.append(da_prcp_obs.isel(station = i).values, da_prcp_mdl.isel(station = i).values)
            ax_twin.set_ylim((0, 1.25*np.nanmax(ydata)))
        ax_twin.set_ylabel(varname + ' (' + unit + ')')
        
        if addLegend:
            legend_elements = [Patch(facecolor=colors[0], edgecolor=None, alpha = alpha, label=data_names[0]),
                               Patch(facecolor=colors[1], edgecolor=None, alpha = alpha, label=data_names[1])]
            fig.legend(handles=legend_elements, loc='center', bbox_to_anchor=(0.5, 0.02), ncol=2, frameon=False)
        
        if out_dir is not None:
            if out_figname is not None:
                plt.savefig(out_dir + out_figname + '.' + fig_format, format = fig_format, dpi = fig_dpi, bbox_inches='tight')
                if fig_format != 'png':
                    # also save as png due to convenience for prelim plots
                    plt.savefig(out_dir + out_figname + '.png', format = 'png', dpi = fig_dpi, bbox_inches='tight')
            else:
                plt.savefig(out_dir + 'figure.' + fig_format, format = fig_format, dpi = fig_dpi)                    
    return fig, ax

##################################
# T2M calculation functions
##################################

#
# Information about 2-m air temperature calculation in NoahMP
#
#--------------------------------------------------------------------------
# 2-m air temperature (T2M) in NoahMP

# T2M in NoahMP is calculated by combining T2MB and T2MV based on land use class & the fraction of vegetation on the grid cell.

# The calculation copied from trunk/NDHMS/Land_models/NoahMP/phys/module_sf_noahmplsm.F around line 2045 is as below.

# IF (VEG .AND. FVEG > 0) THEN
# T2M   = FVEG * T2MV      + (1.0 - FVEG) * T2MB
# ELSE
# T2M = T2MB

# Long names/desc. of variables
# FVEG   !greeness vegetation fraction (-)
# T2MV   !2-m air temperature over vegetated part [k]
# T2MB   !2-m air temperature over bare ground part [k]
# T2M    !2 m height air temperature (k)
# LU_INDEX is based on MODIS veg classes

# &noahmp_modis_veg_categories VEG_DATASET_DESCRIPTION = "modified igbp modis noah" NVEG = 20 /

# &noahmp_modis_parameters ! 1 'Evergreen Needleleaf Forest' -> USGS 14
# ! 2, 'Evergreen Broadleaf Forest' -> USGS 13
# ! 3, 'Deciduous Needleleaf Forest' -> USGS 12
# ! 4, 'Deciduous Broadleaf Forest' -> USGS 11
# ! 5, 'Mixed Forests' -> USGS 15
# ! 6, 'Closed Shrublands' -> USGS 8 "shrubland"
# ! 7, 'Open Shrublands' -> USGS 9 "shrubland/grassland"
# ! 8, 'Woody Savannas' -> USGS 8 "shrubland"
# ! 9, 'Savannas' -> USGS 10
# ! 10, 'Grasslands' -> USGS 7
# ! 11 'Permanent wetlands' -> avg of USGS 17 and 18 (herb. wooded wetland)
# ! 12, 'Croplands' -> USGS 2 "dryland cropland"
# ! 13, 'Urban and Built-Up' -> USGS 1
# ! 14 'cropland/natural vegetation mosaic' -> USGS 5 "cropland/grassland"
# ! 15, 'Snow and Ice' -> USGS 24
# ! 16, 'Barren or Sparsely Vegetated' -> USGS 19
# ! 17, 'Water' -> USGS 16
# ! 18, 'Wooded Tundra' -> USGS 21
# ! 19, 'Mixed Tundra' -> USGS 22
# ! 20, 'Barren Tundra' -> USGS 23

# So, T2MV would not exist for classes 11, 13, 16, 17 that are not expected to have any vegetation.

# The FVEG variables in the model is the SHDMAX from the input data (wrfinput_d01)
# The maximum annual vegetion fraction in input data (SHDMAX).
# ds_wrfin['SHDMAX'][0,:,:].plot()
# This is the variable that is assigned to fveg for namelist option DYNAMIC_VEG_OPTION=4 (the recommended option used in these simulations)
# based on tracing the NoahMP code to the READVEG_HRLDAS function in the trunk/NDHMS/Land_models/NoahMP/IO_code/module_hrldas_netcdf_io.F

def calc_T2M(da_T2MV, da_T2MB, da_veg, da_veg_frac):

    # contributions of vegetated and bare portions in vegetated grid 
    da_T2M_vegetated = (da_T2MV * da_veg_frac) + (da_T2MB * (1-da_veg_frac))

    da_T2M = xr.where(da_veg == 1, da_T2M_vegetated, da_T2MB).rename('T2M')
    attrs = da_T2MV.attrs
    attrs.update({'long_name': '2m Air Temp'})
    da_T2M = da_T2M.assign_attrs(attrs)
    return da_T2M

def calc_T2M_and_writeFile(run_dir, 
                           T2MV_file = '/OUTPUT/DAILY_FILES/T2MV_concatTime.nc',
                           T2MB_file = '/OUTPUT/DAILY_FILES/T2MB_concatTime.nc',
                           wrfinput_file = '/DOMAIN/wrfinput_d01',
                           out_file = '/OUTPUT/DAILY_FILES/T2M_concatTime.nc'):
    '''
    The function calculates the T-2m based on simulated vegetation (T2MV) & bare ground (T2MB) 2-m air temperatures
    The file names are specified with respect to the run_dir. 
    To use the function with independently specified absolute paths of T2MV_file, T2MG_file & wrfinput_file, set the run_dir to None.
    '''
    #
    # read files
    #
    if run_dir is not None:
        ds_t2mv = xr.open_dataset(run_dir + T2MV_file)
        ds_t2mb = xr.open_dataset(run_dir + T2MB_file)
        ds_wrfinput = xr.open_dataset(run_dir + wrfinput_file)
        out_file_fullpath = run_dir + out_file
    else:
        ds_t2mv = xr.open_dataset(T2MV_file)
        ds_t2mb = xr.open_dataset(T2MB_file)
        ds_wrfinput = xr.open_dataset(wrfinput_file)
        out_file_fullpath = out_file

    # the landuse & vegetation fraction arrays from the wrfinput file
    # get all the vegetated land use classes
    da_lu = ds_wrfinput['LU_INDEX'][0,:,:].where(~(ds_wrfinput['LU_INDEX'][0,:,:].isin([11, 13, 16, 17])))
    # get the vegetation fraction
    da_veg_frac = ds_wrfinput['SHDMAX'][0,:,:].where(~np.isnan(da_lu))/1000
    # grids that are vegetated are indicated as 1
    da_veg = da_lu/da_lu

    # Adjusting discrepancy in xy names in the output (named 'x', 'y'), and wrfinput (named 'south_north', 'west_east') files
    # rename da's from wrfinput to match the output files
    xy_rename = {'south_north':'y', 'west_east':'x'}
    da_lu = da_lu.rename(xy_rename)
    da_veg = da_veg.rename(xy_rename)
    da_veg_frac = da_veg_frac.rename(xy_rename)

    # calculate T2M
    da_T2M = calc_T2M(ds_t2mv['T2MV'], ds_t2mb['T2MB'], da_veg, da_veg_frac)

    # global file attributes
    attrs = ds_t2mv.attrs
    attrs.update({'calculated using': '/home/566/ad9701/wrf_hydro/wrf_hydro_analyses_funcs.py',
                  'date': datetime.now().strftime('%Y-%m-%d %H:%M')})
    ds_T2M = da_T2M.to_dataset().assign_attrs(attrs)
    ds_T2M.to_netcdf(out_file_fullpath)
    print('Wrote output file:' + out_file_fullpath)
    return None