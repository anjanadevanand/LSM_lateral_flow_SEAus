#!/bin/bash

##############################################################
# Created by Anjana Devanand; 13 Sep 2023
# Used to 
# 1. calculate total SOILM in mm at the 00 hour of each day and save the data in netcdf files
##############################################################

#4-km runs selected soil data
#1-km
#10-km
#myArray=("/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km_100mRT/wrf_hydro_nwm_public-5.2.0_domain4_4km_t500_RTCHon_4g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")
myArray=("/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
"/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/output_wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_monPnTCorr_defSoil_defPar/OUTPUT/DAILY_FILES/" \
"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_t80_RTCHon_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km_100mRT/wrf_hydro_nwm_public-5.2.0_trial2/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")

#myArray=("/g/data/w28/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_4km_t180_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/" \
#"/g/data/w28/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_10km_t180_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")
#myArray=("/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/OUTPUT/DAILY_FILES/")

for wrf_hydro_dir in ${myArray[@]}; do
  cp job_calc_soilm_total_template.pbs job_calc_soilm_total.pbs
  sed -i 's|wrf_hydro_dir|wrf_hydro_dir='${wrf_hydro_dir}'|g' job_calc_soilm_total.pbs
  job1=$(qsub job_calc_soilm_total.pbs)
  echo $job1
done
