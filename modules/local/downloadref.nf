#!/usr/bin/env nextflow

process DOWNLOADREF {
   tag "$species_name"

   input:
   tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name)
   path downloadref_script
   val ncbi_email
   val ncbi_api_key

   output:
   tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), env(ref_accession)

   script:
   """
   export NCBI_API_KEY=${ncbi_api_key}
   export NCBI_EMAIL=${ncbi_email}
   ref_accession=\$(python ${downloadref_script} "${species_name}" | tail -n1)
   """
}
