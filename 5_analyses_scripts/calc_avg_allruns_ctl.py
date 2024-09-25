"""
Calculate averages from all runs & save in netcdf files
"""

__title__ = "calc_runAvg_savenc"
__author__ = "Anjana Devanand"
__version__ = "1.0"
__email__ = "anjanadevanand@gmail.com"

import xarray as xr

def save_ensemble_and_ensMean(dir_list, run_name_list, fname, out_dir, time_sel = None, subdir = 'OUTPUT/DAILY_FILES/', fname_suffix = '_concatTime.nc'):
    da_list = []
    for wrf_hydro_dir in dir_list:
        path = wrf_hydro_dir + '/' + subdir + '/'
        ds = xr.open_dataset(path + '/' + fname + fname_suffix)
        if time_sel is not None:
            da_list.append(ds[fname].sel(time = time_sel))
        else:
            da_list.append(ds[fname])
    da_concat = xr.concat(da_list, dim = 'run').assign_coords({'run': run_name_list})
    da_concat_avg = da_concat.mean('run')

    # save the average
    out_file1 = out_dir + '/' + fname + fname_suffix
    da_concat_avg.to_netcdf(out_file1)

    # also save the full data
    out_file2 = out_dir + '/allruns_' + fname + fname_suffix
    da_concat.to_netcdf(out_file2)
    return None

if __name__ == '__main__':
        
    ##############################################
    # USER INPUT: CHANGE HERE
    ##############################################
    wrf_hydro_dir_list = ['/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_defSoil_defPar/trunk/NDHMS/Run/',
                          '/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_defSoil_kPar/trunk/NDHMS/Run/',
                          '/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_ternSoil_defPar/trunk/NDHMS/Run/',
                          '/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_ternSoil_kPar/trunk/NDHMS/Run/']
    
    out_dir = '/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/concat_results_ctl/'
    
    run_name_list = ['defSoil_defPar', 'defSoil_kPar', 'ternSoil_defPar', 'ternSoil_kPar']
    
    ###############################################
    
    time_sel = slice('2015-12', '2017-12')

    # save_ensemble_and_ensMean(wrf_hydro_dir_list, run_name_list, fname = 'LH', out_dir = out_dir, time_sel = time_sel)
    # save_ensemble_and_ensMean(wrf_hydro_dir_list, run_name_list, fname = 'HFX', out_dir = out_dir, time_sel = time_sel)

    # # SOIL_M is saved by year due to its size; so need a loop here
    # for year in range(2015, 2018):
    #     fname_suffix = '_concatTime_' + str(year) + '.nc'
    #     save_ensemble_and_ensMean(wrf_hydro_dir_list, run_name_list, fname = 'SOIL_M', out_dir = out_dir, time_sel=None, fname_suffix=fname_suffix)

    for fname in ['LH', 'HFX', 'SOIL_M']:
        save_ensemble_and_ensMean(wrf_hydro_dir_list, run_name_list, fname = fname, out_dir = out_dir, time_sel = time_sel, fname_suffix = '_daily_mean.nc')