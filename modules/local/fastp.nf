#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process FASTP {
    container './third_party/fastp.sif'

    input:
    tuple val(sample), path(fastq_1), path(fastq_2)

    output:
    tuple val(sample), path("*_1_trim.fq.gz"), path("*_2_trim.fq.gz"), emit: trimmed_reads
    tuple val(sample), path("*.fastp.html"), emit: html
    tuple val(sample), path("*.fastp.log"), emit: log
    path "versions.yml", emit: versions

    script:

    """
    echo "Running fastp on ${fastq_1} and ${fastq_2}"
    fastp -i ${fastq_1} -I ${fastq_2} -o ${sample}_1_trim.fq.gz -O ${sample}_2_trim.fq.gz --html ${sample}.fastp.html 2> ${sample}.fastp.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
    END_VERSIONS
    """
}
