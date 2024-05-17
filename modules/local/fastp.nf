#!/usr/bin/env nextflow

process FASTP {
    container './third_party/fastp.sif'

    input:
    path(reads)

    output:
    path("*_fastp.fastq"), emit: trimmed_reads

    script:
    """
    fastp -i $reads -o ${reads.baseName}_fastp.fastq
    """
}
