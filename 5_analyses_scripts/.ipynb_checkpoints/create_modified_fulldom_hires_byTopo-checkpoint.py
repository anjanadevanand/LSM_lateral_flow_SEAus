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
def read_min_max_params_from_text_file(text_file):
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
            value_temp = []
            for value in line.split(','):
                #print(float(value))
                value_temp.append(float(value))
        values.append(value_temp)
    params_dict = dict(zip(names, values))
    return params_dict

if __name__ == '__main__':

    # read in the perturbed parameter values to be written to file
    text_file = 'Fulldom_hires_byTopo.TBL'
    params = read_min_max_params_from_text_file(text_file)

    # Read in the 'Fulldom_hires.nc' file from the DOMAIN directory
    in_file = '../DOMAIN/Fulldom_hires.nc'
    ds_fulldom = xr.open_dataset(in_file)

    parName = 'LKSATFAC'

    # if LKSATFAC varies with topography with a defined min-max - what would it look like?
    lksatfac_min = params[parName][0]
    lksatfac_max = params[parName][1]

    topo_min = ds_fulldom['TOPOGRAPHY'].where(ds_fulldom['TOPOGRAPHY']>0).min().values
    topo_max = ds_fulldom['TOPOGRAPHY'].where(ds_fulldom['TOPOGRAPHY']>0).max().values

    da_topo = ds_fulldom['TOPOGRAPHY'].where(ds_fulldom['TOPOGRAPHY'] > 0)

    # create a new array with min-max ranges as specified & matching the topographic pattern
    da_new = ((1 - (da_topo - topo_min) / (topo_max - topo_min))*(lksatfac_max - lksatfac_min)) + lksatfac_min
    da_new_mean = da_new.mean().values
    da_new = da_new.fillna(da_new_mean)

    da_new = da_new.rename(ds_fulldom[parName].name).assign_attrs(ds_fulldom[parName].attrs)

    ds_fulldom_new = ds_fulldom.copy(deep = True)
    ds_fulldom_new[parName] = da_new

    out_file = 'Fulldom_hires.nc'
    ds_fulldom_new.to_netcdf(out_file)