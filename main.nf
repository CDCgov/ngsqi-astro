#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// This main.nf file is a work in progress. Please no judgment
include {AMR} from './subworkflows/local/arg.nf'
include {AMR} from './subworkflows/local/arg.nf'

//set output directory 
params.outdir = 'arg_results' //default directory

//set path to amrfinderplus directory
params.amrfinderplus = "${baseDir}/assets/AMR_CDS.fasta" 

//set path to correct samplesheet
params.isolate_csv = '/scicomp/home-pure/tkq5/amr-metagenomics/samplesheet_contigs_2.5_CN.csv' //samplesheet
 
 
Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
    .map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }

 
workflow {
    // Update the AMRFinderPlus database
    db_results = AMRFINDERPLUS_UPDATE()

    databases = ["card", "plasmidfinder", "resfinder"]
    AMR(ch_samples,db_results.db, databases)
   
   
}
