process ragtagpatch {

    publishDir "${params.outdir}", mode: 'copy'

    container "/scicomp/home-pure/xvp4/amr-metagenomics/third_party/ragtag.sif"

    input:
    path rag_tag_step1
    tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), val(accession_numbers)

    output:
    path "patch_*"

    script:
    """
    awk '/^>/ {p = !(/Chr0_RagTag/)}; p' /scicomp/home-pure/xvp4/amr-metagenomics/results/scaff_${sample_id}_${accession_numbers}/ragtag.scaffold.fasta > /scicomp/home-pure/xvp4/amr-metagenomics/results/scaff_${sample_id}_${accession_numbers}/ragtag.scaffold_no0.fasta
    ragtag.py patch /scicomp/home-pure/xvp4/amr-metagenomics/results/scaff_${sample_id}_${accession_numbers}/ragtag.scaffold_no0.fasta /scicomp/home-pure/xvp4/amr-metagenomics/results/${accession_numbers}.fa -o patch_${sample_id}_${accession_numbers}
    """
}