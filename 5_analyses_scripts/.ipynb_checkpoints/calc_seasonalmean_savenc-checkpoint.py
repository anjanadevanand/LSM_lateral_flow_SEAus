"""
Calculate seasonal means & accumulations for different time slices & save in netcdf files for plotting
"""

__title__ = "calc_seasmean_seasaccum_savenc"
__author__ = "Anjana Devanand"
__version__ = "1.0"
__email__ = "anjanadevanand@gmail.com"

import xarray as xr
import numpy as np
import pandas as pd
import os
import sys
import glob

new_path = '/home/566/ad9701/drought_probability/final_code_AU/'
if new_path not in sys.path:
    sys.path.append(new_path)
import validation_functions as myfuncs

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

def calc_seasonal_mean(path, var, time_sel, file_suffix = '_daily_mean'):
    if var == 'SOIL_M_total':
        fnames = glob.glob(path + '/SOIL_M' + file_suffix + '*')
        if len(fnames)>1:
            ds = xr.open_mfdataset(path + '/SOIL_M' + file_suffix + '*.nc')
        else:
            ds = xr.open_dataset(path + '/SOIL_M' + file_suffix + '.nc')
        da = calc_tot_sm_inmm(ds['SOIL_M'])
    elif var == 'SOIL_M_2layer':
        fnames = glob.glob(path + '/SOIL_M' + file_suffix + '*')
        if len(fnames)>1:
            ds = xr.open_mfdataset(path + '/SOIL_M' + file_suffix + '*.nc')
        else:
            ds = xr.open_dataset(path + '/SOIL_M' + file_suffix + '.nc')
        da = two_layer_sm_inmm(ds['SOIL_M'])
    else:
        fnames = glob.glob(path + '/' + var + file_suffix + '*')
        if len(fnames)>1:
            ds = xr.open_mfdataset(path + '/' + var + file_suffix + '*.nc')
        else:
            ds = xr.open_dataset(path + '/' + var + file_suffix + '.nc')
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

if __name__ == '__main__':
    
    wrf_hydro_dir = os.environ['wrf_hydro_dir']

    time_sel_dict = {'2016': slice('2015-12', '2016-11'),
                     '2017': slice('2016-12', '2017-11'),
                     '2016-17': slice('2015-12', '2017-11')}
    var_list = ['LH', 'HFX', 'SOIL_M_2layer', 'SOIL_M'] #, 'SOIL_M_total', 'SOIL_M_2layer']
    #var_list = ['SOIL_M_2layer']
    #var_list = ['SOIL_M']

    #time_sel_dict = {'2016-17': slice('2015-12', '2017-11')}
    #var_list = ['LH']    
    
    for time_key in time_sel_dict.keys():    
        time_sel = time_sel_dict[time_key]
        for var in var_list:
            data_path = wrf_hydro_dir + '/' #+ 'OUTPUT/DAILY_FILES/'
            da_seas = calc_seasonal_mean(data_path, var, time_sel)
            output_file = data_path + 'seasonal_data/' + time_key + '_' + var + '_mean.nc'
            print(output_file)
            da_seas.to_netcdf(output_file)
            if (var == 'SOIL_M') | (var == 'SOIL_M_total') | (var == 'SOIL_M_2layer'):
                da_seas_accum = calc_seasonal_accum(data_path, var, time_sel)
                output_file = data_path + 'seasonal_data/' + time_key + '_' + var + '_seasonal_accum.nc'
                print(output_file)
                da_seas_accum.to_netcdf(output_file)
