"""
Create a Fulldom_hires.nc file with modified parameter values that are read in from a text file.
"""

__title__ = "create_modified_fulldom_hires"
__author__ = "Anjana Devanand"
__version__ = "1.0"
__email__ = "anjanadevanand@gmail.com"

import xarray as xr
import pandas as pd
import numpy as np

# Read values from a text file
def read_params_from_text_file(text_file):
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
            for value in line.split():
                values.append(float(value))
    params_dict = dict(zip(names, values))
    return params_dict

def multiply_to_create_new_da(da_orig, old_value, new_value):
    da_new = da_orig/old_value*new_value
    da_new = da_new.rename(da_orig.name).assign_attrs(da_orig.attrs)
    return da_new

if __name__ == '__main__':
    # read in the perturbed parameter values to be written to file
    text_file = 'Fulldom_hires.TBL'
    params = read_params_from_text_file(text_file)
    
    # Read in the 'Fulldom_hires.nc' file from the DOMAIN directory
    in_file = '../DOMAIN/Fulldom_hires.nc'
    ds_fulldom = xr.open_dataset(in_file)

    # use a copy of the existing ds_fulldom file to create a perturbed one
    # the output file needs to be written to the individual run directory of each PEST agent
    ds_fulldom_new = ds_fulldom.copy(deep = True)
    for parName in list(params.keys()):
        da_orig = ds_fulldom[parName]
        old_value = np.unique(da_orig.values.flatten())[0]
        da_new = multiply_to_create_new_da(da_orig, old_value = old_value, new_value = params[parName])
        ds_fulldom_new[parName] = da_new

    out_file = 'Fulldom_hires.nc'
    ds_fulldom_new.to_netcdf(out_file)
    
    
