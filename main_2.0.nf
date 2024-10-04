#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Modules for automated retrieval of isolate genomes
include { downloadref } from './modules/local/downloadref'
include { downloadgenome } from './modules/local/downloadgenome'
// Modules for RagTag genome assembly
include { ragtagscaffold } from './modules/local/ragtag_scaffold.nf'
include { ragtagpatch } from './modules/local/ragtag_patch.nf'
// Module for read simulation
include { neatpaired } from './modules/local/neat-genreads'
// Modules for integration
include { catcopynumber } from './modules/local/catcopynumber'
include { catisolates } from './modules/local/catisolates'
include { catmetagenomics } from './modules/local/catmetagenomics'

workflow  {
    Channel
        .fromPath(params.input_isolates)
        .splitCsv(header: true, sep: ',')
        .map { row -> tuple(row.sample_id, row.added_copy_number, file(row.file_path), row.species_name) }
        .set { input_data }
    
    downloadref(input_data)
    downloadgenome(downloadref.out)
    downloadgenome.out.genome_data.view { id, copy, file_path, species, accession, genome_file ->
        "Sample: $id, Species: $species, Accession: $accession, Genome file: ${genome_file.name}"
    }
    ragtagscaffold(downloadgenome.out.genome_data)
    ragtagpatch(ragtagscaffold.out.ragtag_scaff_dirs)
    neatpaired(ragtagpatch.out.ragtag_patch_dirs)
    catcopynumber(neatpaired.out.neat_reads)
    catisolates(catcopynumber.out.copynumber_read1.collect(),catcopynumber.out.copynumber_read2.collect())

    Channel
        .fromPath(params.input_metagenomics)
        .splitCsv(header: true, sep: ',')
        .map { row -> tuple(row.sample_id, file(row.read_1), file(row.read_2)) }
        .set { input_meta }

    catmetagenomics(input_meta,catisolates.out.isolates_read1,catisolates.out.isolates_read2)
}