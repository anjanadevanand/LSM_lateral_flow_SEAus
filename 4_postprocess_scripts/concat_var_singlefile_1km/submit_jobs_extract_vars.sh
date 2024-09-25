#!/bin/bash

############################################
# Created by Anjana Devanand; 1 Dec 2022
# Used to 
# 1. concatenate hourly data for a single variable from multiple files into one file
# 2. resample hourly data to create daily data by averaging
#*** NOTE
# change year in the loop below to add additional years for runs with longer spin-up
# Modified on 8 Feb 2023
############################################

### *** USER INPUT HERE *** Also change the variables in the for loop below if reqd.

#concat_hrlydata=true
concat_hrlydata=false #T2M

# this would typically be set to true unless an earlier attempt to concatenate succeeded & the daily calculation failed (typically due to running out of memory).
# in that case I would set the above to false to run just the daily calc.

# domain3 runs
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain3_4km_LSMonly/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain3_4km_RTGWon/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WRF-Hydro_test_run/wrf_hydro_nwm_public-5.2.0/trunk/NDHMS/Run/

# LAT run at 4-km
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTon/trunk/NDHMS/Run/

# LAT run at 4-km using RT+CH
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_frxt_mask/trunk/NDHMS/Run/

# CTL run at 4-km
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly/trunk/NDHMS/Run/

#LAT & CTL-4km without precip correction
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTon_noPrecipCorr/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_noPrecipCorr/trunk/NDHMS/Run

#Runs with monPrcp correction
#**** NOTE
# change year in the loop below to add additional years for runs with longer spin-up
#****
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_monPCorr_longSpin/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_LSMonly_monPCorr/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_frxt_mask_4g_newCHPARM_monPCorr/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_frxt_mask_4g_newCHPARM_monPCorr_GW/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_frxt_mask_4g_newCHPARM_monPCorr_longSpin/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTon_monPCorr/trunk/NDHMS/Run/

### **********************
#Final runs using the calibrated parameters

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

#* 1-km
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_12g_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_LSMonly_defSoil_defPar/trunk/NDHMS/Run/

#*** no baseflow
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/output_wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_monPnTCorr_defSoil_defPar/
#WRF_HYDRO_DIR=/scratch/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_167mRT/wrf_hydro_nwm_public-5.2.0_domain4_1km_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/

#for varname in SOIL_M

### **********************

# most of the variables are present in the LDASOUT files
# the variables required from the other files are:
# from .LSMOUT_DOMAIN1, infxsrt sfcheadrt
# from .RTOUT_DOMAIN1, QSTRMVOLRT zwattablrt sfcheadsubrt
# from .GWOUT_DOMAIN1, inflow, outflow, depth

# too much coding, just select the variables manually
# varnames="LH HFX ZWT WA WT LAI GPP RAINRATE ECAN EDIR ETRAN UGDRNOFF SOIL_M infxsrt sfcheadrt QSTRMVOLRT zwattablrt sfcheadsubrt"

# accumulated variables: resampling to daily data not required
# for varname in SFCRNOFF UGDRNOFF ACCPRCP ACCET
# for varname in LH HFX ZWT WA WT LAI GPP RAINRATE ECAN EDIR ETRAN SOIL_M inflow outflow depth
# for varname in QSTRMVOLRT zwattablrt sfcheadsubrt


myArray=("/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_LSMonly_defSoil_defPar/trunk/NDHMS/Run/" \
"/g/data/w28/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km_100mRT/output_wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t500_RTCHon_monPnTCorr_defSoil_defPar/" \
"/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_1km/wrf_hydro_nwm_public-5.2.0_domain4_1km_monPnTCorr_t80_RTCHon_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/")

for WRF_HYDRO_DIR in ${myArray[@]}; do

#****** Variables ******
# RT variables
# QSTRMVOLRT channel inflow (mm)
# sfcheadsubrt surface head (mm)
# zwattablrt depth to saturation, rounded to highest saturated layer (m)

# LDASOUT variables
# SOIL_M "volumetric soil moisture, the dimensionless ratio of water volume (m3) to soil volume (m3)"  (m3 m-3)

#*****
# variables from an RT run
#for varname in UGDRNOFF ACCPRCP ACCET LH HFX ZWT WA WT LAI GPP RAINRATE ECAN EDIR ETRAN #SOIL_M #inflow outflow depth #QSTRMVOLRT zwattablrt sfcheadsubrt #infxsrt sfcheadrt 

#for varname in SOIL_M
#for varname in UGDRNOFF ACCPRCP ACCET LH HFX ZWT WA WT LAI GPP RAINRATE ECAN EDIR ETRAN

# typically not run because the jobs run of memory trying to concat these variables
#for varname in QSTRMVOLRT zwattablrt sfcheadsubrt
#*****

#****
# variables from an RT+CH run. Additional variables: elevation streamflow, from the CHRTOUT files
#for varname in UGDRNOFF ACCPRCP ACCET LH HFX ZWT WA WT LAI GPP RAINRATE ECAN EDIR ETRAN SOIL_M SWFORC LWFORC SAV FSA FIRA IRC IRG GRDFLX ALBEDO
#for varname in inflow outflow depth
#for varname in SOIL_M
#for varname in UGDRNOFF
#for varname in streamflow
#for varname in QSTRMVOLRT zwattablrt sfcheadsubrt

