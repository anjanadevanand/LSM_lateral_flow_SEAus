#!/bin/bash

for fname in LDAS RT #GW
do
echo $fname
for year in 2013 #2016 2017
do
for mon in 01 02 03 04 05 06 07 08 09 10 11 12
do
echo $year$mon
num_files=$(ls -l $year$mon*$fname* |wc -l)
echo $num_files
done
done
done
