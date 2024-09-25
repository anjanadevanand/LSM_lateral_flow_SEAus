"""
Calculates mean streamflow over a period for calibration
"""

__title__ = "calc_mean_flow_for_calib"
__author__ = "Anjana Devanand"
__version__ = "1.0"
__email__ = "anjanadevanand@gmail.com"


import xarray as xr
import pandas as pd
import numpy as np

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
    df_frxst = pd.read_csv(filename, header = None, names=colnames) #, index_col = None)

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

if __name__ == '__main__':
    
    # the calibration period
    time_sel = slice('2016-09-01', '2016-09-17')

    frxst_file = 'frxst_pts_out.txt'
    ds_model = read_streamflow_textfile(frxst_file)
    mean_q_Lperday = np.round(ds_model['q_cms'].sel(time = time_sel).mean('time')*86.4, 3)
    df_out = pd.DataFrame({'gauge': ds_model.gauge.values,
                           'flow (L/day)': mean_q_Lperday.values})
    df_out.to_csv('mean_frxst_pts_out.txt', sep=',', index=False, header=False)
