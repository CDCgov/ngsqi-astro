process  NEAT_PAIRED_READS {

    publishDir "${params.outdir}/neat-genreads", mode: 'copy'

    label 'process_single'

    input:
        tuple val(sample), path(refseq)

    output:
        path "${sample}_reads_r1.fastq.gz"
        path "${sample}_reads_r2.fastq.gz"
        path "${sample}_golden.bam"

    script:
    """
    cd /neat-genreads
    python gen_reads.py -r ${sample} -R 195 -c 100 --bam -o ${sample} \
    """
 
}
