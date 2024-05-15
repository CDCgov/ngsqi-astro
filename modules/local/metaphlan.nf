#!/usr/bin/env nextflow

params.outdir = 'results'  // default output directory

process metaphlan {

label 'process_single'

container "./third_party/metaphlan.sif"

    input:
    tuple val(sample), path(fastq_1), path(fastq_2)

    output:
    tuple val(sample), path("${sample}.txt"), emit: profile

    script:
    """
    metaphlan ${fastq_1},${fastq_2} \\
        --bowtie2out ${sample}_metagenome.bowtie2.bz2 \\
        --nproc ${task.cpus} \\
        --input_type fastq \\
        -o ${sample}.txt \\
        --bowtie2db ./assets/databases/metaphlan_databases
    """
}