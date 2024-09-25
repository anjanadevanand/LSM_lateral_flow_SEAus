"""
Reads the daily files, extracts the specified variable, and saves it in a single file
"""

__title__ = "extract_var_save_singleFile"
__author__ = "Anjana Devanand"
__version__ = "1.0"
__email__ = "anjanadevanand@gmail.com"

import xarray as xr
import os
import glob

def save_singlefile(output_dir, varname, out_suffix = '_concatTime'):
    file_names = sorted(glob.glob(output_dir + '*.LDASOUT_DOMAIN1'))
    da_list = []
    for f in file_names:
        ds_temp = xr.open_dataset(f)
        da_temp = ds_temp[varname].load()
        da_list.append(da_temp)
        attrs_ds = ds_temp.attrs
        del ds_temp, da_temp
    da = xr.concat(da_list, dim='time')
    ds = da.to_dataset().assign_attrs(attrs_ds)
    ds.to_netcdf(output_dir + varname + out_suffix + '.nc')

if __name__ == '__main__':
        
    # the run directory of the simulation
    WRF_HYDRO_DIR = os.environ['WRF_HYDRO_DIR']
    # the name of the variable to extract
    varname = os.environ['varname']
    
    output_dir = WRF_HYDRO_DIR + '/OUTPUT/DAILY_FILES/'
    save_singlefile(output_dir, varname)    
