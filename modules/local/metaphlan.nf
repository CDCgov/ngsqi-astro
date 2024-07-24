#!/usr/bin/env nextflow

params.outdir = 'results'  // default output directory

process metaphlan {

label 'process_single'

container "/scicomp/home-pure/tkq5/amr-metagenomics/third_party/metaphlan.sif"

    input:
    tuple val(sample), path(fastq_1), path(fastq_2)

    output:
    tuple val(sample), path("${sample}.txt"), emit: profile

    script:
    """
    metaphlan ${fastq_1},${fastq_2} \\
        --bowtie2out ${sample}_metagenome.bowtie2.bz2 \\
        --nproc 9 \\
        --input_type fastq \\
        -o ${sample}.txt \\
        --bowtie2db /scicomp/home-pure/tkq5/amr-metagenomics/assets/databases/metaphlan_databases
    """
}