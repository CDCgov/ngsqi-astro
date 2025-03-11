process RGI_MAIN {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/rgi:6.0.3--pyha8f3691_1':
        'biocontainers/rgi:6.0.3--pyha8f3691_1' }"

    input:
    tuple val(meta), path(fasta)
    path(card)

    output:
    tuple val(meta), path("*.json"), emit: json
    tuple val(meta), path("*.txt") , emit: txt
    tuple val(meta), path("temp/") , emit: tmp
    env RGI_VERSION                , emit: tool_version
    env DB_VERSION                 , emit: db_version
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: '' // This customizes the command: rgi load
    def args2 = task.ext.args ?: '' // This customizes the command: rgi main
    def prefix = task.ext.prefix ?: "${meta.id}"


    """
    DB_VERSION=\$(ls ${card}/card_database_*_all.fasta | sed "s/${card}\\/card_database_v\\([0-9].*[0-9]\\).*/\\1/")

    rgi \\
        load \\
        $args \\
        --card_json ${card}/card.json \\
        --debug --local \\
        --card_annotation ${card}/card_database_v\$DB_VERSION.fasta \\
        --card_annotation_all_models ${card}/card_database_v\$DB_VERSION\\_all.fasta \\

    rgi \\
        main \\
        $args2 \\
        --num_threads $task.cpus \\
        --output_file $prefix \\
        --input_sequence $fasta

    mkdir temp/
    for FILE in *.xml *.fsa *.{nhr,nin,nsq} *.draft *.potentialGenes *{variant,rrna,protein,predictedGenes,overexpression,homolog}.json; do [[ -e \$FILE ]] && mv \$FILE temp/; done

    RGI_VERSION=\$(rgi main --version)

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rgi: \$(echo \$RGI_VERSION)
        rgi-database: \$(echo \$DB_VERSION)
    END_VERSIONS
    """

    stub:
    """
    mkdir -p temp
    touch test.json
    touch test.txt

    RGI_VERSION=\$(rgi main --version)
    DB_VERSION=stub_version

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rgi: \$(echo \$RGI_VERSION)
        rgi-database: \$(echo \$DB_VERSION)
    END_VERSIONS
    """
}
