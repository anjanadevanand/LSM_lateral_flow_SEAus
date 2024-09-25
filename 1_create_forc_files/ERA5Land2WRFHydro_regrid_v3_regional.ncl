;----------------------------------------------------------------------
; Name    : ERA5Land2WRFHydro_regrid.ncl
;
; Purpose : This is an NCL script that uses ESMF utilities to perform regridding of various 
;           data fields to a WRF-Hydro domain.
;
;           Note that before running this script you will need to run the 
;           ERA5Land2WRFHydro_generate_weights.ncl script to generate the required weight
;           file(s) for your chosen regridding option(s). 
;
;           Important notes:
;           1) This script assumes that the source files are provided at an hourly interval.
;              This is true for the current generation of ERA5Land forcing data and is an assumption made
;              to compute the rainrate variable in output files.          
;           2) This script is currently configured to use the bilinear interpolation option for all forcing 
;              fields.  Should the user desire to use a different interpolation option, the name for the
;              corresponding weight file should be added to user settings and the weight files for each 
;              variable adjusted appropriately.
;           4) ERA5Land accum_prcp is hourly precipitation amount. No need for zero'ing it out
;              at the begining of the time period.
;           5) By default the domain number for the output filename is set to 1.  This can be changed in the 
;              user settings section of this script.
;
;
; Example Usage   : ncl 'srcFileName="2016/*era5-land_oper_sfc_20160101-20160131.nc"' 'dstGridName="/g/data/w97/ad9701/WRF-Hydro/SEA/WPS_domain3_4km/geo_em.d01.nc"' ERA5Land2WRFHydro_regrid.ncl
;
;           srcFileName = filename pattern of the souce ERA5Land files.
;                         e.g., "2016/*era5-land_oper_sfc_20160101-20160131.nc", "2016/era5-land_oper_sfc_2016*.nc" , ...
;           dstGridName = name of file that contains the destination (WRF-Hydro) grid
; 
; Anjana Devanand created on 24 Nov 2022
; Last modified: 18 Apr 2023
;
;----------------------------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

begin

;----------------------------------------------------------------------
; User settings
;----------------------------------------------------------------------

  ;---------------------------------------------------------------;
  ; Set the domain number to agree with the geogrid file and      ;
  ; the IGRID option in the hydro.namelist for WRF-Hydro          ;
  ;---------------------------------------------------------------;
  domain  = "DOMAIN1"

  ;---------------------------------------------------------------;
  ; Set input and output file directories.                        ;
  ;---------------------------------------------------------------;
  dirm    = "/g/data/zz93/era5-land/reanalysis/"       ; directory where source forcing data resides
  outdir  = "./output_files/"      ; directory where regridded forcing data will be placed. set to dirm for overwriting the original file

  ;---------------------------------------------------------------;
  ; Apply a ratio based correction to match AGCD precip data?
  ;---------------------------------------------------------------;
  apply_annual_precip_corr = False
  apply_monthly_precip_corr = True
  apply_monthly_temp_corr = True

  ;---------------------------------------------------------------;
  ; Set a variable to indicate the timestep of source data        ;
  ;---------------------------------------------------------------;
  dt=3600.0   ; time over which precipitation is accumulated in the source dataset in units of seconds (currently set for ERA5Land2 forcing)

  ;---------------------------------------------------------------;
  ; Weight filenames for regridding                               ;
  ;---------------------------------------------------------------;
  ;wgtFileName_conserve = "./ERA5Land2WRFHydro_weight_conserve.nc"
  wgtFileName_bilinear = "./ERA5Land2WRFHydro_weight_bilinear.nc"
  wgtFileName_bilinear_agcd = "./AGCD2WRFHydro_weight_bilinear.nc"
  
  ;----------------------------------------------------------------------;
  ; Create lists to store variable names from the source file to be
  ; regridded and the corresponding output variable names ;
  ;----------------------------------------------------------------------;
  
  ; specific humidity is calculated as https://confluence.ecmwf.int/pages/viewpage.action?pageId=171411214

  list_var_in = (/"sp", "t2m", "u10", "v10", "calc_hus2m", "tp", "ssrd", "strd"/)
  list_var_out = (/"PSFC", "T2D", "U2D", "V2D", "Q2D", "RAINRATE", "SWDOWN", "LWDOWN"/)
  list_filedir = (/"sp/", "2t/", "u10/", "v10/", " ", "tp/", "ssrd/", "strd/"/)
  ; appropriate constant values to replace missing values with
  list_constant = (/100000, 290, 1, 1, 0.01, 0, 350, 400/)

  ;list_var_in = (/"strd"/)
  ;list_var_out = (/"LWDOWN"/)
  ;list_filedir = (/"strd/"/)
  ; appropriate constant values to replace missing values with
  ;list_constant = (/400/)

  ; the length to be used when splitting the string to get the date-time string. This changes by variable
  ; list_str_prefix_len = (/33, 34, 32, 32, 33, 35, 36, 36/) 
  ; list_str_prefix_len = (/33, 34, 32, 32, 36, 36/)

