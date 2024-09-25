"""
Create a Fulldom_hires.nc file with modified parameter values that are read in from a text file.
"""

__title__ = "create_modified_fulldom_hires_by_soil_type"
__author__ = "Anjana Devanand"
__version__ = "1.0"
__email__ = "anjanadevanand@gmail.com"

import xarray as xr
import pandas as pd
import numpy as np

# Read values from a text file
def read_params_from_text_file_bySoilClass(text_file):
    '''
    Inside text_file:
    The first two lines contain info about the file
    Lines 3 onwards: param name1, value1, param name2, value2 and so on..
    '''
    values = []
    names = []
    with open(text_file, 'r') as file:
        for i in range(1):
            file.readline()  # first two lines state info about the text file. discarding them.
            file.readline()
        fLines = file.readlines()
        #print(fLines)
        for line in fLines[0::2]:
            for name in line.split():
                names.append(name)
        for line in fLines[1::2]:
            sClass = []
            sValue = []
            for soil in line.split(',')[0::2]:
                sClass.append(int(soil))
            for value in line.split(',')[1::2]:
                sValue.append(float(value))
            values.append(dict(zip(sClass, sValue)))
    params_dict = dict(zip(names, values))
    return params_dict

def multiply_to_create_new_da(da_orig, old_value, new_value):
    da_new = da_orig/old_value*new_value
    da_new = da_new.rename(da_orig.name).assign_attrs(da_orig.attrs)
    return da_new

if __name__ == '__main__':
    # read in the perturbed parameter values to be written to file
    text_file = 'Fulldom_hires_bySoilClass.TBL'
    params = read_params_from_text_file_bySoilClass(text_file)
    
    # Read in the 'Fulldom_hires.nc' file from the DOMAIN directory
    in_file = '../DOMAIN/Fulldom_hires.nc'
    ds_fulldom = xr.open_dataset(in_file)
    
    # Read in the dominant SOIL category data regridded to the fine grid
    in_soil_file = '../DOMAIN/SCT_DOM_RT.nc'
    ds_sctdom = xr.open_dataset(in_soil_file)

    # use a copy of the existing ds_fulldom file to create a perturbed one
    # the output file needs to be written to the individual run directory of each PEST agent
    # note that the below code works only for LKSATFAC which is modified by each soil class
    ds_fulldom_new = ds_fulldom.copy(deep = True)
    for parName in list(params.keys()):
        da_orig = ds_fulldom[parName]
        old_value = np.unique(da_orig.values.flatten())[0]

        # separate list of soil classes & its values
        sClass = list(params[parName].keys())
        all_values = list(params[parName].values())

        # the mean value of all the classes; will be used for other soil classes.
        # In this domain, the only other "soil" class that is present is water 
        # As the SATDK of water is zero this step does not make any difference to the simulation
        meanVal = np.mean(all_values)
        list_da = []
        for sc in sClass:
            da_new = multiply_to_create_new_da(da_orig, old_value = old_value, new_value = params[parName][sc])
            da_new = da_new.where(ds_sctdom['SCT_DOM'] == sc)
            list_da.append(da_new)
            del da_new
        da_concat = xr.concat(list_da, dim = 'soil_class')
        da_new = da_concat.sum('soil_class', skipna = True, min_count=1).fillna(meanVal)
        # check if rounding the data fixes the problem with writing RTOUT files
        #da_new = da_new.round(0)
        
        #da_new = da_new.assign_attrs(da_orig.attrs)
        #testing
        #da_new = (da_orig/10).assign_attrs(da_orig.attrs)
        #ds_fulldom_new[parName].values = da_new.values
        ds_fulldom[parName].values = da_new.values

    out_file = 'Fulldom_hires.nc'
    ds_fulldom.to_netcdf(out_file, encoding={'y': {'_FillValue': None}, 'x': {'_FillValue': None}})