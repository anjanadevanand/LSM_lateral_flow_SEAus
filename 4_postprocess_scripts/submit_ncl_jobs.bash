#!/bin/bash

for f in *.ncl
do
cp run_ncl_template.pbs run_ncl.pbs
sed -i "s|ncl_script_name.ncl|$f|g" run_ncl.pbs
job1=$(qsub run_ncl.pbs)
echo $job1
done
