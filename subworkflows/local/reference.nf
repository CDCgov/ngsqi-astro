// subworkflows/reference.nf
include { LOCALISOLATE } from '../../modules/local/local_isolate.nf'
include { DOWNLOADISOLATE } from '../../modules/local/download_isolate.nf'
include { PROCESSISOLATE } from '../../modules/local/process_isolate.nf'
include { DOWNLOADREF } from '../../modules/local/downloadref.nf'
include { DOWNLOADGENOME } from '../../modules/local/downloadgenome.nf'

workflow REFERENCE {
   take:
   input_data
   downloadref_script
   downloadgenome_script
   ncbi_email
   ncbi_api_key

    main:
    // Get isolate genomes
    if (params.mode == 'local') {
        isolate_data = LOCALISOLATE(input_data)
    } else {
        isolate_data = DOWNLOADISOLATE(input_data, downloadgenome_script, ncbi_email, ncbi_api_key)
    }

    // Get reference genomes
    ref_download = DOWNLOADREF(input_data, downloadref_script, ncbi_email, ncbi_api_key)
    ref_data = DOWNLOADGENOME(ref_download, downloadgenome_script, ncbi_email, ncbi_api_key)

    // Join isolate and reference data by sample_id and added_copy_number
    paired_data = isolate_data.genome_data
        .join(ref_data.genome_data, by: [0,1])

    emit:
        paired_data
}