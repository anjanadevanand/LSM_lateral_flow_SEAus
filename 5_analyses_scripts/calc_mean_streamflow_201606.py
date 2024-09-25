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
    mean_q_Lperday = np.round(ds_model['q_cms'].sel(time = time_sel).mean('time')*86.4, 3)
    df_out = pd.DataFrame({'gauge': ds_model.gauge.values,
                           'flow (ML/day)': mean_q_Lperday.values})
    df_out.to_csv('mean_frxst_pts_out.txt', sep=',', index=False, header=False)
