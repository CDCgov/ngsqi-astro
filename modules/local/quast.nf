process QUAST {
    container 'https://depot.galaxyproject.org/singularity/quast:5.0.2--py37pl526hb5aa323_2'
    
    input:
    tuple val(sample), path(contigs)

    output:
    tuple val(sample), path("${sample}.tsv"), emit: quast_report

    script:
    """
    metaquast.py --threads 5 --space-efficient --rna-finding --max-ref-number 0 -l "${sample}" "${contigs}" -o "${sample}"

    ln -s ${sample}/report.tsv ${sample}.tsv


    """
}