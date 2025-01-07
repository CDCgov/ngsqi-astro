#!/usr/bin/env nextflow

process DOWNLOADGENOME {
    tag "$accession"
    publishDir "${params.outdir}/references", mode: 'copy'

    input:
    tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), val(accession)
    path downloadgenome_script
    val ncbi_email
    val ncbi_api_key

    output:
    tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), val(accession), path("*_genomic.fna"), emit: genome_data
    path "*_genomic.fna.gz"

    script:
    """
    export NCBI_API_KEY=${ncbi_api_key}
    export NCBI_EMAIL=${ncbi_email}
    python ${downloadgenome_script} ${accession}
    gunzip -c *_genomic.fna.gz > \$(basename *_genomic.fna.gz .gz)
    """
}