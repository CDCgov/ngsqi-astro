#!/usr/bin/env nextflow

workflow {
   
    Channel
        .fromFilePairs( params.reads, size: 2 )
        .set { ch_reads }

    Channel
        .fromPath(params.hostile_ref)
        .set { ch_hostile_ref }

    ch_reads.view { sample, reads -> "The reference genome is ${params.hostile_ref} and the metagenomics reads from ${sample} are: ${reads[0]} and ${reads[1]}" }

    HOSTILE(ch_reads, ch_hostile_ref)
}
process HOSTILE {
    container './third_party/hostile.sif'

    input:
    tuple val(sample), path(reads)
    path ref
    path hostile_ref

    output:
    path("hostile"), emit: hostile_output

    script:
    """
    hostile clean --index ${ref} --fastq1 ${reads[0]} --fastq2 ${reads[1]} --out-dir hostile
    """
}

