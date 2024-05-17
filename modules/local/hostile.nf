#!/usr/bin/env nextflow

process HOSTILE {
    container './third_party/hostile.sif'

    input:
    tuple val(sample_id), path(fastq1), path(fastq2), path(index)

    output:
    path("${sample_id}_hostile_output"), emit: hostile_output

    script:
    """
    hostile clean --index $index --fastq1 $fastq1 --fastq2 $fastq2 --out-dir ${sample_id}_hostile_output
    """
}
