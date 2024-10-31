#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {AMR} from './subworkflows/local/arg.nf'

//set path to amrfinderplus directory
params.amrfinderplus = "${baseDir}/assets/AMR_CDS.fasta" 

//set path to correct samplesheet
params.isolate_csv = '/scicomp/home-pure/tkq5/amr-metagenomics/samplesheet_contigs_2_5_copynum.csv' //samplesheet
 
 
Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
    .map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }

 
workflow {

    databases = ["card", "plasmidfinder", "resfinder"]
    AMR(ch_samples, databases)
   
   
}
