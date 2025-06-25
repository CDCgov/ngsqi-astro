process NEATPAIRED {
    publishDir "${params.outdir}", mode: 'copy'
    label 'process_high'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/neat:4.2.8--pyhdfd78af_0' :
    'biocontainers/neat:4.2.8--pyhdfd78af_0' }"
    
    input:
    tuple val(sample_id), val(added_copy_number), path(patch_dir), val(species_name), val(ref_accession), path(ref_genome)
    val ch_readlength

    output:
    tuple val(sample_id), val(added_copy_number), path(patch_dir), val(ref_accession), path("simreads_${sample_id}_*_r1.fastq.gz"), path("simreads_${sample_id}_*_r2.fastq.gz"), emit: neat_reads
    path "versions.yml", emit: versions   

    script:
    """
    cat > neat_config.yml << EOF
    reference: ${patch_dir}/ragtag.patch.fasta
    read_len: ${ch_readlength}
    produce_bam: False
    produce_vcf: False
    paired_ended: True
    fragment_mean: 300
    fragment_st_dev: 30
    coverage: 100
    EOF

    neat read-simulator -c neat_config.yml -o "simreads_${sample_id}_${ref_accession}" 
    
    cat <<- 'END_VERSIONS' > versions.yml
    "${task.process}":
        NEAT: 4.2.8
    END_VERSIONS
    """
}

