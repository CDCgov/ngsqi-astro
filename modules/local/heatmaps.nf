#!/usr/bin/env nextflow

process heatmaps {

    label 'process_single'

    input:
    path merged_species
    path merged_phylum

    output:
    path("${merged_species}.png"), emit: species_visual
    path("${merged_phylum}.png"), emit: phylum_visual

    script:
    """
    ml Python/3
    pip install hclust2

    # Run clustering
    hclust2.py \
        -i "${merged_species}" \
        -o "${merged_species}.png" \
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

<<<<<<< HEAD
    hclust2.py \
        -i "${merged_phylum}" \
        -o "${merged_phylum}.png" \
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
=======
>>>>>>> dev/taxonomy
    """
}
