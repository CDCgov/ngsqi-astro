process LOCALISOLATE {
    tag "$sample_id"

    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name)

    output:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), path("${sample_id}_genomic.fna"), emit: genome_data

    script:
    """
    if [ ! -f "${sample_id}_genomic.fna" ]; then
        if [ -f "${file_path}" ]; then
            cp "${file_path}" "${sample_id}_genomic.fna"
        else
            echo "Error: Genome file not found at ${file_path}"
            exit 1
        fi
    fi
    """
}