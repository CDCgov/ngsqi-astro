#!/usr/bin/env nextflow

process heatmaps {
    label 'process_single'

    input:
    path merged_species
    path merged_phylum
    path(hclust2)

    output:
    path("merged_species.png"), emit: species_visual
    path("merged_phylum.png"), emit: phylum_visual
    path "versions.yml", emit: versions

    script:
    """
    python3 ${hclust2} \
        -i "${merged_species}" \
        -o "merged_species.png" \
        --ftop 10 \
        --f_dist_f braycurtis \
        --s_dist_f braycurtis \
        --cell_aspect_ratio 1 \
        --log_scale \
        --flabel_size 10 \
        --slabel_size 10 \
        --max_flabel_len 100 \
        --max_slabel_len 100 \
        --minv 0.1 \
        --dpi 300

    python3 ${hclust2} \
        -i "${merged_phylum}" \
        -o "merged_phylum.png" \
        --ftop 10 \
        --f_dist_f braycurtis \
        --s_dist_f braycurtis \
        --cell_aspect_ratio 1 \
        --log_scale \
        --flabel_size 10 \
        --slabel_size 10 \
        --max_flabel_len 100 \
        --max_slabel_len 100 \
        --minv 0.1 \
        --dpi 300
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hclust2: \$(hclust2 --version 2>&1 | sed -e "s/hclust2 //g")
    END_VERSIONS
    """
}
