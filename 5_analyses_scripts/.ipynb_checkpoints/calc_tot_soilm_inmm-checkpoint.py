"""
Calculate tot SOIL_M in mm and save the data for the 00-hour timesteps only
"""

__title__ = "calc_tot_soilm_savenc"
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

if __name__ == '__main__':
    
    wrf_hydro_dir = os.environ['wrf_hydro_dir']
    var = 'SOIL_M'

    for year in [2013, 2014, 2015, 2016, 2017]:
        fname = 'SOIL_M_concatTime_' + str(year) + '.nc'
        fname_out = 'SOIL_M_total_inmm_00hr_' + str(year) + '.nc'
        ds = xr.open_dataset(wrf_hydro_dir + fname)
        target_hours = [0]
        da_subset = ds[var].sel(time=ds['time.hour'].isin(target_hours))
        da_subset_mm = calc_tot_sm_inmm(da_subset)
        da_subset_mm.to_netcdf(wrf_hydro_dir + fname_out)