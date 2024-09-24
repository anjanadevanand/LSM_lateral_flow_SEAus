#!/bin/bash

#directory that contains the routing stack created using ArcGIS
STACK_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/routing_stack/SEA_domain4_4km/hydrosheds_3s_r16_t80_4gauges_maskBasin      #no '/' at the end in order to access the GW params folder

#*******
# default soils
#WPS_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain4_4km_newLUonly_redo/
#WRF_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WRF_domain4_4km_newLUonly/run/
# Default soil data file is placed here
#SCT_DOM_RT_dir=/g/data/w97/ad9701/WRF-Hydro/SEA/routing_stack/SEA_domain4_4km/hydrosheds_3s_r16_t80_4gauges_maskBasin/
#*******

#*******
# TERN top soils
WPS_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain4_4km_newLU_ternsoil/
WRF_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WRF_domain4_4km_newLU_ternsoil/run/
# TERN-top file is placed here
SCT_DOM_RT_dir=/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain4_4km_newLU_ternsoil/
#*******

#*******
# TERN 1m soils
#WPS_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain4_4km_newLU_ternsoil_TOP1m/
#WRF_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WRF_domain4_4km_newLU_ternsoil_TOP1m/run/
# TERN upto 1m file is placed here
#SCT_DOM_RT_dir=/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain4_4km_newLU_ternsoil_TOP1m/
#*******

# with Temp & precip correction
FORCING_DIR=/g/data/w97/ad9701/WRF-Hydro/ERA5Land_regrid/regional/domain4_4km_monPCorr_monTCorr/output_files/

# For PEST Run: the directory which contains the restart files to use
# ******************************************

# ****** RUNS WITHOUT BASEFLOW *******************
# Using DLCD land cover only (default soils) & Precip & Temp monthly correction; default pars
#RESTART_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_defPar/trunk/NDHMS/Run/
#RESTART_DIR_lowLKSATFAC=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_defPar_lowLKSATFAC/trunk/NDHMS/Run/

# Using DLCD land cover only (default soils) & Precip & Temp monthly correction; Kishne pars
#RESTART_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_kishPar/trunk/NDHMS/Run/
#RESTART_DIR_lowLKSATFAC=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_defSoil_kishPar_lowLKSATFAC/trunk/NDHMS/Run/

# Using DLCD land cover only (TERN-1m soils) & Precip & Temp monthly correction; default pars
#RESTART_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_defPar/trunk/NDHMS/Run/
#RESTART_DIR_lowLKSATFAC=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_defPar_lowLKSATFAC/trunk/NDHMS/Run/

# Using DLCD land cover only (TERN-1m soils) & Precip & Temp monthly correction; Kishne pars
#RESTART_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_kishPar/trunk/NDHMS/Run/
#RESTART_DIR_lowLKSATFAC=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern1m_kishPar_lowLKSATFAC/trunk/NDHMS/Run/

# Using DLCD land cover only (TERN-top soils) & Precip & Temp monthly correction; default pars
RESTART_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_defPar/trunk/NDHMS/Run/
RESTART_DIR_lowLKSATFAC=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_defPar_lowLKSATFAC/trunk/NDHMS/Run/

# Using DLCD land cover only (TERN-top soils) & Precip & Temp monthly correction; Kishne pars
#RESTART_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_kishPar/trunk/NDHMS/Run/
#RESTART_DIR_lowLKSATFAC=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/wrf_hydro_nwm_public-5.2.0_domain4_4km_t80_RTCHon_12g_monPnTCorr_tern_kishPar_lowLKSATFAC/trunk/NDHMS/Run/

# ******************************************

# Run with LKSATFAC that varies by topography
#RESTART_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/hydro_test_soil/wrf_hydro_nwm_public-5.2.0_domain4_newLU_defSoil_varyLKSATFAC/trunk/NDHMS/Run/

# link the domain files to the appropriate directory
if [ ! -d "DOMAIN" ] ; then
mkdir "DOMAIN"
fi
cd DOMAIN
ln -sf $STACK_DIR/GEOGRID_LDASOUT_Spatial_Metadata.nc .
ln -sf $STACK_DIR/Fulldom_hires.nc .
ln -sf $SCT_DOM_RT_dir/SCT_DOM_RT.nc .
# link GW basin & param files created using the masked basins in Fulldom_hires
ln -sf ${STACK_DIR}_GW/GWBASINS.nc
ln -sf ${STACK_DIR}_GW/GWBUCKPARM.nc
ln -sf $WPS_DIR/geo_em.d01.nc .
ln -sf $WRF_DIR/wrfinput_d01 . 
ln -sf $RESTART_DIR/OUTPUT/RESTART.2016080100_DOMAIN1 .
ln -sf $RESTART_DIR/HYDRO_RST.2016-08-01_00:00_DOMAIN1 .

###############################################################################
# Uncomment the below if using separate restart files for low LKSATFAC values
###############################################################################
if [ ! -d "Rst_lowLKSATFAC" ] ; then
mkdir "Rst_lowLKSATFAC"
fi
cd Rst_lowLKSATFAC
ln -sf $RESTART_DIR_lowLKSATFAC/OUTPUT/RESTART.2016080100_DOMAIN1 .
ln -sf $RESTART_DIR_lowLKSATFAC/HYDRO_RST.2016-08-01_00:00_DOMAIN1 .
cd ..

cd ..

# link the forcing files
if [ ! -d "FORCING" ] ; then
mkdir "FORCING"
fi
cd FORCING
for year in 2016 #{2013..2018..1}
do
ln -sf $FORCING_DIR/$year* .
done
cd ..
