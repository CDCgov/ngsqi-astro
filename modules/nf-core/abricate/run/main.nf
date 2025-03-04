process ABRICATE_RUN {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate%3A1.0.1--ha8f3691_1' :
        'biocontainers/abricate:1.0.1--ha8f3691_1'}"

    input:
    tuple val(meta), path(assembly)
    path megares_db_path
    path plasmidfinder_db_path
    path resfinder_db_path

    output:
    tuple val(meta), path("${meta.id}_megares_abricate.txt"), emit: report_megares
    tuple val(meta), path("${meta.id}_plasmidfinder_abricate.txt"), emit: report_resfinder
    tuple val(meta), path("${meta.id}_resfinder_abricate.txt"), emit: report_plasmid
    path "versions.yml", emit: versions
    env megares_DBVER, emit: db_megares
    env plasmidfinder_DBVER, emit: db_plasmid
    env resfinder_DBVER, emit: db_resfinder

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"


    """
    abricate  \\
        $assembly \\
        $args \\
        --db ${megares_db_path} \\
        --threads $task.cpus \\
        > ${prefix}_megares_abricate.txt

    abricate \\
        $assembly \\
        $args \\
        --db ${plasmidfinder_db_path} \\
        --threads $task.cpus \\
        > ${prefix}_plasmidfinder_abricate.txt

    abricate \\
        $assembly \\
        $args \\
        --db ${resfinder_db_path} \\
        --threads $task.cpus \\
        > ${prefix}_resfinder_abricate.txt

    megares_DBVER=\$(cat ${megares_db_path}/VERSION.TXT)
    plasmidfinder_DBVER=\$(cat ${plasmidfinder_db_path}/VERSION.txt)
    resfinder_DBVER=\$(cat ${resfinder_db_path}/VERSION)

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(echo \$(abricate --version 2>&1) | sed 's/^.*abricate //' )
        megares-database: \$megares_DBVER
        plasmidfinder-database: \$plasmidfinder_DBVER
        resfinder-database: \$resfinder_DBVER
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
