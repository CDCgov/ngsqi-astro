#!/usr/bin/env nextflow

process HOSTILE {
    container './third_party/hostile.sif'

    input:
    path(reads)

    output:
    path("*_hostile.fastq"), emit: hostile_reads

    script:
    """
    hostile -i $reads -o ${reads.baseName}_hostile.fastq
    """
}
