#!/bin/bash
source /etc/profile

#$ -N test_NEAT_workflow
#$ -cwd
#$ -l mem_free=32G

module load nextflow/23
module load singularity

nextflow run main.nf -profile singularity \
-entry NEAT \
--input /scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/p_aeruginosa_goldstandard_samplesheet.csv \
--outdir output
