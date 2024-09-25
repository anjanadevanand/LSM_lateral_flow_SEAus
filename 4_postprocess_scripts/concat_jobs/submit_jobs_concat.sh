#!/bin/bash

#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain3_4km_t160_RTGWon/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain3_4km_RTGWon/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain3_4km_GW_LSMonly/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain3_4km_GW_RTGWon/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain3_4km_GW_t160_RTGWon/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTon/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly/trunk/NDHMS/Run/

#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTon_noPrecipCorr/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_noPrecipCorr/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_frxt_mask/trunk/NDHMS/Run/

#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_frxt_mask_4g_newCHPARM_monPCorr_GW/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_monPCorr/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_frxt_mask_4g_newCHPARM_monPCorr/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_monPCorr_longSpin/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_frxt_mask_4g_newCHPARM_monPCorr_longSpin/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTon_monPCorr/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_frxt_mask_4g_newCHPARM_monPCorr_TCorr_GW_201609/trunk/NDHMS/Run/

#*** Final runs using calibrated parameters ***
#*** 4km ***
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_ternSoil_kPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_defSoil_kPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_noCalib_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_ternSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_defSoil_kPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_noCalib_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_ternSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_ternSoil_kPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_defSoil_defPar_RD100/trunk/NDHMS/Run/

#*** 1km ***
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_12g_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_LSMonly_defSoil_defPar/trunk/NDHMS/Run/

#*** No Baseflow runs ***
#*** 4km; using default paremeters ***
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_kishPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_kishPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_kishPar/trunk/NDHMS/Run/

#*** 4km; calibrated runs
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_kishPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_kishPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_tern1m_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_defSoil_kishPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_tern1m_kishPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_monPnTCorr_LSMonly_tern_kishPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_kishPar/trunk/NDHMS/Run/

#*** 4km & 100m RT
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km_100mRT/wrf_hydro_nwm_public-5.2.0_domain4_4km_t500_RTCHon_4g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#***

#*** 10km
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_t80_RTCHon_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/
#! ** complete ** | WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km_100mRT/wrf_hydro_nwm_public-5.2.0_trial2/trunk/NDHMS/Run/
#***

#*** 10km calibrated at the same resolution
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wNewCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_t80_RTCHon_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wNewCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/

#*** 1km; calibrated runs
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/
#! ** complete ** | WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/

#*** 1km & 100m RT; calibrated runs
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#re-did 2016-03-16 
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_defSoil_defPar_201603_rerun/trunk/NDHMS/Run/
#2017-08 to the end
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_monPnTCorr_defSoil_defPar_201708_toEnd/trunk/NDHMS/Run/
# concatenated all outputs here
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/output_wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_monPnTCorr_defSoil_defPar/
#***

#*** 167m RT; calibrated runs
#WRF_HYDRO_DIR=/scratch/w28/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_10km_t180_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/scratch/w28/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_4km_t180_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/

if [ ! -d "$WRF_HYDRO_DIR/OUTPUT/DAILY_FILES" ] ; then
mkdir "$WRF_HYDRO_DIR/OUTPUT/DAILY_FILES"
fi

#for year in {2013..2017..1}
#for year in 2013 2014 2015
for year in 2018 #2016 #2016 #2016 #2016 #2018
do
for mon in 1 #{1..12..1}
do
for day in 1 #{1..31..1}
do
cp job_concat_template.pbs concat_script.pbs
sed -i 's/year/year='${year}'/g' concat_script.pbs
sed -i 's/mon/mon='${mon}'/g' concat_script.pbs
sed -i 's/day/day='${day}'/g' concat_script.pbs
sed -i 's|WRF_HYDRO_DIR|WRF_HYDRO_DIR='$WRF_HYDRO_DIR'|g' concat_script.pbs
job1=$(qsub concat_script.pbs)
echo $job1
done
done
done
