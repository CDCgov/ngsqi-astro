// modules/process_isolate.nf
process PROCESSISOLATE {
    tag "$sample_id"
    publishDir "${params.outdir}/processed_isolates", mode: 'copy'

    input:
    tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), path(genome_fna)  // Remove accession

    output:
    tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), path("${sample_id}_processed.fna"), emit: genome_data

    script:
    """
    cp ${genome_fna} "${sample_id}_processed.fna"
    """
}