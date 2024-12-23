process FASTP {
    container './third_party/fastp.sif'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*trim.fq.gz'), emit: trimmed_reads
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    [ ! -f ${prefix}_1.fastq.gz ] && ln -s ${reads[0]} ${prefix}_1.fastq.gz
    [ ! -f ${prefix}_2.fastq.gz ] && ln -s ${reads[1]} ${prefix}_2.fastq.gz

    fastp \\
    -i ${prefix}_1.fastq.gz \\
    -I ${prefix}_2.fastq.gz \\
    -o ${prefix}_1_trim.fq.gz \\
    -O ${prefix}_2_trim.fq.gz \\
    --html ${prefix}.html \\
    $args \\
    2> ${prefix}.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
    END_VERSIONS
    """
}
