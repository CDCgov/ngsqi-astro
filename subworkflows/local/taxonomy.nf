#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {metaphlan} from '../../modules/local/metaphlan.nf'
include {merge_abundance} from '../../modules/local/merge_abundance.nf'
include {filter_abundance} from '../../modules/local/filter_abundance.nf'
include {heatmaps} from '../../modules/local/heatmaps.nf'

workflow TAXONOMY {
    take:
    ch_clean
    ch_hclust2

    main:
    metaphlan(ch_clean)
    
    merge_abundance(metaphlan.out.profile.map { it[1] }.collect())
    
    filter_abundance(merge_abundance.out.merged_output)

    heatmaps(filter_abundance.out.species_output, filter_abundance.out.phylum_output, ch_hclust2)
    
    emit:
    metaphlan.out.profile
    merge_abundance.out.merged_output
    filter_abundance.out.phylum_output
    filter_abundance.out.species_output
    heatmaps.out.species_visual
    heatmaps.out.phylum_visual
}
