###############
# units 
###############
units = {}
units.update({'LH': 'W/m$^2$'})
units.update({'HFX': 'W/m$^2$'})
# units.update({'SOIL_M': 'mm'})
# for var in ['SOIL_M_layer1', 'SOIL_M_layer2', 'SOIL_M_layer3', 'SOIL_M_layer4']:
#     units.update({var: 'mm'})
units.update({'SOIL_M': 'm$^3$/m$^3$'})
for var in ['SOIL_M_layer1', 'SOIL_M_layer2', 'SOIL_M_layer3', 'SOIL_M_layer4']:
    units.update({var: 'm$^3$/m$^3$'})  
for var in ['SOIL_M_accum_layer' + str(i) for i in range(1, 5)]:
    units.update({var: 'mm'})
units.update({'SOIL_M_total': 'mm'})

units.update({'ET': 'mm/day'})

###############
# Flux cbars
###############

col_levels_mean = {}
col_levels_diff = {}
col_levels_diff_perc = {}

flux_mean = [0, 5, 10, 20, 30, 50, 75, 100]

flux_diff = [-25, -15, -10, -5, -2.5, 2.5, 5, 10, 15, 25]
flux_diff_small = [-15, -7.5, -5, -2.5, 2.5, 5, 7.5, 15]

perc_diff_levels = [-40, -25, -15, -7.5, -2.5, 2.5, 7.5, 15, 25, 40]
perc_diff_levels_high = [-50, -30, -20, -10, -2.5, 2.5, 10, 20, 30, 50]

#et_mean = [0, 1, 2, 3, 4, 5]
#et_mean = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5]
et_mean = [0, 0.2, 0.4, 0.8, 1, 1.5, 2, 2.5, 3, 3.5]
#et_diff = [-2, -1.5, -1, -0.5, -0.2, 0.2, 0.5, 1, 1.5, 2]
et_diff = [-1, -0.75, -0.5, -0.25, -0.1, 0.1, 0.25, 0.5, 0.75, 1]

col_levels_mean.update({'LH': flux_mean})
col_levels_mean.update({'HFX': flux_mean})
col_levels_mean.update({'ET': et_mean})

col_levels_diff.update({'LH': flux_diff})
col_levels_diff.update({'HFX': flux_diff})
col_levels_diff.update({'ET': et_diff})

col_levels_diff_perc.update({'LH': perc_diff_levels})
col_levels_diff_perc.update({'HFX': perc_diff_levels})
col_levels_diff_perc.update({'ET': perc_diff_levels})

###############
# Soil cbars
###############

soilm_mean_vol = [0, 0.1, 0.2, 0.3, 0.4, 0.5]   #unused; intended for vol. sm
soilm_mean = [0, 5, 10, 15, 20, 30, 40, 50]
soilm_mean_l2 = [50, 75, 100, 125, 150, 175]
soilm_mean_l3 = [100, 125, 150, 175, 200, 250, 300, 350]
soilm_mean_l4 = [100, 125, 150, 200, 250, 300, 350, 400]

soilm_diff_vol = [-0.15, -0.1, -0.05, -0.01, 0.01, 0.05, 0.1, 0.15]   #unused; intended for vol. sm
soilm_diff = [-10, -5, -2.5, -1, 1, 2.5, 5, 10]
soilm_diff_l2 = [-20, -10, -5, -2.5, 2.5, 5, 10, 20]
soilm_diff_l3 = [-50, -30, -10, -2.5, 2.5, 10, 30, 50]
soilm_diff_l4 = [-50, -30, -10, -2.5, 2.5, 10, 30, 50]

# when plotting in mm
col_levels_mean.update({'SOIL_M': {0:soilm_mean, 1:soilm_mean_l2, 2:soilm_mean_l3, 3:soilm_mean_l4}})
col_levels_diff.update({'SOIL_M': {0:soilm_diff, 1:soilm_diff_l2, 2:soilm_diff_l3, 3:soilm_diff_l4}})
# when plotting in volumetric
col_levels_mean.update({'SOIL_M': {0:soilm_mean_vol, 1:soilm_mean_vol, 2:soilm_mean_vol, 3:soilm_mean_vol}})
col_levels_diff.update({'SOIL_M': {0:soilm_diff_vol, 1:soilm_diff_vol, 2:soilm_diff_vol, 3:soilm_diff_vol}})
col_levels_diff_perc.update({'SOIL_M': {0:perc_diff_levels, 1:perc_diff_levels, 2:perc_diff_levels, 3:perc_diff_levels}})

