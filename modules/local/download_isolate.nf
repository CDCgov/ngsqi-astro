process DOWNLOADISOLATE {
   input:
   tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name)
   path downloadgenome_script
   val ncbi_email
   val ncbi_api_key

   output:
   tuple val(sample_id), val(added_copy_number), val(genome_path), val(species_name), path("${sample_id}_genomic.fna"), emit: genome_data
   path "${sample_id}_genomic.fna.gz", emit: isolate_fna

   exec:
   genome_path = "$workflow.workDir/${task.index}/${sample_id}_genomic.fna"
   
   script:
   """
   export NCBI_API_KEY=${ncbi_api_key}
   export NCBI_EMAIL=${ncbi_email}
   python ${downloadgenome_script} ${sample_id}
   if [ -f "${sample_id}_genomic.fna.gz" ]; then
       gunzip -c "${sample_id}_genomic.fna.gz" > "${sample_id}_genomic.fna"
   else
       echo "Download failed for ${sample_id}"
       exit 1
   fi
   """
}