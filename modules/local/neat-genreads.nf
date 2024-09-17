process  neatpaired {

    publishDir "${params.outdir}", mode: 'copy'


    label 'process_single'

    input:
        path rag_tag_step1
        tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), val(accession_numbers)

    output:
    path "simreads_*"

    script:
    """
    python /neat-genreads/gen_reads.py -r /scicomp/home-pure/xvp4/amr-metagenomics/results/patch_${sample_id}_${accession_numbers}/ragtag.patch.fasta -R 151 -c 100 --pe 300 30 --bam -o simreads_${sample_id}_${accession_numbers}
    """
 
}

