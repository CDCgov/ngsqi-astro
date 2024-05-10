#!/usr/bin/env nextflow

params.outdir = 'results'  // default output directory
params.reads = 'assets/data/*_{1,2}.fastq.gz'  // default input reads pattern

Channel
    .fromFilePairs( params.reads, size: 2 )
    .set { ch_reads }

process metaphlan {

label 'process_single'

container "./third_party/metaphlan.sif"

    tag "metaphlan_${sample}"
    publishDir "${params.outdir}/metaphlan", mode: 'copy'

    input:
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path("${sample}.txt"), emit: profile


    script:
    """
    echo "Printing the PATH:"
    echo $PATH
    echo "Checking the location of metaphlan:"
    which metaphlan

    metaphlan ${reads[0]},${reads[1]} \\
        --bowtie2out ${sample}_metagenome.bowtie2.bz2 \\
        --nproc ${task.cpus} \\
        --input_type fastq \\
        -o ${sample}.txt \\
        --bowtie2db ./assets/databases/metaphlan_databases

    """
}

