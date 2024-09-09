#!/usr/bin/env nextflow

process metaphlan {

label 'process_high'

container "./third_party/metaphlan.sif"

    input:
    tuple val(sample), path(fastq_1), path(fastq_2)

    output:
    tuple val(sample), path("${sample}.txt"), emit: profiles

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