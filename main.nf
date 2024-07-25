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
include { ragtagscaffold } from './modules/local/ragtag_scaffold.nf'
include { ragtagpatch } from './modules/local/ragtag_patch.nf'
include { NEAT_PAIRED_READS } from './modules/local/neat-genreads'

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
    (out1, out2) = refseq_isolates
    fasta_pull = fastareferencepull(out2, params.script2)
    out1
        .ifEmpty { Channel.empty() }
        .splitCsv(header: true, sep: ',')
        .view { row -> println "${row.RefSeq_ID} - ${row.refseq} - ${row.Species_Name} - ${row.Accession_Number}" }
        .set { parsed_data }
    rag_tag_step1=ragtagscaffold(parsed_data, fasta_pull)
    rag_tag_step2=ragtagpatch(rag_tag_step1,parsed_data)
    NEAT_PAIRED_READS(rag_tag_step2,parsed_data)
}

