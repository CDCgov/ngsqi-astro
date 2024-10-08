process ragtagpatch {

    publishDir "${params.outdir}", mode: 'copy'

    container "/scicomp/home-pure/xvp4/amr-metagenomics/third_party/ragtag.sif"

    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(accession), path(ref_file), path(scaff_dir)
    
    output:
    path "${scaff_dir}/ragtag.scaffold_no0.fasta", emit: no0_fasta
    tuple val(sample_id), val(added_copy_number), path(file_path), val(accession), path(ref_file), path(scaff_dir), path("patch_${sample_id}_${accession}"), emit:ragtag_patch_dirs

    script:
    """
    awk '/^>/ {p = !(/Chr0_RagTag/)}; p' ${scaff_dir}/ragtag.scaffold.fasta > ${scaff_dir}/ragtag.scaffold_no0.fasta
    ragtag.py patch ${scaff_dir}/ragtag.scaffold_no0.fasta ${ref_file} -o "patch_${sample_id}_${accession}"
    """
}