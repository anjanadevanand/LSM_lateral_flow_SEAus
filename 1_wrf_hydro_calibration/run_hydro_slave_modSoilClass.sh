#!/bin/bash

module use /g/data/hh5/public/modules
module load intel-compiler/2019.3.199
module load openmpi/4.0.2
module load netcdf/4.7.1
module load conda/analysis3

inputDir=../input/

# copy inputs; excluding the tables supplied by ppest
cp -rf $inputDir/namelist.hrldas .
cp -rf $inputDir/hydro.namelist .
cp -rf $inputDir/namelist.hrldas.lowLKSATFAC .
cp -rf $inputDir/hydro.namelist.lowLKSATFAC .
cp -rf $inputDir/MPTABLE.TBL .
cp -rf $inputDir/SOILPARM.TBL .

# In a PEST run with all parameters, these tables should not be copied. Otherwise these lines would overwrite the tables supplied by PEST.
# Uncomment these lines to Copy these tables only for cases: wrfSEA_3daymean_sensPar.pst wrfSEA_3daymean_sensPar_estim.pst 
#cp -rf $inputDir/HYDRO.TBL .
#cp -rf $inputDir/CHANPARM.TBL .

# if not modifying parameters within Fulldom_hires.nc
# cp -rf ../DOMAIN/Fulldom_hires.nc .

# if modifying any of these pars, use the text file written by PEST to create a modified Fulldom_hires.nc file in the agent's directory
# This python script reads in the original file from the '../DOMAIN/' directory & writes a new file with perturbed params supplied by PEST
python ~/wrf_hydro/create_modified_fulldom_hires_bySoilClass.py

#***********
# if the perturbed LKSATFAC is lower than 150, use restart files from a simulation with LKSATFAC=50 (lowLKSATFAC)
# Find the line immediately after "LKSATFAC"
line_after_lksatfac=$(grep -A1 '^LKSATFAC' Fulldom_hires_bySoilClass.TBL | tail -n 1)
# Remove commas and split the numbers into an array
IFS=', ' read -ra numbers <<< "$line_after_lksatfac"
# Initialize variables
num_6=0
num_7=0
found_6=false
found_7=false
# Loop through the array and find the numbers immediately after 6 and 7
for number in "${numbers[@]}"; do
  if [ "$found_6" = true ]; then
    num_6=$number
    found_6=false
  elif [ "$found_7" = true ]; then
    num_7=$number
    found_7=false
  fi

  if [ $(echo "$number == 6" | bc) -eq 1 ]; then
    found_6=true
  elif [ $(echo "$number == 7" | bc) -eq 1 ]; then
    found_7=true
  fi
done

# Calculate the average of the numbers immediately after 6 and 7 using awk
average=$(awk "BEGIN {print ($num_6 + $num_7) / 2}")
is_low=$(echo "$average < 150" | bc)

if [ "$is_low" -eq 1 ]; then
  mv namelist.hrldas.lowLKSATFAC namelist.hrldas
  mv hydro.namelist.lowLKSATFAC hydro.namelist
else
  rm namelist.hrldas.lowLKSATFAC
  rm hydro.namelist.lowLKSATFAC
fi
#***********

# run wrf hydro
ulimit -s unlimited
mpirun -np $PBS_NCPUS ../wrf_hydro.exe

# calculate mean streamflow over calib period (wrfSEA.pst uses this)
python ~/wrf_hydro/calc_mean_streamflow.py
# calculate also the daily model streamflow in ML (wrfSEA_daily.pst uses this)
python ~/wrf_hydro/calc_model_streamflow_inML.py
# calculate the 3-day mean streamflow in ML (wrfSEA_3daymean.pst uses this)
python ~/wrf_hydro/calc_model_streamflow_3daymean_inML.py

# save the Fulldom_hires.nc files to make sure that the changes to LKSATFAC has actually been made for the run
file_basename="Fulldom_hires"
file_ext=".nc"
index=0
if [ ! -d "allfiles_Fulldom" ] ; then
mkdir "allfiles_Fulldom"
fi
cd allfiles_Fulldom
# Check if the base file exists, if not, create it
if [ ! -e "${file_basename}${file_ext}" ]; then
  cp ../Fulldom_hires.nc .
else
  # If the base file exists, find the next available index and create a new file
  while [ -e "${file_basename}${index}${file_ext}" ]; do
    index=$((index+1))
  done
  cp ../Fulldom_hires.nc ${file_basename}${index}${file_ext}
  cp ../namelist.hrldas namelist.hrldas${index}
  cp ../hydro.namelist hydro.namelist${index}
  cp ../frxst_pts_out.txt frxst_pts_out.txt${index}
fi
cd ..

# clean-up inputs I copied & outputs/files that are not required
rm -f hydro2dtbl.nc
rm -f Fulldom_hires.nc
rm *.LDASOUT_DOMAIN1
rm namelist.hrldas
rm hydro.namelist
rm MPTABLE.TBL
rm SOILPARM.TBL
#rm HYDRO.TBL
#rm CHANPARM.TBL
rm frxst_pts_out.txt
