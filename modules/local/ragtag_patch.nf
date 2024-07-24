process ragtagpatch {

    publishDir "${params.outdir}", mode: 'copy'

    label 'process_single'

    container "/scicomp/home-pure/xvp4/amr-metagenomics/third_party/ragtag.sif"

    input:
    path rag_tag_step1
    tuple val(RefSeq_ID), val(refseq), val(Species_Name), val(Accession_Number)

    output:
    path "patch_*"

    script:
    """
    awk '/^>/ {p = !(/Chr0_RagTag/)}; p' /scicomp/home-pure/xvp4/amr-metagenomics/results/scaff_${RefSeq_ID}_${Accession_Number}/ragtag.scaffold.fasta > /scicomp/home-pure/xvp4/amr-metagenomics/results/scaff_${RefSeq_ID}_${Accession_Number}/ragtag.scaffold_no0.fasta
    ragtag.py patch /scicomp/home-pure/xvp4/amr-metagenomics/results/scaff_${RefSeq_ID}_${Accession_Number}/ragtag.scaffold_no0.fasta /scicomp/home-pure/xvp4/amr-metagenomics/results/${Accession_Number}.fa -o patch_${RefSeq_ID}_${Accession_Number}
    """
 
}