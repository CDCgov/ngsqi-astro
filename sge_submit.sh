#!/bin/bash
source /etc/profile

#$ -N read_sim_wkflow
#$ -cwd
#$ -l h_rt=24:00:00
#$ -l mem_free=128G
#$ -M xvp4@cdc.gov

module load nextflow/23
module load singularity

nextflow run main_2.0.nf 