;----------------------------------------------------------------------
; read in source and destination files
;----------------------------------------------------------------------

  if ( .not.isfilepresent( dstGridName ) ) then
     print( " ... source grid file not found : "+ dstGridName )
     exit
  end if

;---  destination grid data
  dstfile     = addfile( dstGridName ,"r")
  dlon2d=dstfile->XLONG_M(0,:,:)
  dlat2d=dstfile->XLAT_M(0,:,:)
  dims=dimsizes(dlat2d)

  flag=0    ; flag for removing accum precip... (should be set to 0 for ERA5Land2 forcing data)

;--- read in dominant LU and get surface roughness to calculate U2m/V2m from U10m/V10m
  LUINDEX = dstfile->LU_INDEX(0,:,:)
  
  ; function to get surface roughness from LUINDEX
  function get_surf_roughness(LU)
  local LU1, LU2, LU3, LU4, LU5, LU6, LU7, LU8, LU9, LU10, LU11, LU12, LU13, LU14, LU15, LU16, LU17, LU18, LU19, LU20, Z0M
  begin
  ; case statement to assign Z0M values based on modis 20-class LU information in MPTABLE.TBL
  ; https://ral.ucar.edu/sites/default/files/public/product-tool/noah-multiparameterization-land-surface-model-noah-mp-lsm/MPTABLE.TBL_.txt
  LU1 = where(LU.eq.1, 1.09, 0)
  LU2 = where(LU.eq.2, 1.1, 0)
  LU3 = where(LU.eq.3, 0.85, 0)
  LU4 = where(LU.eq.4, 0.8, 0)
  LU5 = where(LU.eq.5, 0.8, 0)
  LU6 = where(LU.eq.6, 0.2, 0)
  LU7 = where(LU.eq.7, 0.06, 0)
  LU8 = where(LU.eq.8, 0.6, 0)
  LU9 = where(LU.eq.9, 0.5, 0)
  LU10 = where(LU.eq.10, 0.12, 0)
  LU11 = where(LU.eq.11, 0.3, 0)
  LU12 = where(LU.eq.12, 0.15, 0)
  LU13 = where(LU.eq.13, 1.0, 0)
  LU14 = where(LU.eq.14, 0.14, 0)
  LU15 = where(LU.eq.15, 0.01, 0)
  LU16 = where(LU.eq.16, 0.01, 0)
  LU17 = where(LU.eq.17, 0.01, 0)
  LU18 = where(LU.eq.18, 0.3, 0)
  LU19 = where(LU.eq.19, 0.2, 0)
  LU20 = where(LU.eq.20, 0.03, 0)
  Z0M = LU1 + LU2 + LU3 + LU4 + LU5 + LU6 + LU7 + LU8 + LU9 + LU10 + LU11 + LU12 + LU13 + LU14 + LU15 + LU16 + LU17 + LU18 + LU19 + LU20
  copy_VarCoords(LU, Z0M)
  return(Z0M)
  end
  surf_roughness = get_surf_roughness(LUINDEX)

  ; calculate numerator & denominator for the logarithmic wind profile
  z1 = conform_dims(dimsizes(surf_roughness), 10, -1)
  z2 = conform_dims(dimsizes(surf_roughness), 2, -1)
  numerator = log(z2/surf_roughness)
  denominator = log(z1/surf_roughness)

