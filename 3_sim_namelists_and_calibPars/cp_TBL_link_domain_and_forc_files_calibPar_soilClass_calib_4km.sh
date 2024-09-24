#!/bin/bash

#STACK_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/routing_stack/SEA_domain4_4km/hydrosheds_3s_r16_t80_4gauges_maskBasin
STACK_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/routing_stack/SEA_domain4_4km/hydrosheds_3s_r16_t80_12gauges_maskBasin
FORCING_DIR=/g/data/w97/ad9701/WRF-Hydro/ERA5Land_regrid/regional/domain4_4km_monPCorr_monTCorr/output_files/
nml_DIR=/g/data/w28/ad9701/WRF-Hydro/SEA/nml_for_calibParRuns_4km/
# directory to get hydro.namelist from. Select appropriate dir for LSM only or routing on
nml_HYDRO=/g/data/w28/ad9701/WRF-Hydro/SEA/nml_for_calibParRuns_4km/noGW/
#nml_HYDRO=/g/data/w28/ad9701/WRF-Hydro/SEA/nml_for_calibParRuns_4km/routing_off/noGW/

if [ ! -d "DOMAIN" ] ; then
mkdir "DOMAIN"
fi

#****
# Uncomment the appropriate block to link the appropriate files for that case
#***

#1. Default soils
#-------------------
# WPS_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain4_4km_newLUonly_redo/
# WRF_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WRF_domain4_4km_newLUonly/run/
# 1a. Default params
# cp /g/data/w28/ad9701/WRF-Hydro/SEA/SOILPARM.TBL .
# cp /g/data/w28/ad9701/WRF-Hydro/SEA/HYDRO_MODIS.TBL HYDRO.TBL
# cp /g/data/w28/ad9701/WRF-Hydro/SEA/new_CHANPARM.TBL CHANPARM.TBL
# some of these tables would be overwritten by the ones from the calibration directory later
# calib_TBL_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/Calibration/noGW_runs/wrf_hydro_nwm_public-5.2.0_calib2016_0910_newLUonly_PnTCorr_defSoil_defPar/trunk/NDHMS/Run/test1/
 
# 1b. Kishne params
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/SOILPARM.TBL_Kishne_2017 SOILPARM.TBL
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/HYDRO_MODIS.TBL_Kishne_2017 HYDRO.TBL 
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/new_CHANPARM.TBL CHANPARM.TBL
#calib_TBL_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/Calibration/noGW_runs/wrf_hydro_nwm_public-5.2.0_calib2016_0910_newLUonly_PnTCorr_defSoil_kishPar/trunk/NDHMS/Run/test7/

##2. TERN-top soils
##-------------------
#WPS_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain4_4km_newLU_ternsoil/
#WRF_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WRF_domain4_4km_newLU_ternsoil/run/
## 2a. Default params
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/SOILPARM.TBL .
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/HYDRO_MODIS.TBL HYDRO.TBL
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/new_CHANPARM.TBL CHANPARM.TBL
#calib_TBL_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/Calibration/noGW_runs/wrf_hydro_nwm_public-5.2.0_calib2016_0910_newLUonly_PnTCorr_tern_defPar/trunk/NDHMS/Run/test2/

## 2b. Kishne params
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/SOILPARM.TBL_Kishne_2017 SOILPARM.TBL
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/HYDRO_MODIS.TBL_Kishne_2017 HYDRO.TBL 
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/new_CHANPARM.TBL CHANPARM.TBL
#calib_TBL_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/Calibration/noGW_runs/wrf_hydro_nwm_public-5.2.0_calib2016_0910_newLUonly_PnTCorr_tern_kishPar/trunk/NDHMS/Run/test1/

##3. TERN-1m soils
##-------------------
#WPS_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain4_4km_newLU_ternsoil_TOP1m/
#WRF_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WRF_domain4_4km_newLU_ternsoil_TOP1m/run/
## 3a. Default params
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/SOILPARM.TBL .
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/HYDRO_MODIS.TBL HYDRO.TBL
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/new_CHANPARM.TBL CHANPARM.TBL
#calib_TBL_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/Calibration/noGW_runs/wrf_hydro_nwm_public-5.2.0_calib2016_0910_newLUonly_PnTCorr_tern1m_defPar/trunk/NDHMS/Run/test4/

## 3b. Kishne params
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/SOILPARM.TBL_Kishne_2017 SOILPARM.TBL
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/HYDRO_MODIS.TBL_Kishne_2017 HYDRO.TBL 
#cp /g/data/w28/ad9701/WRF-Hydro/SEA/new_CHANPARM.TBL CHANPARM.TBL
#calib_TBL_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/Calibration/noGW_runs/wrf_hydro_nwm_public-5.2.0_calib2016_0910_newLUonly_PnTCorr_tern1m_kishPar/trunk/NDHMS/Run/test1/

# link the domain files to the appropriate directory
cd DOMAIN
ln -sf $STACK_DIR/GEOGRID_LDASOUT_Spatial_Metadata.nc .
#ln -sf $STACK_DIR/Fulldom_hires.nc .
# link GW basin & param files created using the masked basins in Fulldom_hires
ln -sf ${STACK_DIR}_GW/GWBASINS.nc
ln -sf ${STACK_DIR}_GW/GWBUCKPARM.nc
ln -sf $WPS_DIR/geo_em.d01.nc .
ln -sf $WRF_DIR/wrfinput_d01 .
cd ..

cp ${calib_TBL_DIR}/*TBL* .

cp -rf ${nml_DIR}/namelist.hrldas .
cp -rf ${nml_HYDRO}/hydro.namelist .

#*** create the Fulldom_hires.nc file with the calibrated LKSATFAC values by soil type
cd ..
mkdir DOMAIN
cd DOMAIN
ln -sf $STACK_DIR/Fulldom_hires.nc .
ln -sf $WPS_DIR/SCT_DOM_RT.nc .
cd ../Run/
module use /g/data/hh5/public/modules
module load conda/analysis3
python ~/wrf_hydro/create_modified_fulldom_hires_bySoilClass.py
mv Fulldom_hires.nc DOMAIN/
#****

# link the forcing files
if [ ! -d "FORCING" ] ; then
mkdir "FORCING"
fi
cd FORCING
for year in {2013..2018..1}
do
ln -sf $FORCING_DIR/$year* .
done
cd ..

if [ ! -d "OUTPUT" ] ; then
mkdir "OUTPUT"
fi

