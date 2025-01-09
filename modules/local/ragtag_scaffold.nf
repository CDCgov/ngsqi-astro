#!/usr/bin/env nextflow

process RAGTAGSCAFFOLD {
    publishDir "${params.outdir}", mode: 'copy'

    container "${baseDir}/third_party/ragtag.sif"

    input:
    tuple val(sample_id), val(added_copy_number), val(iso_file_path), val(species_name), path(isolate_genome), val(ref_file_path), val(species_name),val(ref_accession), path(ref_genome)

    output:
    tuple val(sample_id), val(added_copy_number), val(iso_file_path), val(species_name), val(ref_accession), path(ref_genome), path("scaff_${sample_id}"), emit: ragtag_scaff_dirs
    path "versions.yml", emit: versions

    script:
    """
    ragtag.py scaffold -C ${ref_genome} ${isolate_genome} -o "scaff_${sample_id}"
    sleep 10
    
    cat <<- 'END_VERSIONS' > versions.yml
    "${task.process}":
        RAGTAG/SCAFFOLD: 2.1.0
    END_VERSIONS
    """
}
