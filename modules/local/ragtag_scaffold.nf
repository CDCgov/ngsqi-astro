process ragtagscaffold {

    publishDir "${params.outdir}", mode: 'copy'

    label 'process_single'

    container "/scicomp/home-pure/xvp4/amr-metagenomics/third_party/ragtag.sif"

    input:
    tuple val(RefSeq_ID), val(refseq), val(Species_Name), val(Accession_Number)
    file "isolate_genome_assemblies_with_species.csv"

    output:
    path "scaff_*"

    script:
    """
    ls ${params.outdir}/isolate_genome_assemblies_with_species.csv
    ragtag.py scaffold -C /scicomp/home-pure/xvp4/amr-metagenomics/results/${Accession_Number}.fa /scicomp/home-pure/xvp4/amr-metagenomics/results/${RefSeq_ID}.fa -o "scaff_${RefSeq_ID}_${Accession_Number}"
    """
 
}
