process METAPHLAN {
    label 'process_high'
    container 'staphb/metaphlan:4.1.1'

    input:
    tuple val(meta), path(reads)
    path metaphlan_db_latest

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
        --bowtie2db ${metaphlan_db_latest}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan: \$(metaphlan --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}

