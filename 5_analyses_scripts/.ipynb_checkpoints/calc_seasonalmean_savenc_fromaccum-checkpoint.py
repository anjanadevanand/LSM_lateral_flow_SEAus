"""
Calculate seasonal means from accumulated var (ACCET) different time slices & save in netcdf files for plotting
"""

__title__ = "calc_seasmean_savenc_fromaccum"
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

def calc_seasonal_from_accumvar(path, var, time_sel, newvar, newunit, file_suffix = '_concatTime'):
    fnames = glob.glob(path + '/' + var + file_suffix + '*')
    if len(fnames)>1:
        ds = xr.open_mfdataset(path + '/' + var + file_suffix + '*.nc')
    else:
        ds = xr.open_dataset(path + '/' + var + file_suffix + '.nc')

    seas_names = ['DJF', 'JJA', 'MAM', 'SON']
    # data grouped by season
    da_gb = ds[var].sel(time = time_sel).groupby('time.season')
    list_mean_byseas = []
    for seas in seas_names:
        x0 = da_gb[seas][0,:,:]
        xend = da_gb[seas][-1,:,:]
        ndays = len(np.unique(da_gb[seas]['time.dayofyear'].values))
        if ndays > 93:
            print('Input only a single year in time_sel. Otherwise, the calculation of avg (per day) by subtracting the last and first values in the season wont work.')
            exit()
        da_mmpday = (xend - x0)/ndays
        da_mmpday = da_mmpday.rename(newvar).assign_attrs({'units':newunit})
        list_mean_byseas.append(da_mmpday)
    da_seas_mean = xr.concat(list_mean_byseas, dim = 'season').assign_coords({'season': seas_names})
    return(da_seas_mean)

if __name__ == '__main__':
    
    wrf_hydro_dir = os.environ['wrf_hydro_dir']

    time_sel_dict = {'2016': slice('2015-12', '2016-11'),
                     '2017': slice('2016-12', '2017-11'),
                     '2016-17': [slice('2015-12', '2016-11'), slice('2016-12', '2017-11')]}
    var = 'ACCET'
    newvar = 'ET'
    newunit = 'mm/day' 
    
    for time_key in time_sel_dict.keys():    
        time_sel = time_sel_dict[time_key]
        data_path = wrf_hydro_dir + '/' #+ 'OUTPUT/DAILY_FILES/'
        
        if type(time_sel) is list:
            da_seas0 = calc_seasonal_from_accumvar(data_path, var, time_sel[0], newvar, newunit)
            da_seas1 = calc_seasonal_from_accumvar(data_path, var, time_sel[1], newvar, newunit)
            da_seas = (da_seas0 + da_seas1)/2
            da_seas = da_seas.assign_attrs({'units':newunit})
        else:
            da_seas = calc_seasonal_from_accumvar(data_path, var, time_sel, newvar, newunit)
        
        output_file = data_path + 'seasonal_data/' + time_key + '_' + newvar + '_mean.nc'
        print(output_file)
        da_seas.to_netcdf(output_file)
