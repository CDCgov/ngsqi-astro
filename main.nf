#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// This main.nf file is a work in progress. Please no judgment
include {AMR} from './subworkflows/local/arg.nf'
 
params.outdir = 'arg_results' //default directory
params.isolate_csv = '/scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate_reference_samplesheet3.csv' //samplesheet
 
 
Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
    .map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }

 
workflow {
 
    databases = ["card", "plasmidfinder", "resfinder"]
    AMR(ch_samples, databases)
   
   
}
