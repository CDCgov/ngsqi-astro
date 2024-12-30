#!/usr/bin/env nextflow

process CATMETAGENOMICS {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), path(read_1), path(read_2)
    path isolates_read1
    path isolates_read2

    output:
    tuple val(sample_id), path("${sample_id}_1_integrated.fastq.gz"), path("${sample_id}_2_integrated.fastq.gz"), emit: integrated_reads

    script:
    def cleanName1 = "${sample_id}_1_integrated.fastq.gz"
    def cleanName2 = "${sample_id}_2_integrated.fastq.gz"
    """
    cat "${isolates_read1}" "${read_1}" > "${cleanName1}"
    cat "${isolates_read2}" "${read_2}" > "${cleanName2}"
    """
}

