"""
Calculates mean streamflow over a period for calibration
"""

__title__ = "calc_obs_flow_for_pst_file"
__author__ = "Anjana Devanand"
__version__ = "1.0"
__email__ = "anjanadevanand@gmail.com"


import xarray as xr
import pandas as pd
import numpy as np
import argparse
import sys
from pandas.tseries.frequencies import to_offset

if __name__ == '__main__':
    
    # the calibration period start & end dates - to be input as args
    parser = argparse.ArgumentParser(description="Get the calibration time period")
    parser.add_argument("startDate", type=str, help="The start date in form %Y-%m-%d")
    parser.add_argument("endDate", type=str, help="The end date in form %Y-%m-%d")
    args = parser.parse_args()

    startDate = args.startDate
    endDate = args.endDate
    
    time_sel = slice(startDate, endDate)
    
    # get functions I defined
    new_path = '/home/566/ad9701/wrf_hydro/'
    if new_path not in sys.path:
        sys.path.append(new_path)
    import wrf_hydro_analyses_funcs as myhydro
    
    ###################################
    # directories & files
    ###################################
    hrs_gauges_file = '/g/data/w97/ad9701/WRF-Hydro/SEA/forecast_points_csv_4_gauges.csv'
    # directory containing observed streamflow data
    obs_streamflow_dir = '/g/data/w97/ad9701/HRS_data_till2022/'
    
    ###################################
    # read observed data
    ###################################
    df_hrs = pd.read_csv(hrs_gauges_file)
    station_list = df_hrs['STATION'].values
    
    list_da_stn = []
    for Stn in station_list:
        da_stn = myhydro.read_obs_streamflow(obs_streamflow_dir, Stn, quiet=True)
        list_da_stn.append(da_stn)
    # create an xarray data array containing the data at all the stations
    ds_obs_flow = xr.concat(list_da_stn, dim = 'station').assign_coords({'station': station_list}).rename({'Date': 'time'})
    ds_obs_flow['Flow'] = ds_obs_flow['Flow'].assign_attrs({'units': 'ML'})
    ds_obs_flow = ds_obs_flow.assign_attrs({'Source': 'http://www.bom.gov.au/water/hrs/'})
    
    #########################################
    # select data for the calib time period
    #########################################
    da_daily_flow_sel = ds_obs_flow['Flow'].sel(time = time_sel)
    da_daily_flow_sel_mean = np.round(ds_obs_flow['Flow'].sel(time = time_sel).mean('time'),0)
    da_3daymean_flow = ds_obs_flow['Flow'].sel(time = time_sel).resample(time = '3D').mean()
    # place the time co-ordinate at the centre of the 3-day window
    da_3daymean_flow = da_3daymean_flow.assign_coords({'time': [x + to_offset("1D") for x in da_3daymean_flow['time'].values]})

    # create a df to write to csv. Arrange flow at one gauge followed by another
    arr_date_str = pd.to_datetime(da_daily_flow_sel.time.values).strftime('%d/%m/%Y')
    arr_date_str = [str(x) for x in arr_date_str]*len(da_daily_flow_sel.station)

    arr_daily_flow = []
    arr_gauge = []
    for istn in range(0, len(da_daily_flow_sel.station)):
        flow_temp = np.round(da_daily_flow_sel.isel(station = istn).values,0)
        arr_daily_flow.extend(flow_temp)
        arr_gauge.extend([da_daily_flow_sel.isel(station = istn).station.values]*len(flow_temp))
    df_obs = pd.DataFrame({'date': arr_date_str,
                           'obs flow (ML/day)': arr_daily_flow,
                           'gauge': arr_gauge})
    
    # the lines to be used in the '* observation data' section of the control file
    df_obs_for_pst = pd.DataFrame({'obs_num': ['o' + str(x) for x in range(1, len(df_obs)+1)],
                                   'obs flow (ML/day)': [int(x) for x in df_obs['obs flow (ML/day)'].values],
                                   'weight': [1.0]*len(df_obs),
                                   'obsgroup': ['obsgroup']*len(df_obs)})
    
    df_meanObs = pd.DataFrame({'gauge': da_daily_flow_sel_mean.station.values,
                               'obs flow (ML/day)': da_daily_flow_sel_mean.values})
    
    # the lines to be used in the '* observation data' section of the control file if using mean flows
    df_meanObs_for_pst = pd.DataFrame({'obs_num': ['o' + str(x) for x in range(1, len(df_meanObs)+1)],
                                       'obs flow (ML/day)': [int(x) for x in df_meanObs['obs flow (ML/day)'].values],
                                       'weight': [1.0]*len(df_meanObs),
                                       'obsgroup': ['obsgroup']*len(df_meanObs)})    

    # 3-day mean obs data
    arr_date_str = pd.to_datetime(da_3daymean_flow.time.values).strftime('%d/%m/%Y')
    arr_date_str = [str(x) for x in arr_date_str]*len(da_3daymean_flow.station)
   
    arr_3day_flow = []
    arr_gauge = []
    for istn in range(0, len(da_3daymean_flow.station)):
        flow_temp = np.round(da_3daymean_flow.isel(station = istn).values,0)
        arr_3day_flow.extend(flow_temp)
        arr_gauge.extend([da_3daymean_flow.isel(station = istn).station.values]*len(flow_temp))
    df_3day_obs = pd.DataFrame({'date': arr_date_str,
                                'obs flow (ML/day)': arr_3day_flow,
                                'gauge': arr_gauge})
    df_3day_obs_for_pst = pd.DataFrame({'obs_num': ['o' + str(x) for x in range(1, len(df_3day_obs)+1)],
                                        'obs flow (ML/day)': [int(x) for x in df_3day_obs['obs flow (ML/day)'].values],
                                        'weight': [1.0]*len(df_3day_obs),
                                        'obsgroup': ['obsgroup']*len(df_3day_obs)})
    
    ###########################################
    # write to text files. Assumed that an output dir named 'obs_flow' exists.
    ###########################################
    
    out_file1 = f'obs_flow/ML_daily_obs_flow_{da_daily_flow_sel.time[0].dt.strftime("%Y%m%d").data}_to_{da_daily_flow_sel.time[-1].dt.strftime("%Y%m%d").data}.txt'
    df_obs.to_csv(out_file1, sep=',', index=False, header=False)
    
    out_file2 = f'obs_flow/ML_daily_obs_for_pst_{da_daily_flow_sel.time[0].dt.strftime("%Y%m%d").data}_to_{da_daily_flow_sel.time[-1].dt.strftime("%Y%m%d").data}.txt'
    df_obs_for_pst.to_csv(out_file2, sep='\t', index=False, header=False)
    
    out_file3 = f'obs_flow/ML_mean_obs_flow_{da_daily_flow_sel.time[0].dt.strftime("%Y%m%d").data}_to_{da_daily_flow_sel.time[-1].dt.strftime("%Y%m%d").data}.txt'
    df_meanObs.to_csv(out_file3, sep=',', index=False, header=False)
    
    out_file4 = f'obs_flow/ML_mean_obs_for_pst_{da_daily_flow_sel.time[0].dt.strftime("%Y%m%d").data}_to_{da_daily_flow_sel.time[-1].dt.strftime("%Y%m%d").data}.txt'
    df_meanObs_for_pst.to_csv(out_file4, sep='\t', index=False, header=False)

    out_file7 = f'obs_flow/ML_3daymean_obs_flow_{da_3daymean_flow.time[0].dt.strftime("%Y%m%d").data}_to_{da_3daymean_flow.time[-1].dt.strftime("%Y%m%d").data}.txt'
    df_3day_obs.to_csv(out_file7, sep=',', index=False, header=False)

    out_file8 = f'obs_flow/ML_3daymean_obs_for_pst_{da_3daymean_flow.time[0].dt.strftime("%Y%m%d").data}_to_{da_3daymean_flow.time[-1].dt.strftime("%Y%m%d").data}.txt'
    df_3day_obs_for_pst.to_csv(out_file8, sep='\t', index=False, header=False)
    
    ###########################################
    # write also the corresponding pest instruction files
    ###########################################
    
    df_ins_daily = pd.DataFrame({'line': ['l1']*len(df_obs_for_pst),
                                 'identifier': ['#,#']*len(df_obs_for_pst),
                                 'obs': ['!' + x + '!' for x in df_obs_for_pst['obs_num'].values]})
    out_file5 = f'obs_flow/ML_daily_ins_file_{da_daily_flow_sel.time[0].dt.strftime("%Y%m%d").data}_to_{da_daily_flow_sel.time[-1].dt.strftime("%Y%m%d").data}.txt'
    df_ins_daily.to_csv(out_file5, sep='\t', index=False, header=False)
    
    df_ins_mean = pd.DataFrame({'line': ['l1']*len(df_meanObs_for_pst),
                                'identifier': ['#,#']*len(df_meanObs_for_pst),
                                'obs': ['!' + x + '!' for x in df_meanObs_for_pst['obs_num'].values]})
    out_file6 = f'obs_flow/ML_mean_ins_file_{da_daily_flow_sel.time[0].dt.strftime("%Y%m%d").data}_to_{da_daily_flow_sel.time[-1].dt.strftime("%Y%m%d").data}.txt'
    df_ins_mean.to_csv(out_file6, sep='\t', index=False, header=False)

    df_ins_3day = pd.DataFrame({'line': ['l1']*len(df_3day_obs_for_pst),
                                'identifier': ['#,#']*len(df_3day_obs_for_pst),
                                'obs': ['!' + x + '!' for x in df_3day_obs_for_pst['obs_num'].values]})
    out_file9 = f'obs_flow/ML_3daymean_ins_file_{da_3daymean_flow.time[0].dt.strftime("%Y%m%d").data}_to_{da_3daymean_flow.time[-1].dt.strftime("%Y%m%d").data}.txt'
    df_ins_3day.to_csv(out_file9, sep='\t', index=False, header=False)
    
