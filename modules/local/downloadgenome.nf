process DOWNLOADGENOME {
    tag "$accession"
    publishDir "${params.outdir}/references", mode: 'copy'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/neat:4.2.8--pyhdfd78af_0' :
    'biocontainers/neat:4.2.8--pyhdfd78af_0' }"

    input:
    tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), val(accession)
    path downloadgenome_script
    val ncbi_email
    val ncbi_api_key

    output:
    tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), val(accession), path("${accession}_genomic.fna"), emit: genome_data
    path "${accession}_genomic.fna"  // More specific path pattern

    script:
    """
    export NCBI_API_KEY=${ncbi_api_key}
    export NCBI_EMAIL=${ncbi_email}
    python ${downloadgenome_script} ${accession}
    if [ -f "${accession}_genomic.fna.gz" ]; then
       gunzip -c "${accession}_genomic.fna.gz" > "${accession}_genomic.fna"
    else
       echo "Download failed for ${accession}"
       exit 1
    fi
    """
}
