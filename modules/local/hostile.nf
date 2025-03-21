process HOSTILE {
    tag "${meta.id}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/hostile:1.1.0--pyhdfd78af_0'
        : 'biocontainers/hostile:1.1.0--pyhdfd78af_0'}"

    input:
    tuple val(meta), path(reads)
    path(hostile_ref)

    output:
    tuple val(meta), path('*clean.fastq.gz'), emit: clean_reads
    tuple val(meta), path("*.hostile.log"), emit: log
    path "versions.yml", emit: versions
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def cleanName1 = "${prefix}_1_clean.fastq.gz"
    def cleanName2 = "${prefix}_2_clean.fastq.gz"

    """
    hostile clean --index ${hostile_ref} --fastq1 ${reads[0]} --fastq2 ${reads[1]} > ${prefix}.hostile.log

    #Rename the output files
     mv ${prefix}_1.clean_1.fastq.gz ${cleanName1}
     mv ${prefix}_2.clean_2.fastq.gz ${cleanName2}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hostile: \$(echo \$(hostile --version 2>&1))
    END_VERSIONS
    """
}
