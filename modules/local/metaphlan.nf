#!/usr/bin/env nextflow

process METAPHLAN {
    label 'process_high'
    container "./third_party/metaphlan.sif"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.txt"), emit: profiles
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    metaphlan ${reads[0]},${reads[1]} \\
        --bowtie2out ${prefix}_metagenome.bowtie2.bz2 \\
        --nproc 12 \\
        --input_type fastq \\
        -o ${prefix}.txt \\
        --bowtie2db ./assets/databases/metaphlan_databases/latest

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan: \$(metaphlan --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}

