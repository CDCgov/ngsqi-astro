#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    amr-metagenomics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GitLab : https://git.biotech.cdc.gov/ngsqi-insilico/amr-metagenomics
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//params.fasta = WorkflowMain.getGenomeAttribute(params, 'fasta')

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { validateParameters; paramsHelp } from 'plugin/nf-validation'

// Print help message if needed
if (params.help) {
    def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
    def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
    def String command = "nextflow run ${workflow.manifest.name} --input samplesheet.csv --genome GRCh37 -profile docker"
    log.info logo + paramsHelp(command) + citation + NfcoreTemplate.dashedLine(params.monochrome_logs)
    System.exit(0)
}

// Validate input parameters
if (params.validate_params) {
    validateParameters()
}

WorkflowMain.initialise(workflow, params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//include { PROTOTYPE } from './workflows/prototype'

include { VARBEN } from './modules/local/varben'
include { INDEX_BAM_REFSEQ } from './modules/local/index'
include { BAMSURGEON_SNV } from './modules/local/bamsurgeon'
include { RANDOM_PAIRED_READS } from './modules/local/bbmap'
include { DWGSIM_PAIRED_READS } from './modules/local/dwgsim'
include { metaphlan } from './modules/local/metaphlan'

//
// WORKFLOW: Run main amr-metagenomics analysis pipeline


workflow BAMFILE_SAMPLESHEET{

    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    Channel.fromPath ( samplesheet )
    .splitCsv ( header:true,sep:',' ) 
    .map { row -> tuple(row.sample, file(row.BAM), file(row.refseq)) }
    .set { samples }

    emit:
    samples  // channel: [ val(sampleid), bamfile, reference genome ]

}

workflow REFERENCE_SAMPLESHEET{

    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    Channel.fromPath ( samplesheet )
    .splitCsv ( header:true,sep:',' ) 
    .map { row -> tuple(row.sample, file(row.refseq)) }
    .set { samples }

    emit:
    samples  // channel: [ val(sampleid), reference genome ]

}

workflow BAMSURGEON {

    BAMFILE_SAMPLESHEET ( params.input )
    INDEX_BAM_REFSEQ ( BAMFILE_SAMPLESHEET.out.samples )
    BAMSURGEON_SNV ( INDEX_BAM_REFSEQ.out.sample_reference )

}

workflow BBMAP {
    REFERENCE_SAMPLESHEET ( params.input )
    RANDOM_PAIRED_READS ( REFERENCE_SAMPLESHEET.out.samples )
}

workflow DWGSIM {

    REFERENCE_SAMPLESHEET ( params.input )
    DWGSIM_PAIRED_READS ( REFERENCE_SAMPLESHEET.out.samples )

}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
