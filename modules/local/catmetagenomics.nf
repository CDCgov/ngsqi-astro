#!/usr/bin/env nextflow

process CATMETAGENOMICS {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(id), path(reads)
    path isolates_read1 
    path isolates_read2

    output:
    tuple val(id.id), path("${id.id}_1_integrated.fastq.gz"), path("${id.id}_2_integrated.fastq.gz"), emit: integrated_reads

    script:
    """
    cat "${isolates_read1}" "${reads[0]}" > "${id.id}_1_integrated.fastq.gz"
    cat "${isolates_read2}" "${reads[1]}" > "${id.id}_2_integrated.fastq.gz"
    """
}