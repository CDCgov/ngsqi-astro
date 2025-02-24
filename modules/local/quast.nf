process QUAST {
    container 'https://depot.galaxyproject.org/singularity/quast:5.0.2--py37pl526hb5aa323_2'
    
    input:
    tuple val(meta), path(contigs)

    output:
    tuple val(meta), path("*.tsv"), emit: tsv
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    metaquast.py --threads 5 --space-efficient --rna-finding --max-ref-number 0 -l "${prefix}" "${contigs}" -o "${prefix}"

    ln -s "${prefix}/report.tsv" "${prefix}.tsv"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        metaquast: \$(metaquast.py --version | sed "s/QUAST v//; s/ (MetaQUAST mode)//")
    END_VERSIONS
    """
}