;----------------------------------------------------------------------
; Open source data files to be regridded...
;----------------------------------------------------------------------
  if(.not. isfilepresent(outdir)) then
     system("mkdir "+outdir)
  end if

num_var = dimsizes(list_var_in)

do v = 0,num_var-1,1   ; loop through variables
  
  var_in = list_var_in(v)
  var_out = list_var_out(v)
  filedir = list_filedir(v)
  var_const = list_constant(v)
  ;str_prefix_len = list_str_prefix_len(v)

  if (var_in.eq."calc_hus2m") then
     Rdry=287.0597
     Rvap=461.5250
     a1=611.21
     a3=17.502
     a4=32.19
     T0=273.16
     datfils_td = systemfunc ("ls "+dirm+"2d/"+srcFileName)    ; list of file names containing dew point temperature
     datfils_sp = systemfunc ("ls "+dirm+"sp/"+srcFileName)    ; list of file names containing surface pressure
     num_datfils = dimsizes(datfils_sp)
  else
     datfils = systemfunc ("ls "+dirm+filedir+srcFileName)    ; list of file names
     num_datfils     = dimsizes(datfils)
  end if

  do ifil = 0,num_datfils-1,1   ; loop through datafiles one at a time

       wgtFileName = wgtFileName_bilinear

       ;---Options to pass to ESMF_regrid--------------------;
       opt                = True
       opt@WgtFileName    = wgtFileName
       opt@CopyVarAtts    = True
       opt@CopyVarCoords  = False

       ;---Debug information
       opt@PrintTimings   = True
       opt@Debug          = True
       ;-----------------------------------------------------;
       exist = isfilepresent( wgtFileName )
       if ( .not.exist ) then
          print( " ... no weight file. Run ERA5Land2WRFHydro_generate_weights.ncl first to generate: "+" "+wgtFileName )
          exit
       end if

       ;---Options to regrid the AGCD data used to correct the annual precip---------;
       opt2                = True
       opt2@WgtFileName    = wgtFileName_bilinear_agcd
       opt2@CopyVarAtts    = True
       opt2@CopyVarCoords  = False

       ;---Debug information
       opt2@PrintTimings   = True
       opt2@Debug          = True
       ;-----------------------------------------------------;
       exist2 = isfilepresent( wgtFileName_bilinear_agcd )
       if ( .not.exist2 ) then
          print( " ... no weight file. Run AGCD2WRFHydro_generate_weights.ncl first to generate: "+" "+wgtFileName_bilinear_agcd )
          exit
       end if

      if (var_in.eq."calc_hus2m") then   ; specific humidity has to be calculated
         print( " ... Calculating specific humidity from td and sp" )
         datfile_td = addfile( datfils_td(ifil), "r")
         datfile_sp = addfile( datfils_sp(ifil), "r")
         if (getfilevartypes (datfile_td,"d2m").eq."short") then
            td  = short2flt( datfile_td->d2m(:,{-10:-44},{112:154}) )
         else
            td  = datfile_td->d2m(:,{-10:-44},{112:154})
         end if
         if (getfilevartypes (datfile_sp,"sp").eq."short") then
            sp  = short2flt( datfile_sp->sp(:,{-10:-44},{112:154}) )
         else
            sp  = datfile_sp->sp(:,{-10:-44},{112:154})
         end if
         if (ifil.eq.0) then
            td_orig = td                                   ; saved the original data here
            delete(td)
            td = td_orig(1::,:,:)
            
            sp_orig = sp                                   ; saved the original data here
            delete(sp)
            sp = sp_orig(1::,:,:)
         end if
         ;----------------------------------------------------------------------------------
         ; I tried to calculate specific humidity using data on the ERA5-Land grid
         ; It shows divide by zero errors
         ; the data is too big to debug, so I'm switching to calculating after regridding
         ;----------------------------------------------------------------------------------
         var_dims = dimsizes(td)
         ntimes = var_dims(0)     ; for ERA5Land, files are organised by month. No of timesteps = 24 * days-in-month
         
         v4_td = new((/ntimes(0), dims(0), dims(1)/),"double")
         v4_td = ESMF_regrid_with_weights( td , wgtFileName, opt)
         v4_sp = new((/ntimes(0), dims(0), dims(1)/),"double")
         v4_sp = ESMF_regrid_with_weights( sp , wgtFileName, opt)

         ;Calculation of E saturation water vapour from Teten's formula
         E=a1*exp(a3*(v4_td-T0)/(v4_td-a4))
         ;Calculation of saturation specific humidity at 2m qsat  (equal to huss)
         v4=(Rdry/Rvap)*E/(v4_sp-((1-Rdry/Rvap)*E))
         v4@long_name = "Q2D"
         v4@description = "2-m Specific humidity calculated from dew point and surf. pres."
         v4@units = "kg/kg"
         
         ; assigning this in case I need to use the metadata from var later
         var = td
         var2d=var
         delete([/td, sp, v4_td, v4_sp, E/])
      else                               ; other variables can be read in
         print( " ... Processing input file : "+ datfils(ifil) )

         datfile = addfile( datfils(ifil), "r")
         if (getfilevartypes (datfile,var_in).eq."short") then
            var  = short2flt( datfile->$var_in$(:,{-10:-44},{112:154}) )
         else
            var = datfile->$var_in$(:,{-10:-44},{112:154})
         end if

         var_dims = dimsizes(var)
         ntimes = var_dims(0)  ; for ERA5Land, files are organised by month. No of timesteps = 24 * days-in-month

         ; Convert accumulated variables to instantaneous rates: precip, sw & lw
         if (var_in.eq."ssrd".or.var_in.eq."strd".or.var_in.eq."tp") then
            ; For the first file, leave out the first time step because the prior timestep is not available to calculate the difference
            ; as the first time step corresponds to the 00 hr - it is the 24hr accumulation of the previous day. 
            if (ifil.eq.0) then
              var_orig = var                                   ; saved the original data here
              delete(var)
              if (var_in.eq."tp") then
                 var_diff_inst_rate = (var_orig(1::,:,:) - var_orig(0:(ntimes-2),:,:))/3600*1000
                 var_orig_inst_rate = var_orig(1::,:,:)/3600*1000
              else
                 var_diff_inst_rate = (var_orig(1::,:,:) - var_orig(0:(ntimes-2),:,:))/3600
                 var_orig_inst_rate = var_orig(1::,:,:)/3600
              end if
              var_forCoords = var_orig(1::,:,:)
              time=var_orig&time(1::)
           else  ; this is not the first file. Get 23hr data from the previous file to calculate difference
             delete(var)
             two_datfiles = addfiles( datfils(ifil-1:ifil), "r")
             if (getfilevartypes (two_datfiles[0],var_in).eq."short") then
                var_orig  = short2flt( two_datfiles[:]->$var_in$(:,{-10:-44},{112:154}) )
             else
                var_orig = two_datfiles[:]->$var_in$(:,{-10:-44},{112:154})
             end if

             var_dims_2files = dimsizes(var_orig)                          
             ntimes_2files = var_dims_2files(0)
             if (var_in.eq."tp") then
                 var_diff_inst_rate = (var_orig((ntimes_2files-ntimes)::,:,:) - var_orig((ntimes_2files-ntimes-1):(ntimes_2files-2),:,:))/3600*1000
                 var_orig_inst_rate = var_orig((ntimes_2files-ntimes)::,:,:)/3600*1000
             else
                 var_diff_inst_rate = (var_orig((ntimes_2files-ntimes)::,:,:) - var_orig((ntimes_2files-ntimes-1):(ntimes_2files-2),:,:))/3600
                 var_orig_inst_rate = var_orig((ntimes_2files-ntimes)::,:,:)/3600
             end if
             var_forCoords = var_orig((ntimes_2files-ntimes)::,:,:)
             time=var_orig&time((ntimes_2files-ntimes)::)
             ;delete([/
           end if  ; end ifil
          
           ; When time = YYYY-MM-DD:01:mm:ss, the instantaneous rate should be taken from var_orig_inst_rate; because 01 hr is the first time step of accum 
           ; For all other hours in the day, the instantaneous rate should be taken from var_diff_inst_rate. 
           ; get the subdaily hour in a 1D array
           str_hour_arr=cd_string(time,"%H")
           int_hour_arr = toint(str_hour_arr)
           ; NCL does not allow me use the above 1D array to identify hours. To use it, it has to have the same dim as the 3D array
           ; convert 1-D hour array to 3-D
           int_hour_3d = conform_dims(dimsizes(var_diff_inst_rate), int_hour_arr, 0)
           ; Now get the indices of the timesteps corresponding to 01 hr
           int_hour_3d_1D = ndtooned(int_hour_3d)
           ind_1hr = ind(int_hour_3d_1D.eq.1)

           var_1D = ndtooned(var_diff_inst_rate)                  ; save the rates calc. from difference
           var_orig_inst_rate_1D = ndtooned(var_orig_inst_rate)
           var_1D(ind_1hr) = (/ var_orig_inst_rate_1D(ind_1hr) /) ; during 01 hrs, use the original instantaneous rates
           var = onedtond(var_1D, dimsizes(var_diff_inst_rate))

           copy_VarCoords(var_forCoords,var)

           if (var_in.eq."tp") then
              var@long_name = "RAINRATE"
              var@description = "RAINRATE"
              var@units       = "mm s^-1"
           else
              var@long_name = var_orig@long_name
              var@units       = "W m^-2"
           end if 
           delete([/var_orig,var_diff_inst_rate,var_orig_inst_rate,var_forCoords,str_hour_arr,int_hour_arr,int_hour_3d,int_hour_3d_1D,ind_1hr,var_1D/])
           delete([/var_orig_inst_rate_1D/])       

         else if (ifil.eq.0) then   
            var_orig = var                                   ; saved the original data here
            delete(var)
            var = var_orig(1::,:,:)
         end if  ; end ifil check
         end if  ; end accumulated variables
        
         ; the size of the time dimension of var may be shorter now
         delete([/var_dims, ntimes/])

         var_dims = dimsizes(var)
         ntimes = var_dims(0)
 
         ;----------------------------------------------------------------------
         ; Define new array and perform regriddding
         ;----------------------------------------------------------------------
         v4 = new((/ntimes(0), dims(0), dims(1)/),"double") 
         var2d = var
         v4 = ESMF_regrid_with_weights( var2d , wgtFileName, opt)
         ;printVarSummary(v4)

         ;-----------------------------------------------------------------------
         ; Correcting ERA5Land precipitation data to match AGCD annual data
         ; Comment the below block if correction is not required
         ;-----------------------------------------------------------------------
         if (var_in.eq."tp") then
            if (apply_annual_precip_corr .or. apply_monthly_precip_corr) then
               if (apply_annual_precip_corr) then
                  ; code to adjust the rate such that the annual ERA5Land total matches the AGCD total at the grid cell
                  ; read ann_era5land file & data for the selected year
                  ; read ann_agcd file & data for the selected year
                  str_year_arr=cd_string(time,"%Y")
                  str_time_identifier=str_year_arr(0)
                  delete(str_year_arr)
               else if (apply_monthly_precip_corr) then
                  ; same code but to read in monthly total data
                  str_year_mon_arr=cd_string(time,"%Y%N")
                  str_time_identifier=str_year_mon_arr(0)
                  delete(str_year_mon_arr)
               end if
               end if
               ; read in the precip datasets for correction 
               file_tp_elnd = addfile("/g/data/w97/ad9701/WRF-Hydro/ERA5Land_regrid/precip_forCorr/era5-land_" + str_time_identifier + ".nc", "r")
               file_tp_agcd = addfile("/g/data/w97/ad9701/WRF-Hydro/ERA5Land_regrid/precip_forCorr/agcd_" + str_time_identifier + ".nc", "r")
               tp_elnd = dble2flt( file_tp_elnd->tp )
               tp_agcd = dble2flt( file_tp_agcd->tp )

               ; regrid total precip datasets to the domain grid
               tp_elnd_reg = ESMF_regrid_with_weights( tp_elnd , wgtFileName, opt)
               tp_agcd_reg = ESMF_regrid_with_weights( tp_agcd , wgtFileName_bilinear_agcd, opt2) 
               
               ; calculate ratio AGCD/ERA5Land Annual Precip
               ratio_orig = tp_agcd_reg/tp_elnd_reg
               ratio = where(ismissing(ratio_orig),1.,ratio_orig)
               ;printVarSummary(ratio)           
    
               ; multiply the rain rate with ratio
               v4_orig = v4
               delete(v4)
               ;printVarSummary(v4_orig)
               ratio_3d = conform_dims(dimsizes(v4_orig), ratio, (/1,2/))
               ;printVarSummary(ratio_3d)
               v4 = v4_orig*ratio_3d
               copy_VarMeta(v4_orig,v4)
               delete(v4_orig)
 
               ; write the ratio to file to check if it makes sense
               file_ratio = "RAINRATE_corr_ratio_" + str_time_identifier + ".nc"
               if ( .not.isfilepresent( file_ratio ) ) then
                  ratio!0 = "south_north"
                  ratio!1 = "west_east"
                  ncdf_r=addfile(file_ratio, "c")
                  ncdf_r->lat = dlat2d   ;output lat
                  ncdf_r->lon = dlon2d   ;output lon
                  ncdf_r->ratio = ratio
                  ncdf_r->ratio_orig = ratio_orig
                  ;ncdf_r->elnd = ann_tp_elnd_reg
                  ;ncdf_r->agcd = ann_tp_agcd_reg
               end if
               delete([/ratio_3d, ratio_orig, ratio/])
            end if  ; precip correction yes/no
         end if  ; is the variable precip

         if (var_in.eq."t2m") then
            if (apply_monthly_temp_corr) then
               ; same code but to read in monthly total data
               time=var&time(1::)
               str_year_mon_arr=cd_string(time,"%Y%N")
               str_time_identifier=str_year_mon_arr(0)
               delete(str_year_mon_arr)
               delete(time)
         
             ; read in the datasets for correction 
             file_t2m_elnd = addfile("/g/data/w97/ad9701/WRF-Hydro/ERA5Land_regrid/temp_forCorr/era5-land_" + str_time_identifier + ".nc", "r")
             file_t2m_agcd = addfile("/g/data/w97/ad9701/WRF-Hydro/ERA5Land_regrid/temp_forCorr/agcd_" + str_time_identifier + ".nc", "r")
             t2m_elnd = dble2flt( file_t2m_elnd->t2m )
             t2m_agcd = dble2flt( file_t2m_agcd->t2m )

             ; regrid total datasets to the domain grid
             t2m_elnd_reg = ESMF_regrid_with_weights( t2m_elnd , wgtFileName, opt)
             t2m_agcd_reg = ESMF_regrid_with_weights( t2m_agcd , wgtFileName_bilinear_agcd, opt2)

             ; calculate ratio AGCD/ERA5Land temperature
             ratio_orig = t2m_agcd_reg/t2m_elnd_reg
             ratio = where(ismissing(ratio_orig),1.,ratio_orig)
             ;printVarSummary(ratio)           

             ; multiply the temperature with ratio
             v4_orig = v4
             delete(v4)
             ;printVarSummary(v4_orig)
             ratio_3d = conform_dims(dimsizes(v4_orig), ratio, (/1,2/))
             ;printVarSummary(ratio_3d)
             v4 = v4_orig*ratio_3d
             copy_VarMeta(v4_orig,v4)
             delete(v4_orig)

             ; write the ratio to file to check if it makes sense
             file_ratio = "TEMP_corr_ratio_" + str_time_identifier + ".nc"
             if ( .not.isfilepresent( file_ratio ) ) then
                ratio!0 = "south_north"
                ratio!1 = "west_east"
                ncdf_r=addfile(file_ratio, "c")
                ncdf_r->lat = dlat2d   ;output lat
                ncdf_r->lon = dlon2d   ;output lon
                ncdf_r->ratio = ratio
                ncdf_r->ratio_orig = ratio_orig
             end if
             delete([/ratio_3d, ratio_orig, ratio/])
          end if  ; correction yes/no
         end if  ; is the variable temperature

         ;-------------------------------------------------------------------------------------------------------
         ; Converting 10-m winds to 2-m winds using the surface roughness assigned based on dominant land-use
         ;-------------------------------------------------------------------------------------------------------
         if (var_in.eq."V2D".or.var_in.eq."U2D") then
            numerator_3D = conform_dims(dimsizes(v4), numerator, (/1, 2/))
            denominator_3D = conform_dims(dimsizes(v4), denominator, (/1, 2/))
            v4_10m = v4
            delete(v4)
            v4 = v4_10m*numerator_3D/denominator_3D
            copy_VarMeta(v4_10m, v4)
            delete([/v4_10m, numerator_3D, denominator_3D/])
         end if  ; 2-m wind calculation
      end if ; end spec hum if else cond. All other variables are processed in the else part.
   
     time=var&time
     cd_date_arr=cd_calendar(time,-3)  ; time as an integer in format YYYYMMDDHH, this is an array containing all timesteps in the month
     cd_string_arr=cd_string(time,"%Y-%N-%D_%H:%M:%S")  ; time in string format YY-MM-DD_hh:mm:ss, again an array containing all timesteps in the month

     ; Anjana, I'm not sure why this roundabout way to get a valid date (see line below concatenating to valid time) is required. 
     ; I'm retaining this in line with what the example scripts do as I don't want it to break the workflow. Maybe the unit has to be the one specified
     str_year_arr=cd_string(time,"%Y")
     str_mon_arr=cd_string(time,"%N")
     str_day_arr=cd_string(time,"%D")
     str_hour_arr=cd_string(time,"%H")
       
     ;--- change dimension names so that ncks command works appropriately ---;
     v4!0 = "Time"
     v4!1 = "south_north"
     v4!2 = "west_east"
     ;printVarSummary(v4)
     ;v4_orig = v4

     ;if there are ocean grids in the domain the ERA5Land variables would have missing values
     ;these need to be replaced with some reasonable constants in the forcing files
     print(var_in)
     print("Number of missing values = " + tostring(num(ismissing(v4))))
     v4 = where(ismissing(v4),var_const,v4)
     ;printVarSummary(v4)     
     print("Number of missing values = " + tostring(num(ismissing(v4)))) 

      do itime = 0,dimsizes(cd_date_arr)-1
         ncfile = outdir + tostring(cd_date_arr(itime)) +".LDASIN_"+domain+".nc"
 
         ;--------------------------------------------------------------------------------
         ; create output file only for the first variable & use for subsequent variables
         ;--------------------------------------------------------------------------------
         if (v.eq.0)
           if ( isfilepresent( ncfile ) ) then
               system ("/bin/rm "+ncfile)
           end if

           ncdf= addfile( ncfile,"c")
           ;print(ncdf)

           ;----------------------------------------------------------------------
           ; Parse time from filename : similar to the GLDAS script - don't exactly know why it is required
           ;----------------------------------------------------------------------
           ;dtime_map2 = (/4,2,2,2/)
           ;date_vec = str_split_by_length( datestr(0)+outF_hr_str, dtime_map2)
           ;print( date_vec )
     
           ;date_str = date_vec(0)+date_vec(1)+date_vec(2)+date_vec(3)
           ;Times_str = date_vec(0)+"-"+date_vec(1)+"-"+date_vec(2)+"_"+date_vec(3)+":00:00"
           
           Times_str=cd_string_arr(itime)
           new_string = str_strip(Times_str)
           Times = stringtochar( new_string )
           Times!0 = "DateStrLen"
     
           valid_time = cd_inv_calendar(toint(str_year_arr(itime)), toint(str_mon_arr(itime)), toint(str_day_arr(itime)), toint(str_hour_arr(itime)), toint(0) ,toint(0) ,"seconds since 1970-01-01 00:00:00", 0)
           valid_time!0 = "Time"

           filedimdef( ncdf ,"Time",-1,True)
           ;ncdf->Time = sTime_sel   ;output time
           ncdf->Times = Times  ;output times
           ncdf->valid_time = valid_time
           ncdf->lat = dlat2d   ;output lat
           ncdf->lon = dlon2d   ;output lon

           delete(valid_time)
         else
           ncdf= addfile( ncfile,"w")
         end if

         ncdf->$var_out$ = v4(itime:itime,:,:)

         if (v.eq.num_var-1) ; last variable
            dstFile = str_sub_str(ncfile, ".nc" , "")
            system( "mv "+ncfile+" "+dstFile)
         end if

      end do ; end do for hour loop  

      delete([/var,v4,var2d,wgtFileName,time,cd_date_arr,cd_string_arr,str_year_arr,str_mon_arr,str_day_arr,str_hour_arr/])
     
     end do   ; end do for file loop
   
   end do   ; end do for variable loop


end
