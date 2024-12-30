#!/usr/bin/env nextflow

process RAGTAGSCAFFOLD {
    publishDir "${params.outdir}", mode: 'copy'

    container "${baseDir}/third_party/ragtag.sif"

    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), val(accession), path(ref_file)

    output:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), val(accession), path(ref_file), path("scaff_${sample_id}_${accession}"), emit: ragtag_scaff_dirs
    path "versions.yml", emit: versions
    
    script:
    """
    ragtag.py scaffold -C ${ref_file} ${file_path} -o "scaff_${sample_id}_${accession}"

    cat <<- 'END_VERSIONS' > versions.yml
    "${task.process}":
        RAGTAG/SCAFFOLD: 2.1.0
    END_VERSIONS
    """
}

