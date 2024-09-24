#!/bin/bash

STACK_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/routing_stack/SEA_domain4_10km/hydrosheds_3s_r40_t80_4gauges_maskBasin      #no '/' at the end in order to access the GW params folder

#*******
# default soils
WPS_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain4_10km_newLUonly/
WRF_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/WRF_domain4_10km_newLUonly/run/
SCT_DOM_RT_dir=/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain4_10km_newLUonly/
#*******

#**** OLD ONE ****
FORCING_DIR=/g/data/w97/ad9701/WRF-Hydro/ERA5Land_regrid/regional/domain4_10km_monPCorr_monTCorr/output_files/

# ****** RUNS WITHOUT BASEFLOW *******************
# Using DLCD land cover only (default soils) & Precip & Temp monthly correction; default pars
RESTART_DIR=/g/data/w97/ad9701/WRF-Hydro/SEA/noGW_runs/runs_wCalibPars_10km/wrf_hydro_nwm_public-5.2.0_domain4_10km_monPnTCorr_t80_RTCHon_defSoil_defPar/trunk/NDHMS/Run/

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
