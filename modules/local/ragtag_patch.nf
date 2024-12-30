process RAGTAGPATCH {

    publishDir "${params.outdir}", mode: 'copy'

    container "${baseDir}/third_party/ragtag.sif"

    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), val(accession), path(ref_file), path(scaff_dir)
    
    output:
    path "${scaff_dir}/ragtag.scaffold_no0.fasta", emit: no0_fasta
    tuple val(sample_id), val(added_copy_number), path(file_path), val(accession), path(ref_file), path(scaff_dir), path("patch_${sample_id}_${accession}"), emit:ragtag_patch_dirs
    path "versions.yml", emit: versions
    
    script:
    """
    awk '/^>/ {p = !(/Chr0_RagTag/)}; p' ${scaff_dir}/ragtag.scaffold.fasta > ${scaff_dir}/ragtag.scaffold_no0.fasta
    ragtag.py patch ${scaff_dir}/ragtag.scaffold_no0.fasta ${ref_file} -o "patch_${sample_id}_${accession}"
    
    cat <<- 'END_VERSIONS' > versions.yml
    "${task.process}":
        RAGTAG/PATCH: 2.1.0
    END_VERSIONS

    
    """
}