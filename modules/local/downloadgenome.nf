process downloadgenome {
   
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), val(accession)

    output:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), val(accession), path("*_genomic.fna"), emit: genome_data
    path "*_genomic.fna.gz", emit: zipped_genome

    script:
    """
    clean_accession=\$(echo '${accession}' | tr -d '\\n\\r' | sed 's/[^a-zA-Z0-9._]//g')

    export NCBI_API_KEY=${params.ncbi_api_key}
    export NCBI_EMAIL=${params.ncbi_email}
    python ${params.downloadgenome_script} "\$clean_accession"

    downloaded_file=\$(ls *_genomic.fna.gz)

    gunzip -c "\$downloaded_file" > "\${downloaded_file%.gz}"
    """
}
