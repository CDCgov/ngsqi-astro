#!/usr/bin/env nextflow

process DOWNLOADGENOME {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), val(accession)
    path downloadgenome_script
    val ncbi_email
    val ncbi_api_key

    output:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), val(accession), path("*_genomic.fna.gz"), emit: gunzip

    script:
    """
    clean_accession=\$(echo "${accession}" | tr -d '\\n\\r' | sed 's/[^a-zA-Z0-9._]//g')

    export NCBI_API_KEY=${ncbi_api_key}
    export NCBI_EMAIL=${ncbi_email}
    python ${downloadgenome_script} "\${clean_accession}"

    downloaded_file=\$(ls *_genomic.fna.gz)
    gunzip -c "\${downloaded_file}" > "\${downloaded_file%.gz}"
    """
}
