#!/usr/bin/env nextflow

process FASTP {
    container './third_party/fastp.sif'

    input:
    tuple val(sample_id), path(reads1), path(reads2)

    output:
    path("${sample_id}_R1_fastp.fastq.gz"), emit: trimmed_reads1
    path("${sample_id}_R2_fastp.fastq.gz"), emit: trimmed_reads2

    script:
    """
    fastp -i $reads1 -I $reads2 -o ${sample_id}_R1_fastp.fastq.gz -O ${sample_id}_R2_fastp.fastq.gz
    """
}
