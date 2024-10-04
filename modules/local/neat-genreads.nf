process  neatpaired {

    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(accession), path(ref_file), path(scaff_dir), path(patch_dir)

    output:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(accession), path("simreads_${sample_id}_${accession}_read1.fq.gz"), path("simreads_${sample_id}_${accession}_read2.fq.gz"), emit:neat_reads

    script:
    """
    python /neat-genreads/gen_reads.py -r ${patch_dir}/ragtag.patch.fasta -R 151 -c 100 --pe 300 30 --bam -o "simreads_${sample_id}_${accession}"
    """
 
}

