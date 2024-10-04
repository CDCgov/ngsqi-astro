process downloadref {
    
    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name)

    output:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), env(accession)

    script:
    """
    export NCBI_API_KEY=${params.ncbi_api_key}
    export NCBI_EMAIL=${params.ncbi_email}
    accession=\$(python ${params.downloadref_script} "${species_name}" | sed 's/[[:space:]\\r]*\$//' | tr -d '\\r')
    sleep \$(( RANDOM % 10 + 5 ))
    """
    stub:
    """
    accession="STUB_accession"
    """

}
