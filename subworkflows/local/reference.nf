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
   if (params.mode == 'local') {
       isolate_data = LOCALISOLATE(input_data)
   } else {
       isolate_data = DOWNLOADISOLATE(input_data, downloadgenome_script, ncbi_email, ncbi_api_key)
   }
  
   ref_download = DOWNLOADREF(input_data, downloadref_script, ncbi_email, ncbi_api_key)
   ref_data = DOWNLOADGENOME(ref_download, downloadgenome_script, ncbi_email, ncbi_api_key)

   emit:
    isolate_data = isolate_data.genome_data
    ref_data = ref_data.genome_data
}