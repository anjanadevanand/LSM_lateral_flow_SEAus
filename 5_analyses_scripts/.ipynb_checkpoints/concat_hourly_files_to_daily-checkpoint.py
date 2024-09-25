import xarray as xr
import os
import glob

"""
The hourly files take a long time to read into jupyter notebooks on OOD; probably because of the option 3 compression I used
This script creates daily files to reduce the number of files & make it easier to read in
"""

__title__ = "concat_hourly_files_to_daily"
__author__ = "Anjana Devanand"
__version__ = "2.0"
__email__ = "anjanadevanand@gmail.com"

def concat_files(file_names, suffix, out_dir):
    # if files exists, some may not as month may not have 30th & 31st days
    if (len(file_names)>0):
        if (len(file_names)<23):  # start and end days would have 23 timesteps; there should not be any other days with less than 24 timesteps
            print(str(len(file_names)) + ' timesteps in ' + year + mon + day)

        ds = xr.open_mfdataset(file_names, concat_dim='time', combine = 'nested')
        for var in ds.data_vars:
            ds[var].encoding['zlib'] = True
            ds[var].encoding['complevel'] = 1
            del(ds[var].encoding['contiguous'])
            del(ds[var].encoding['chunksizes'])

        out_file = str(year) + mon + day + suffix
        ds.to_netcdf(out_dir + out_file)
        # now delete the original hourly files
        for f in file_names:
            os.remove(f)
        return None

if __name__ == '__main__':
    
    # the run directory of the simulation
    WRF_HYDRO_DIR = os.environ['WRF_HYDRO_DIR']
    year = os.environ['year']
    
    # mon & day may need to be padded with zero
    mon_in = os.environ['mon']
    day_in = os.environ['day']
    mon = str.zfill(mon_in,2)
    day = str.zfill(day_in,2)
    
    out_dir = WRF_HYDRO_DIR + 'OUTPUT/DAILY_FILES/'
    
    # LDASOUT
    suffix = '.LDASOUT_DOMAIN1'
    file_names = sorted(glob.glob(WRF_HYDRO_DIR + 'OUTPUT/' + year + mon + day + '*.LDASOUT_DOMAIN1'))
    concat_files(file_names, suffix, out_dir)
    
    # LSMOUT
    suffix = '.LSMOUT_DOMAIN1'
    file_names = sorted(glob.glob(WRF_HYDRO_DIR + '/' + year + mon + day + '*.LSMOUT_DOMAIN1'))
    concat_files(file_names, suffix, out_dir)
    
    # RTOUT
    suffix = '.RTOUT_DOMAIN1'
    file_names = sorted(glob.glob(WRF_HYDRO_DIR + '/' + year + mon + day + '*.RTOUT_DOMAIN1'))
    concat_files(file_names, suffix, out_dir)
    
    # GWOUT
    suffix = '.GWOUT_DOMAIN1'
    file_names = sorted(glob.glob(WRF_HYDRO_DIR + '/' + year + mon + day + '*.GWOUT_DOMAIN1'))
    concat_files(file_names, suffix, out_dir)

    # CHRTOUT
    suffix = '.CHRTOUT_DOMAIN1'
    file_names = sorted(glob.glob(WRF_HYDRO_DIR + '/' + year + mon + day + '*.CHRTOUT_DOMAIN1'))
    concat_files(file_names, suffix, out_dir)

    # .CHRTOUT_GRID1
    suffix = '.CHRTOUT_GRID1'
    file_names = sorted(glob.glob(WRF_HYDRO_DIR + '/' + year + mon + day + '*.CHRTOUT_GRID1'))
    concat_files(file_names, suffix, out_dir)
