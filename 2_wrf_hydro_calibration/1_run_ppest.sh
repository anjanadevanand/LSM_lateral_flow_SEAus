#!/bin/bash

# set the appropriate wall times in ppest_slave_template.pbs & ppest_master.pbs

# submit the master first & hold it; submit agents 3 to nSlaves dependent on master so that they would end if master crashes & resources would not be wasted
# add the master job ID here
masterJob=

nSlaves=10
# create test$i directories for each slave and start the slave jobs
for (( i=1; i<=$nSlaves; i++ ))
do
    if [ ! -d "test$i" ] ; then
	mkdir "test$i"
    fi
    rm test$i/*
    export islave=$i
    cp ppest_slave_template.pbs ppest_slave.pbs 
    sed -i 's|slave_no|'${islave}'|g' ppest_slave.pbs
    if [ "$i" -gt 1 ]; then 
    sljob=$(qsub -W depend=after:$masterJob ppest_slave.pbs )
    else
    sljob=$(qsub ppest_slave.pbs )
    fi
done

# submit the master to run after the last slave has started execution
#mjob=$(qsub -W depend=after:$sljob ppest_master.pbs) 
