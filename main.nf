#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Modules for automated retrieval of isolate genomes
include { isolateaccessiontolist } from './modules/local/list_isolates'
include { fastaisolatepull } from './modules/local/pull_isolate_fasta'
// Modules for automated retrieval of reference genomes
include { taxonpullallisolates } from './modules/local/pull_taxon'
include { refseqpullallisolates } from './modules/local/pull_reference'
include { fastareferencepull } from './modules/local/pull_reference_fasta'
// Modules for RagTag genome assembly
include { ragtagscaffold } from './modules/local/ragtag_scaffold.nf'
include { ragtagpatch } from './modules/local/ragtag_patch.nf'
// Module for read simulation
include { neatpaired } from './modules/local/neat-genreads'

// Define two workflow sequences
workflow {
    // Download isolate genomes from NCBI
    isolatedownload()
    // Download reference genomes from NCBI, assemble isolate genomes, simulate reads
    refdownloadreadsim()
}

workflow isolatedownload {
    // Convert samplesheet to list of .fna files
    isolate_list = isolateaccessiontolist(params.input1, params.script1)
    // Download isolate .fna files using NCBI E-utilities
    fasta_isolates = fastaisolatepull(isolate_list, params.script2)
}

workflow refdownloadreadsim {
    // Retrieve species name for each isolate using NCBI E-utilities
    taxon_isolates = taxonpullallisolates(params.input1, params.script3)
    // Retrieve accession number for species reference genome using NCBI E-utilities
    refseq_isolates = refseqpullallisolates(taxon_isolates, params.script4)
    // Label two outputs: out1=sample sheet with species name and accession number, out2=list of reference accession numbers
    (out1, out2) = refseq_isolates
    // Download reference .fna files using NCBI E-utilities
    fasta_pull = fastareferencepull(out2, params.script2)
    // Parse output csv file
    out1
        .ifEmpty { Channel.empty() }
        .splitCsv(header: true, sep: ',')
        .view { row -> println "${row.RefSeq_ID} - ${row.refseq} - ${row.Species_Name} - ${row.Accession_Number}" }
        .set { parsed_data }
    // Using columns from csv file, combine the isolate genome with the reference genome to generate isolate genome scaffold
    rag_tag_step1=ragtagscaffold(parsed_data, fasta_pull)
    // Using columns from csv file, combine the isolate genome with the reference genome to generate gapless genome
    rag_tag_step2=ragtagpatch(rag_tag_step1,parsed_data)
    // Simulate reads from gapless isolate genomes
    neatpaired(rag_tag_step2,parsed_data)
}

