#!/usr/bin/env nextflow

process CATMETAGENOMICS {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(meta), path(reads)
    tuple val(sample_id), path(isolates_read1)
    tuple val(sample_id), path(isolates_read2)

    output:
    tuple val(meta), path("*_integrated.fastq.gz"), emit: integrated_reads

    script:
    def cleanName1 = "${sample_id}_1_integrated.fastq.gz"
    def cleanName2 = "${sample_id}_2_integrated.fastq.gz"
    """
    cat "${isolates_read1}" "${reads[0]}" > "${cleanName1}"
    cat "${isolates_read2}" "${reads[1]}" > "${cleanName2}"
    """
}

