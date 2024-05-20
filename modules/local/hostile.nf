#!/usr/bin/env nextflow

params.reads = './samplesheet.csv'
params.ref = "./assets/references/human-t2t-hla.argos-bacteria-985_rs-viral-202401_ml-phage-202401.fa.gz" // added ref as a param

workflow {
    Channel
        .fromFilePairs( params.reads, size: 2 )
        .set { ch_reads }

    Channel
        .fromPath(params.ref)
        .set { ch_hostile_ref }

    ch_reads.view { sample, reads -> "The reference genome is ${params.ref} and the metagenomics reads from ${sample} are: ${reads[0]} and ${reads[1]}" }

    HOSTILE(ch_reads, ch_hostile_ref)
}
process HOSTILE {
    container './third_party/hostile.sif'

    input:
    tuple val(sample), path(reads)
    path ref

    output:
    path("hostile"), emit: hostile_output

    script:
    """
    hostile clean --index ${ref} --fastq1 ${reads[0]} --fastq2 ${reads[1]} --out-dir hostile
    """
}
