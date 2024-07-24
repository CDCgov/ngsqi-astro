process  NEAT_PAIRED_READS {

    publishDir "${params.outdir}", mode: 'copy'


    label 'process_single'

    input:
        path rag_tag_step1
        tuple val(RefSeq_ID), val(refseq), val(Species_Name), val(Accession_Number)

    output:
    path "simreads_*"

    script:
    """
    python /neat-genreads/gen_reads.py -r /scicomp/home-pure/xvp4/amr-metagenomics/results/patch_${RefSeq_ID}_${Accession_Number}/ragtag.patch.fasta -R 151 -c 100 --pe 300 30 --bam -o simreads_${RefSeq_ID}_${Accession_Number}
    """
 
}