#*****
# variables from an LSMonly run
#for varname in SFCRNOFF UGDRNOFF ACCPRCP ACCET LH HFX ZWT WA WT LAI GPP RAINRATE ECAN EDIR ETRAN SOIL_M SWFORC LWFORC SAV FSA FIRA IRC IRG GRDFLX ALBEDO
#for varname in LH 
#for varname in SOIL_M
#*****

for varname in T2M #T2MV T2MB
do

# the routing variables are on a very fine grid (100-250 m), so their sizes are too big to load and resample to daily data; so I can use the script to concat data; but cant calc daily means
# resampling to daily data is not required for the accumulated variables

if [ "$varname" = QSTRMVOLRT ] || [ "$varname" = zwattablrt ] || [ "$varname" = sfcheadsubrt ] || [ "$varname" = infxsrt ] || [ "$varname" = SFCRNOFF ] || [ "$varname" = UGDRNOFF ] || [ "$varname" = ACCPRCP ] || [ "$varname" = ACCET ] || [ "$varname" = T2MV ] || [ "$varname" = T2MB ] || [ "$varname" = T2M ]; then
calc_daily=false
else
calc_daily=true
fi

if [ "$varname" = T2M ]; then
calc_dailymax=true
else
calc_dailymax=false
fi

if [ "$concat_hrlydata" = true ] ; then
if [ "$varname" = infxsrt ] || [ "$varname" = sfcheadrt ] ; then
file_suffix=.LSMOUT_DOMAIN1
elif [ "$varname" = QSTRMVOLRT ] || [ "$varname" = zwattablrt ] || [ "$varname" = sfcheadsubrt ] ; then
file_suffix=.RTOUT_DOMAIN1
elif [ "$varname" = inflow ] || [ "$varname" = outflow ] || [ "$varname" = depth ] ; then
file_suffix=.GWOUT_DOMAIN1
elif [ "$varname" = elevation ] || [ "$varname" = streamflow ] ; then
file_suffix=.CHRTOUT_DOMAIN1
else
file_suffix=.LDASOUT_DOMAIN1
fi

# the RTOUT variables generally run out of memory, even for a highmem job so omit them
if [ "$varname" = QSTRMVOLRT ] || [ "$varname" = zwattablrt ] || [ "$varname" = sfcheadsubrt ] || [ "$varname" = SOIL_M ] || [ "$varname" = elevation ] || [ "$varname" = streamflow ] ; then
for year in {2013..2017..1}
do
cp job_extract_template_highmem.pbs extract_script.pbs
sed -i 's|year_sel|year='$year'|g' extract_script.pbs
sed -i 's|WRF_HYDRO_DIR|WRF_HYDRO_DIR='$WRF_HYDRO_DIR'|g' extract_script.pbs
sed -i 's|varname|varname='$varname'|g' extract_script.pbs
sed -i 's|file_suffix|file_suffix='$file_suffix'|g' extract_script.pbs
if [ "$year" = 2013 ]; then job1=$job1; fi
job_temp=$(qsub extract_script.pbs)
echo $job_temp
if [ "$year" = 2013 ]; then
job1=$job_temp
else
job1=$job1:$job_temp
fi
done
else
cp job_extract_template_larger.pbs extract_script.pbs
sed -i 's|WRF_HYDRO_DIR|WRF_HYDRO_DIR='$WRF_HYDRO_DIR'|g' extract_script.pbs
sed -i 's|varname|varname='$varname'|g' extract_script.pbs
sed -i 's|file_suffix|file_suffix='$file_suffix'|g' extract_script.pbs
job1=$(qsub extract_script.pbs)
echo $job1
fi
fi

if [ "$calc_daily" = true ] ; then
if [ "$varname" = SOIL_M ] || [ "$varname" = elevation ] || [ "$varname" = streamflow ] ; then
#cp job_calc_daily_template_vhighmem.pbs daily_script.pbs
for year in {2013..2017..1}
do
cp job_calc_daily_template_srmem_byyear.pbs daily_script.pbs
sed -i 's|WRF_HYDRO_DIR|WRF_HYDRO_DIR='$WRF_HYDRO_DIR'|g' daily_script.pbs
sed -i 's|varname|varname='$varname'|g' daily_script.pbs
sed -i 's|year=XXXX|year='$year'|g' daily_script.pbs
if [ "$concat_hrlydata" = true ] ; then
job2=$(qsub -W depend=afterok:$job1 daily_script.pbs)
else
job2=$(qsub daily_script.pbs)
fi
echo $job2
done
else
cp job_calc_daily_template_srmem.pbs daily_script.pbs
sed -i 's|WRF_HYDRO_DIR|WRF_HYDRO_DIR='$WRF_HYDRO_DIR'|g' daily_script.pbs
sed -i 's|varname|varname='$varname'|g' daily_script.pbs
if [ "$concat_hrlydata" = true ] ; then
job2=$(qsub -W depend=afterok:$job1 daily_script.pbs)
else
job2=$(qsub daily_script.pbs)
fi
echo $job2
fi
fi

if [ "$calc_dailymax" = true ] ; then
cp job_calc_dailymax_template_srmem.pbs dailymax_script.pbs
sed -i 's|WRF_HYDRO_DIR|WRF_HYDRO_DIR='$WRF_HYDRO_DIR'|g' dailymax_script.pbs
sed -i 's|varname|varname='$varname'|g' dailymax_script.pbs
if [ "$concat_hrlydata" = true ] ; then
job2=$(qsub -W depend=afterok:$job1 dailymax_script.pbs)
else
job2=$(qsub dailymax_script.pbs)
fi
echo $job2
fi

done

done
