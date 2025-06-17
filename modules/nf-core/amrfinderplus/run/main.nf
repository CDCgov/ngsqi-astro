process AMRFINDERPLUS_RUN {
    tag "$meta.id"
    label 'process_medium'
    debug true

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ncbi-amrfinderplus:3.12.8--h283d18e_0':
        'biocontainers/ncbi-amrfinderplus:3.12.8--h283d18e_0' }"

    input:
    tuple val(meta), path(fasta)
    path db

    output:
    tuple val(meta), path("${meta.id}.tsv"), emit: report
    path "versions.yml", emit: versions
    env VER, emit: tool_version
    env DBVER, emit: db_version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def is_compressed_fasta = fasta.getName().endsWith(".gz") ? true : false
    prefix = task.ext.prefix ?: "${meta.id}"
    organism_param = meta.containsKey("organism") ? "--organism ${meta.organism} --mutation_all ${prefix}-mutations.tsv" : ""
    fasta_name = fasta.getName().replace(".gz", "")
    fasta_param = meta.containsKey("is_proteins") && meta.is_proteins ? "-p" : "-n"
    
    """
    if [ "$is_compressed_fasta" == "true" ]; then
        gzip -c -d $fasta > $fasta_name
    fi

    amrfinder \\
        $fasta_param $fasta_name \\
        $organism_param \\
        $args \\
        --database ${baseDir}/assets/2024-07-22.1/ \\
        --threads $task.cpus > ${prefix}.tsv

    VER=\$(amrfinder --version)
    DBVER=\$(echo \$(amrfinder --database ${baseDir}/assets/2024-07-22.1/ --database_version 2> stdout) | rev | cut -f 1 -d ' ' | rev)

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        amrfinderplus: \$VER
        amrfinderplus-database: \$DBVER
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.tsv

    VER=\$(amrfinder --version)
    DBVER=stub_version

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        amrfinderplus: \$VER
        amrfinderplus-database: stub_version
    END_VERSIONS
    """
}
