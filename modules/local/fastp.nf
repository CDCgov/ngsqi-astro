#!/usr/bin/env nextflow

process FASTP {
    container './third_party/fastp.sif'

    input:
    tuple val(sample_id), path(fastq_1), path(fastq_2)

    output:
    tuple val(sample_id), path("${fastq_1.baseName.replace('.fastq', '')}_trim.fq.gz"), path("${fastq_2.baseName.replace('.fastq', '')}_trim.fq.gz"), emit: trimmed_reads
    tuple val(sample_id), path('*.html'), emit: html

    script:
    def baseName = fastq_1.baseName.replaceAll(/_[12].*$/, '')
    def prefix1 = fastq_1.baseName.replace('.fastq', '')
    def prefix2 = fastq_2.baseName.replace('.fastq', '')
    """
    echo "Running fastp on ${fastq_1} and ${fastq_2}"
    fastp -i ${fastq_1} -I ${fastq_2} -o ${prefix1}_trim.fq.gz -O ${prefix2}_trim.fq.gz --html ${baseName}.fastp.html
    """
}
