process HAMRONIZATION_ABRICATE {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/hamronization:1.1.4--pyhdfd78af_0':
        'biocontainers/hamronization:1.1.4--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(report_megares)
    tuple val(meta), path(report_resfinder)
    tuple val(meta), path(report_plasmid)
    val(format)
    val(software_version)
    val(db_megares)
    val(db_resfinder)
    val(db_plasmid)

    output:
    tuple val(meta), path("${meta.id}_megares.json"), emit: megares_json
    tuple val(meta), path("${meta.id}_plasmidfinder.json"), emit: resfinder_json
    tuple val(meta), path("${meta.id}_resfinder.json"), emit: plasmid_json
    tuple val(meta), path("*.tsv") , optional: true, emit: tsv
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    hamronize \\
        abricate \\
        ${report_megares} \\
        $args \\
        --format ${format} \\
        --analysis_software_version ${software_version} \\
        --reference_database_version ${db_megares} \\
        > ${meta.id}_megares.${format}

      hamronize \\
        abricate \\
        ${report_resfinder} \\
        $args \\
        --format ${format} \\
        --analysis_software_version ${software_version} \\
        --reference_database_version ${db_resfinder} \\
        > ${meta.id}_resfinder.${format}

      hamronize \\
        abricate \\
        ${report_plasmid} \\
        $args \\
        --format ${format} \\
        --analysis_software_version ${software_version} \\
        --reference_database_version ${db_plasmid} \\
        > ${meta.id}_plasmidfinder.${format}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hamronization: \$(echo \$(hamronize --version 2>&1) | cut -f 2 -d ' ' )
    END_VERSIONS
    """
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.${format}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hamronization: \$(echo \$(hamronize --version 2>&1) | cut -f 2 -d ' ' )
    END_VERSIONS
    """
}
