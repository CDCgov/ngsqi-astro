process RAGTAGPATCH {
   publishDir "${params.outdir}", mode: 'copy'
   container "${baseDir}/third_party/ragtag.sif"

   input:
   tuple val(sample_id), val(added_copy_number), path(scaff_dir)
   tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), val(ref_accession), path(ref_genome)



   output:
   tuple val(sample_id), val(added_copy_number), path("patched_${sample_id}"), val(species_name), val(ref_accession), path(ref_genome), emit: ragtag_patch_dirs

   script:
   """
   ragtag.py patch ${ref_genome} ${scaff_dir}/ragtag.scaffold.fasta -o "patched_${sample_id}"
   """
}