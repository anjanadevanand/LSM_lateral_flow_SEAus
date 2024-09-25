#!/bin/bash

##############################################################
# Created by Anjana Devanand; 30 Jun 2023
# Used to 
# 1. calculate seasonal mean & save the data in netcdf files
##############################################################

#myArray=("/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_defSoil_defPar/trunk/NDHMS/Run/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_defSoil_kPar/trunk/NDHMS/Run/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_ternSoil_defPar/trunk/NDHMS/Run/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_ternSoil_kPar/trunk/NDHMS/Run/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_defSoil_defPar/trunk/NDHMS/Run/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_defSoil_kPar/trunk/NDHMS/Run/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_ternSoil_defPar/trunk/NDHMS/Run/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_ternSoil_kPar/trunk/NDHMS/Run/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_noCalib_defSoil_defPar/trunk/NDHMS/Run/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_noCalib_defSoil_defPar/trunk/NDHMS/Run/")

#myArray=("/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_defSoil_defPar/trunk/NDHMS/Run/")

#for wrf_hydro_dir in ${myArray[@]}; do
#  if [ ! -d "${wrf_hydro_dir}OUTPUT/DAILY_FILES/seasonal_data" ] ; then
#  mkdir "${wrf_hydro_dir}OUTPUT/DAILY_FILES/seasonal_data"
#  fi
#  cp job_calc_seasonal_template.pbs job_calc_seasonal.pbs
#  sed -i 's|wrf_hydro_dir|wrf_hydro_dir='${wrf_hydro_dir}OUTPUT/DAILY_FILES/'|g' job_calc_seasonal.pbs
#  job1=$(qsub job_calc_seasonal.pbs)
#  echo $job1
#done

#myArray=("/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/concat_results_lat/")
#myArray=("/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_LSMonly_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_12g_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")

#4-km runs with different soil data
#myArray=("/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_kishPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_kishPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_defSoil_kishPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_tern1m_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_tern1m_kishPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_tern_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_tern_kishPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")

### waiting for run to complete
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_kishPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \

#4-km runs selected soil data
#myArray=("/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km_100mRT/wrf_hydro_nwm_public-5.2.0_domain4_4km_t500_RTCHon_4g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/") # \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")

#1-km res runs
#myArray=("/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/output_wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_monPnTCorr_defSoil_defPar/OUTPUT/DAILY_FILES/")

#10-km res runs
#myArray=("/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wNewCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wNewCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_t80_RTCHon_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")

#old 10-km res runs. Calibrated to params from 4km, 250mRT
#myArray=("/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_t80_RTCHon_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")

#myArray=("/g/data/w28/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_4km_t180_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_10km_t180_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")

#myArray=("/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km_100mRT/wrf_hydro_nwm_public-5.2.0_trial2/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")

myArray=("/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")

for wrf_hydro_dir in ${myArray[@]}; do
  if [ ! -d "${wrf_hydro_dir}/seasonal_data" ] ; then
  mkdir "${wrf_hydro_dir}/seasonal_data"
  fi
  cp job_calc_seasonal_template.pbs job_calc_seasonal.pbs
  sed -i 's|wrf_hydro_dir|wrf_hydro_dir='${wrf_hydro_dir}'|g' job_calc_seasonal.pbs
  job1=$(qsub job_calc_seasonal.pbs)
  echo $job1
done
