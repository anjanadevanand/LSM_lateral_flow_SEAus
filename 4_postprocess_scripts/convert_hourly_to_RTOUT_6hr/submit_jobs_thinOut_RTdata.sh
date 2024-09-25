#!/bin/bash

#*** Final runs using calibrated parameters ***
#*** 4km ***
#****| complete  |** WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_ternSoil_kPar/trunk/NDHMS/Run/
#****| complete  |** WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_defSoil_defPar/trunk/NDHMS/Run/
#****| complete  |** WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_defSoil_kPar/trunk/NDHMS/Run/
#****| complete  |** WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_noCalib_defSoil_defPar/trunk/NDHMS/Run/
#****| complete  |** WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_12g_ternSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_defSoil_kPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_noCalib_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_ternSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_ternSoil_kPar/trunk/NDHMS/Run/

#*** 1km ***
#****| complete  |** WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_12g_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_LSMonly_defSoil_defPar/trunk/NDHMS/Run/

#*** No Baseflow runs ***
#*** 4km; using default paremeters *** I haven't output RT data for these runs
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_kishPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_kishPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_kishPar/trunk/NDHMS/Run/

#*** 4km; calibrated runs
#I have deleted RT output except for the defSoil_defPar run that is used in the paper.
WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/

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
#***

#*** 10km & 100mRT
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km_100mRT/wrf_hydro_nwm_public-5.2.0_trial2/trunk/NDHMS/Run/

#*** 10km calibrated at the same resolution
#**** already moved to mdss and deleted TAR files ***
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wNewCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_t80_RTCHon_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wNewCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/

#*** 1km; calibrated runs
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/
#***| complete |** WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/

#*** 1km & 100m RT; calibrated runs
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#re-did 2016-03-16 
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_defSoil_defPar_201603_rerun/trunk/NDHMS/Run/
#2017-08 to the end
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_monPnTCorr_defSoil_defPar_201708_toEnd/trunk/NDHMS/Run/
# concatenated all outputs here
##***| complete except 2015-10 (in prog.)|** WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/output_wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_monPnTCorr_defSoil_defPar/
#***

#*** 167m RT; calibrated runs **
# I finally output 6hrly data for the 10km & 4km simulations! (except for the first day)
#WRF_HYDRO_DIR=/scratch/w28/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_10km_t180_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/scratch/w28/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_4km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_4km_t180_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/

if [ ! -d "$WRF_HYDRO_DIR/OUTPUT/DAILY_FILES/RTOUT_6hr" ] ; then
mkdir "$WRF_HYDRO_DIR/OUTPUT/DAILY_FILES/RTOUT_6hr"
fi

for year in {2013..2017}
do
for mon in {1..12..1}
do
cp job_convert_template.pbs convert_script.pbs
sed -i 's/year/year='${year}'/g' convert_script.pbs
sed -i 's/mon/mon='${mon}'/g' convert_script.pbs
sed -i 's|WRF_HYDRO_DIR|WRF_HYDRO_DIR='$WRF_HYDRO_DIR'|g' convert_script.pbs
job1=$(qsub convert_script.pbs)
echo $job1
done
done
