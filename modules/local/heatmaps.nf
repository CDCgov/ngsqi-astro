#!/usr/bin/env nextflow

params.outdir = 'results'  // default output directory

process heatmaps {

label 'process_single'

container "/scicomp/home-pure/tkq5/amr-metagenomics/third_party/metaphlan.sif"
//edit below
    input:
    tuple val(sample), path("${sample}.txt")), path(fastq_2)

    output:
    tuple val(sample), path("${sample}.txt"), emit: profile

    script:
    """
    python3 ./hclust2.py \
        -i "$file" \
        -o "$output_name" \
        --ftop 10 \
        --f_dist_f braycurtis \
        --s_dist_f braycurtis \
        --cell_aspect_ratio 0.1 \
        --log_scale \
        --flabel_size 10 \
        --slabel_size 10 \
        --max_flabel_len 100 \
        --max_slabel_len 100 \
        --minv 0.1 \
        --dpi 300

    """
}
