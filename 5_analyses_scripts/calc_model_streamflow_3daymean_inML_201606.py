"""
Writes model 3-day mean streamflow to a text file for the calibration period
"""

__title__ = "calc_3daymean_flow_for_calib"
__author__ = "Anjana Devanand"
__version__ = "1.0"
__email__ = "anjanadevanand@gmail.com"

import xarray as xr
import pandas as pd
import numpy as np
import sys

if __name__ == '__main__':
    
    # the calibration period
    time_sel = slice('2016-06-01', '2016-06-30')

    # get functions I defined
    new_path = '/home/566/ad9701/wrf_hydro/'
    if new_path not in sys.path:
        sys.path.append(new_path)
    import wrf_hydro_analyses_funcs as myhydro

    frxst_file = 'frxst_pts_out.txt'
    ds_model = myhydro.read_streamflow_textfile(frxst_file)
    q_MLperday = np.round(ds_model['q_cms'].sel(time = time_sel)*86.4, 3)
    q_MLperday = q_MLperday.resample(time = '1D').mean()   # daily values of streamflow at all gauges. Array shape is time(days) x gauge
    q_ML_3daymean = q_MLperday.resample(time = '3D').mean()    

    arr_gauge = np.repeat(q_ML_3daymean.gauge.values, q_ML_3daymean.shape[0])
    df_out = pd.DataFrame({'gauge': arr_gauge,
                           'flow (ML/day)': np.round(q_ML_3daymean.values.transpose().flatten(),3)})
    # 1-D array of flow values. Daily values at gauge 1 followed by daily values at gauge 2... and so on..
    df_out.to_csv('ML_3daymean_frxst_pts_out.txt', sep=',', index=False, header=False)
