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
    env card_DBVER, emit: db_card
    env plasmidfinder_DBVER, emit: db_plasmid
    env resfinder_DBVER, emit: db_resfinder
    
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


    card_DBVER=\$(echo \$(amrfinder --database ${baseDir}/assets/2024-07-22.1/ --database_version 2> stdout) | rev | cut -f 1 -d ' ' | rev)
    plasmidfinder_DBVER=\$(echo \$(amrfinder --database ${baseDir}/assets/2024-07-22.1/ --database_version 2> stdout) | rev | cut -f 1 -d ' ' | rev)
    resfinder_DBVER=\$(echo \$(amrfinder --database ${baseDir}/assets/2024-07-22.1/ --database_version 2> stdout) | rev | cut -f 1 -d ' ' | rev)


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(echo \$(abricate --version 2>&1) | sed 's/^.*abricate //' )
        card-database: \$card_DBVER
        resfinder-database: \$resfinder_DBVER
        plasmidfinder-database: \$plasmidfinder_DBVER
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
