#!/usr/bin/env nextflow


process FASTP {
   
    container './third_party/fastp.sif'
   
    input:
    tuple val(sample_id), file(reads)
    
    output:
    path("${sample_id}_R1_fastp.fastq.gz"), emit: trimmed_reads1
    path("${sample_id}_R2_fastp.fastq.gz"), emit: trimmed_reads2
  
    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} -o ${sample_id}_R1_fastp.fastq.gz -O ${sample_id}_R2_fastp.fastq.gz
    """
}

