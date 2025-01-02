process ABRICATE_RUN {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate%3A1.0.1--ha8f3691_1':
        'biocontainers/abricate:1.0.1--ha8f3691_1' }"

    input:
    tuple val(meta), path(assembly)
    path databasedir

    output:
    tuple val(meta), path("*.txt"), emit: report
    tuple val(sample), path(fna)
	val dbs

   // output:
   // tuple val(sample), path("${sample}.${dbs[0]}.abricate.txt"), emit: report1
//	tuple val(sample), path("${sample}.${dbs[1]}.abricate.txt"), emit: report2
	//tuple val(sample), path("${sample}.${dbs[2]}.abricate.txt"), emit: report3
   // path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def datadir = databasedir ? "--datadir ${databasedir}" : ''
    """
    abricate \\
        $assembly \\
        $args \\
        $datadir \\
        --threads $task.cpus \\
        > ${prefix}.txt
   // def prefix = task.ext.prefix ?: "${meta.id}"
  
    """
  //  abricate --db ${dbs[0]} ${fna} > ${sample}.${dbs[0]}.abricate.txt
//	abricate --db ${dbs[1]} ${fna} > ${sample}.${dbs[1]}.abricate.txt
//	abricate --db ${dbs[2]} ${fna} > ${sample}.${dbs[2]}.abricate.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(echo \$(abricate --version 2>&1) | sed 's/^.*abricate //' )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def datadir = databasedir ? '--datadir ${databasedir}' : ''
    """
    touch ${prefix}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(echo \$(abricate --version 2>&1) | sed 's/^.*abricate //' )
    END_VERSIONS
    """
}
