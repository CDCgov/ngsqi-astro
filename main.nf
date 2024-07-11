#!/usr/bin/env nextflow
/*

nextflow.enable.dsl = 2

/*
*/

//params.fasta = WorkflowMain.getGenomeAttribute(params, 'fasta')

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//include { validateParameters; paramsHelp } from 'plugin/nf-validation'

// Print help message if needed
//if (params.help) {
//    def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
//    def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
//    def String command = "nextflow run ${workflow.manifest.name} --input samplesheet.csv --genome GRCh37 -profile docker"
//    log.info logo + paramsHelp(command) + citation + NfcoreTemplate.dashedLine(params.monochrome_logs)
//    System.exit(0)
//}

// Validate input parameters
//if (params.validate_params) {
//    validateParameters()
//}

//WorkflowMain.initialise(workflow, params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//NCBI Automate .fasta Retrieval
include { isolateaccessiontolist } from './modules/local/list_isolates'
include { fastaisolatepull } from './modules/local/pull_isolate_fasta'
include { taxonpullallisolates } from './modules/local/pull_taxon'
include { refseqpullallisolates } from './modules/local/pull_reference'
include { fastareferencepull } from './modules/local/pull_reference_fasta'


//include { PROTOTYPE } from './workflows/prototype'
//include { VARBEN } from './modules/local/varben'
//include { INDEX_BAM_REFSEQ } from './modules/local/index'
//include { BAMSURGEON_SNV } from './modules/local/bamsurgeon'
//include { RANDOM_PAIRED_READS } from './modules/local/bbmap'
//include { DWGSIM_PAIRED_READS } from './modules/local/dwgsim'
//include { NEAT_PAIRED_READS } from './modules/local/neat-genreads'
//
// WORKFLOW: Run main tb/prototype analysis pipeline
//
//workflow TB_PROTOTYPE {
//    PROTOTYPE ()
//}

// Define the CSV file path
//csv_file = file('/scicomp/home-pure/xvp4/isolate_reference_samplesheet.csv')

// Read the CSV file and split into columns
//Channel
//    .fromPath(csv_file)
//    .splitCsv(header: true)
//    .map { row -> [row.RefSeq_ID, row.refseq] } // Extract columns and add 'status'
//    .set { csvChannel }

// Define workflow
workflow {
    sequence1()
    sequence2()
}

workflow sequence1 {
    isolate_list = isolateaccessiontolist(params.input1, params.script1)
    fasta_isolates = fastaisolatepull(isolate_list, params.script2)
}

workflow sequence2 {
    taxon_isolates = taxonpullallisolates(params.input2, params.script3)
    refseq_isolates = refseqpullallisolates(taxon_isolates, params.script4)
    fasta_reference = fastareferencepull(refseq_isolates, params.script2)
}


workflow BAMFILE_SAMPLESHEET{

    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    Channel.fromPath ( samplesheet )
    .splitCsv ( header:true,sep:',' ) 
    .map { row -> tuple(row.sample, file(row.BAM), file(row.refseq)) }
    .set { samples }

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
