#!/usr/bin/env nextflow

process DOWNLOADREF {
    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name)
    path downloadref_script
    val ncbi_email
    val ncbi_api_key

    output:
    //tuple val(sample_id), val(added_copy_number), path("${sample_id}_genomic.fna"), val(species_name), val(accession)
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), env(accession), emit: accession
    //env(accession)
    //path("${sample_id}_genomic.fna"), emit: fna

    script:
    
    """
    export NCBI_API_KEY=${ncbi_api_key}
    export NCBI_EMAIL=${ncbi_email}
    accession=\$(python ${downloadref_script} "${species_name}" | sed 's/[[:space:]\\r]*\$//' | tr -d '\\r')
    sleep \$(( RANDOM % 10 + 5 ))
    """
    stub:
    """
    accession="STUB_accession"
    """

}
