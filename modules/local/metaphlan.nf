#!/usr/bin/env nextflow

process metaphlan {

label 'process_high'

container "./third_party/metaphlan.sif"

    input:
    tuple val(sample), path(ch_clean_1), path(ch_clean_2)

    output:
    tuple val(sample), path("${sample}.txt"), emit: profile

    script:
    """
    metaphlan ${ch_clean_1},${ch_clean_2} \\
        --bowtie2out ${sample}_metagenome.bowtie2.bz2 \\
        --nproc 12 \\
        --input_type fastq \\
        -o ${sample}.txt \\
        --bowtie2db /scicomp/home-pure/tkq5/amr-metagenomics/assets/databases/metaphlan_databases
    """
}
