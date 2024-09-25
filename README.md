### Scripts to perform WRF-Hydro simulations & analyse the impact of lateral flow

#### 0_compile_wrf_hydro_on_gadi/
Notes to compile the WRF-Hydro model on NCI Gadi.  

#### 1_create_forc_files/
NCL scripts and job submission scripts to create forcing files using the ERA-Land dataset to run the WRF-Hydro model. These are based on existing scripts by the WRF-Hydro team for other datasets.  

#### 2_wrf_hydro_calibration/
PPEST control, management, instruction, and template files used to calibrate the WRF-Hydro model over southeast Australia.   
Also bash scripts to set up the parallel PEST run.  

#### 3_sim_namelists_and_calibPars/
Calibrated parameters and namelists used for the simulations.
Also contains the bash and job scripts used to set up the WRF-Hydro runs.

#### 4_postprocess_scripts/
Bash and job scripts used to postprocess the WRF-hydro output files for analyses.

#### 5_analyses_scripts/
Python code used to analyse the results of the simulations and compare simulations with observations.