col_levels_mean.update({'SOIL_M_2layer': soilm_mean_l2})
col_levels_diff.update({'SOIL_M_2layer': soilm_diff_l3})
col_levels_diff_perc.update({'SOIL_M_2layer': perc_diff_levels})

soilm_tot_mean = [300, 350, 400, 450, 500, 600, 700, 800]
soilm_tot_diff = [-200, -150, -100, -50, -30, -10, 10, 30, 50, 100, 150, 200]

col_levels_mean.update({'SOIL_M_total': soilm_tot_mean})
col_levels_diff.update({'SOIL_M_total': soilm_tot_diff})
col_levels_diff_perc.update({'SOIL_M_total': perc_diff_levels})

####################
# Soil accum cbars
####################

soilm_accum_ly12 = [-50, -30, -20, -10, -5, 5, 10, 20, 30, 50]
soilm_accum_ly34 = [ -150, -100, -50, -10, 10, 50, 100, 150]
soilm_accum_total = [ -250, -150, -100, -50, -10, 10, 50, 100, 150, 250]

soilm_accum_ly12_diff = [-50, -30, -20, -10, -5, 5, 10, 20, 30, 50]
soilm_accum_ly34_diff = [-30, -20, -10, -5, -2, 2, 5, 10, 20, 30]
soilm_accum_total_diff = [-100, -60, -30, -15, -5, 5, 15, 30, 60, 100]

col_levels_mean.update({'SOIL_M_seasonal_accum': {0:soilm_accum_ly12, 1:soilm_accum_ly12, 2:soilm_accum_ly34, 3:soilm_accum_ly34}})
col_levels_diff.update({'SOIL_M_seasonal_accum': {0:soilm_accum_ly12_diff, 1:soilm_accum_ly12_diff, 2:soilm_accum_ly34_diff, 3:soilm_accum_ly34_diff}})
col_levels_diff_perc.update({'SOIL_M_seasonal_accum': {0:perc_diff_levels, 1:perc_diff_levels, 2:perc_diff_levels, 3:perc_diff_levels}})

col_levels_mean.update({'SOIL_M_total_seasonal_accum': soilm_accum_total})
col_levels_diff.update({'SOIL_M_total_seasonal_accum': soilm_accum_total_diff})
col_levels_diff_perc.update({'SOIL_M_total_seasonal_accum': perc_diff_levels})

col_levels_mean.update({'SOIL_M_2layer_seasonal_accum': soilm_accum_ly12})
col_levels_diff.update({'SOIL_M_2layer_seasonal_accum': soilm_accum_ly12_diff})
col_levels_diff_perc.update({'SOIL_M_2layer_seasonal_accum': perc_diff_levels})


# col_levels_mean.update({'SOIL_M_total': soilm_tot_mean})
# col_levels_diff.update({'SOIL_M_total': soilm_tot_diff})
# col_levels_diff_perc.update({'SOIL_M_total': perc_diff_levels})

# for var in ['SOIL_M_layer1', 'SOIL_M_layer2', 'SOIL_M_layer3', 'SOIL_M_layer4']:
#     col_levels_mean.update({var: soilm_mean})
# for var in ['SOIL_M_accum_layer' + str(i) for i in range(1, 3)]:
#     col_levels_mean.update({var: soilm_accum_ly12})
# for var in ['SOIL_M_accum_layer' + str(i) for i in range(3, 5)]:
#     col_levels_mean.update({var: soilm_accum_ly34})
# for var in ['SOIL_M_layer' + str(i) for i in range(1, 3)]:
#     col_levels_mean.update({var: soilm_accum_ly12})
# for var in ['SOIL_M_layer' + str(i) for i in range(3, 5)]:
#     col_levels_mean.update({var: soilm_accum_ly34})

# for var in ['SOIL_M_layer1', 'SOIL_M_layer2', 'SOIL_M_layer3', 'SOIL_M_layer4']:
#     col_levels_diff.update({var: soilm_tot_diff})
# for var in ['SOIL_M_accum_layer' + str(i) for i in range(1, 5)]:
#     col_levels_diff.update({var: soilm_accum_tot_diff})
    
# col_levels_diff_perc.update({'SOIL_M': perc_diff_levels})
# for var in ['SOIL_M_layer1', 'SOIL_M_layer2', 'SOIL_M_layer3', 'SOIL_M_layer4']:
#     col_levels_diff_perc.update({var: perc_diff_levels})
# for var in ['SOIL_M_accum_layer' + str(i) for i in range(1, 5)]:
#     col_levels_diff_perc.update({var: perc_diff_levels_high})