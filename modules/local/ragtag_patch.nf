process RAGTAGPATCH {
   publishDir "${params.outdir}", mode: 'copy'
   errorStrategy 'ignore'
   tag "sample: ${sample_id}"

   container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
   'https://depot.galaxyproject.org/singularity/ragtag:2.1.0--pyhb7b1952_0' :
   'biocontainers/ragtag:2.1.0--pyhb7b1952_0' }"

   input:
   tuple val(sample_id), val(added_copy_number), val(iso_file_path), val(species_name), val(ref_accession), path(ref_genome), path(scaff_dir)

   output:
   tuple val(sample_id), val(added_copy_number), path("patched_${sample_id}"), val(species_name), val(ref_accession), path(ref_genome), emit: ragtag_patch_dirs optional true
   path "versions.yml", emit: versions
   
   script:
   """
   if [ ! -f "${scaff_dir}/ragtag.scaffold.fasta" ]; then
      echo "Assembly unsuccessful for ${sample_id}: ragtag.scaffold.fasta not found in ${scaff_dir}" >&2
      exit 1
   fi

   ragtag.py patch ${ref_genome} ${scaff_dir}/ragtag.scaffold.fasta -o "patched_${sample_id}"

   cat <<- 'END_VERSIONS' > versions.yml
   "${task.process}":
      RAGTAG/SCAFFOLD: 2.1.0
   END_VERSIONS
   """
}