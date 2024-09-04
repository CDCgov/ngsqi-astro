process QUAST {
    container 'https://depot.galaxyproject.org/singularity/quast:5.0.2--py37pl526hb5aa323_2'
    
    input:
    tuple val(sample), path(assembly)

    output:
    tuple val(sample), path("${prefix}.tsv"), emit: quast_report

    script:
    def prefix = assembly.baseName.replaceAll(/_[12].*$/, '')
    """
    metaquast.py --threads 5 --space-efficient --rna-finding --max-ref-number 0 -l "${prefix}" "${assembly}" -o "${prefix}""

    ln -s ${prefix}/report.tsv ${prefix}.tsv


    """
}