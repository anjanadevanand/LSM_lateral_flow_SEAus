"""
Copy the calibrated LKSATFAC values from the 4-km calib run to the 1-km run
"""

__title__ = "copy_LKSATFAC_to_fulldom_hires"
__author__ = "Anjana Devanand"
__version__ = "1.0"
__email__ = "anjanadevanand@gmail.com"

import xarray as xr
import pandas as pd
import numpy as np

if __name__ == '__main__':
    
    # Read in the 'Fulldom_hires.nc' file that is created after calibration of the 4-km run
    in_file_4k = 'Fulldom_hires_4km_calib.nc'
    ds_fulldom_4k = xr.open_dataset(in_file_4k)

    in_file_1k = 'Fulldom_hires.nc'
    ds_fulldom_1k = xr.open_dataset(in_file_1k)

    parName='LKSATFAC'
    ds_fulldom_1k[parName] = ds_fulldom_4k[parName]

    out_file = 'DOMAIN/Fulldom_hires.nc'
    ds_fulldom_1k.to_netcdf(out_file)