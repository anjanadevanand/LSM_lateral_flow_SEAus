#!/bin/bash

# the start and end number of the new agents/slaves
# the *case*.rmf file should already contain information about these new agents/slaves  

slStart=5
slEnd=8

# create test$i directories for each slave and start the slave jobs
for (( i=$slStart; i<=$slEnd; i++ ))
do
    if [ ! -d "test$i" ] ; then
	mkdir "test$i"
    fi
    rm test$i/*
    export islave=$i
    cp ppest_slave_template.pbs ppest_slave.pbs 
    sed -i 's|slave_no|'${islave}'|g' ppest_slave.pbs
    sljob=$(qsub ppest_slave.pbs )
done

