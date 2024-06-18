process  NEAT_PAIRED_READS {


    label 'process_single'

    input:
        tuple val(sample), val(refseq)

    output:

    script:
    """
    cd /neat-genreads
    python gen_reads.py -r ${refseq} -R 151 -c 100 --pe 300 30 --bam -o /scicomp/home-pure/xvp4/${sample} \
    """
 
}
