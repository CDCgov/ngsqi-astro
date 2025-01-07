process ABRICATE_RUN {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate%3A1.0.1--ha8f3691_1':
        'biocontainers/abricate:1.0.1--ha8f3691_1' }"

    input:
    tuple val(meta), path(assembly)
    val db

    output:
    tuple val(meta), path("${meta.id}_${db[0]}_abricate.txt"), emit: report_card
    tuple val(meta), path("${meta.id}_${db[1]}_abricate.txt"), emit: report_resfinder
    tuple val(meta), path("${meta.id}_${db[2]}_abricate.txt"), emit: report_plasmid
    path "versions.yml"                             , emit: versions
    
    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    abricate --db ${db[0]} \\
        $assembly \\
        $args \\
        --threads $task.cpus \\
        > ${prefix}_${db[0]}_abricate.txt

    abricate --db ${db[1]} \\
        $assembly \\
        $args \\
        --threads $task.cpus \\
        > ${prefix}_${db[1]}_abricate.txt

    abricate --db ${db[2]} \\
        $assembly \\
        $args \\
        --threads $task.cpus \\
        > ${prefix}_${db[2]}_abricate.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(echo \$(abricate --version 2>&1) | sed 's/^.*abricate //' )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(echo \$(abricate --version 2>&1) | sed 's/^.*abricate //' )
    END_VERSIONS
    """
}
