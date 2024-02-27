#!/bin/bash
source /etc/profile

#$ -N test_dwgsim_workflow
#$ -cwd
#$ -l mem_free=62G

module load nextflow/23
module load singularity

nextflow run main.nf -profile singularity \
-entry DWGSIM \
--input /scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/dwgsim_test_samplesheet.csv \
--outdir output
