process QUAST {
    container 'https://depot.galaxyproject.org/singularity/quast:5.0.2--py37pl526hb5aa323_2'
    
    input:
    tuple val(sample), path(contigs)

    output:
    tuple val(sample), path("${sample}.tsv"), emit: quast_report
    path "versions.yml", emit: versions
    //tuple val(sample), path("${sample}.contigs"), emit: quast_outputs

    script:
    """
    metaquast.py --threads 5 --space-efficient --rna-finding --max-ref-number 0 -l "${sample}" "${contigs}" -o "${sample}"

    ln -s ${sample}/report.tsv ${sample}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        metaquast: \$(metaquast.py --version | sed "s/QUAST v//; s/ (MetaQUAST mode)//")
    END_VERSIONS
    """
}