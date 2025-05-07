process METAPHLAN_DB {

    container 'staphb/metaphlan:4.1.1'

    output:
    path "metaphlan_db_latest"      , emit: db
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def database_version = 'mpa_vJun23_CHOCOPhlAnSGB_202403'

    """
    metaphlan \\
        --install \\
        --index $database_version \\
        --nproc $task.cpus \\
        --bowtie2db metaphlan_db_latest \\
        $args
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan: \$(metaphlan --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}
