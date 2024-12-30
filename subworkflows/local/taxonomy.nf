#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { METAPHLAN } from '../../modules/local/metaphlan.nf'
include { MERGE_ABUNDANCE } from '../../modules/local/merge_abundance.nf'
include { FILTER_ABUNDANCE } from '../../modules/local/filter_abundance.nf'
include { HEATMAPS } from '../../modules/local/heatmaps.nf'

workflow TAXONOMY {
    take:
    ch_clean
    ch_hclust2

    main:
    ch_versions = Channel.empty()
    METAPHLAN(ch_clean)
    ch_versions = ch_versions.mix(METAPHLAN.out.versions)
    ch_profiles = METAPHLAN.out.profiles
    
    MERGE_ABUNDANCE(ch_profiles.map { it[1] }.collect())
    
    FILTER_ABUNDANCE(MERGE_ABUNDANCE.out.merged_output)

    HEATMAPS(FILTER_ABUNDANCE.out.species_output, FILTER_ABUNDANCE.out.phylum_output, ch_hclust2)
    ch_versions = ch_versions.mix(HEATMAPS.out.versions)
    
    emit:
    METAPHLAN.out.profiles  // Fix: Correct output channel name from profiles
    MERGE_ABUNDANCE.out.merged_output
    FILTER_ABUNDANCE.out.phylum_output
    FILTER_ABUNDANCE.out.species_output
    HEATMAPS.out.species_visual
    HEATMAPS.out.phylum_visual
    versions = ch_versions
}

