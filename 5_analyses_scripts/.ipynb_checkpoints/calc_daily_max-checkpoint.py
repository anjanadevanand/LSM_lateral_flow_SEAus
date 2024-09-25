"""
Resamples hourly data to daily by calculating mean
"""

__title__ = "calc_daily_mean"
__author__ = "Anjana Devanand"
__version__ = "1.0"
__email__ = "anjanadevanand@gmail.com"

import xarray as xr
import os
import glob

if __name__ == '__main__':
        
    # the run directory of the simulation
    WRF_HYDRO_DIR = os.environ['WRF_HYDRO_DIR']
    # the name of the variable to extract
    varname = os.environ['varname']
    
    output_dir = WRF_HYDRO_DIR + '/OUTPUT/DAILY_FILES/'
    ds = xr.open_mfdataset(output_dir + varname + '_concatTime*.nc')
    ds = ds.load()
    ds_daily = ds.resample(time = '1D').max()
    ds_daily[varname].encoding['zlib'] = True
    ds_daily[varname].encoding['complevel'] = 1
    ds_daily.to_netcdf(output_dir + varname + '_daily_max.nc')
