#!/usr/bin/env nextflow

process metaphlan {

label 'process_high'

container "./third_party/metaphlan.sif"

    input:
    tuple val(sample), path(clean_reads)

    output:
    tuple val(sample), path("${sample}.txt"), emit: profile

    script:
    """
    metaphlan ${clean_reads[0]},${clean_reads[1]} \\
        --bowtie2out ${sample}_metagenome.bowtie2.bz2 \\
        --nproc 12 \\
        --input_type fastq \\
        -o ${sample}.txt \\
        --bowtie2db /scicomp/home-pure/tkq5/amr-metagenomics/assets/databases/metaphlan_databases
    """
}
