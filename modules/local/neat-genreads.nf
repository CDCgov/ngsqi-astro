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
    python gen_reads.py -r /scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate-genomes/GCF_000006765.1/GCF_000006765.1_ASM676v1_genomic.fna -R 195 -c 100 --bam -o /scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate-genomes/GCF_000006765.1_out \
    """
 
}
