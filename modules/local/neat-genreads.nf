process NEATPAIRED {
    publishDir "${params.outdir}", mode: 'copy'
    
    input:
    tuple val(sample_id), val(added_copy_number), path(patch_dir), val(species_name), val(ref_accession), path(ref_genome)
    val ch_readlength

    output:
    tuple val(sample_id), val(added_copy_number), path(patch_dir), val(ref_accession), path("simreads_${sample_id}_${ref_accession}_read1.fq.gz"), path("simreads_${sample_id}_${ref_accession}_read2.fq.gz"), emit: neat_reads
    path "versions.yml", emit: versions   

    script:
    """
    python /neat-genreads/gen_reads.py -r ${patch_dir}/ragtag.patch.fasta -R ${ch_readlength} -c 100 --pe 300 30 --bam -o "simreads_${sample_id}_${ref_accession}"
    
    cat <<- 'END_VERSIONS' > versions.yml
    "${task.process}":
        NEAT: 3.0.0
    END_VERSIONS
    """
}
