#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include {PREPROCESSING} from './subworkflows/local/preprocessing.nf'
params.reads = './samplesheet.csv'
params.outdir = 'results'  // default output directory
params.hostile_ref = "./assets/references/human-t2t-hla.argos-bacteria-985_rs-viral-202401_ml-phage-202401"
params.ref = "./assets/references/phiX.fasta"

Channel
    .fromFilePairs( params.reads, size: 2 )
    .set { reads: ch_reads }

Channel
    .fromPath('./assets/references/phiX.fasta')
    .set { ch_ref } 

Channel
    .fromPath(params.hostile_ref) 
    .set { ch_hostile_ref } 

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

WorkflowMain.initialise(workflow, params, log)

//
// WORkFLOW: iSAMR: in Silico AMR Metagenomics Workflow
//
println """\
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    iSAMR: in Silico AMR Metagenomics Workflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         """
         .stripIndent()


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    PREPROCESSING(ch_reads, ch_ref, ch_hostile_ref)
}
