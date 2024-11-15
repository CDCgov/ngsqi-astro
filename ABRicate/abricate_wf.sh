#!/bin/bash

#Author: Sarah Scott
#Last_updated: 5/15/2024

# Setup Variables
data_prefix=GC
input_dir=~/ARG_subworkflow/isolate_data
output_dir=~/ARG_subworkflow/abricate_output

# abricate variables
dbs=("card" "plasmidfinder" "resfinder")
abricate_path=~/

mkdir -p $input_dir $output_dir

for i in $input_dir/${data_prefix}*
do
        isolate_id=${i#$input_dir/}             # get the isolate id from path
        isolate_output_dir=$output_dir/$isolate_id
        mkdir -p $isolate_output_dir            # make the output dir

        for file in $i/*.fna
        do
                file=${file#$i/}                # get the file name from the path
                for db in ${dbs[*]}             # iterate through the dbs array
                do
                        singularity exec $abricate_path/abricate.sif abricate --db $db $i/$file > $isolate_output_dir/${file%.fna}_$db.txt
                done
        done
done
~     
