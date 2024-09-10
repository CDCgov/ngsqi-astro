#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {metaphlan} from '../../modules/local/metaphlan.nf'
include {merge_abundance} from '../../modules/local/merge_abundance.nf'
include {filter_abundance} from '../../modules/local/filter_abundance.nf'
include {heatmaps} from '../../modules/local/heatmaps.nf'

workflow TAXONOMY {
    take:
    ch_samples

    main:
    metaphlan(ch_samples)
    metaphlan.out.profile.view()
    
    // Debugging: Print profiles
    metaphlan.out.profile.map { it[1] }.collect().view { "Profiles: ${it}" }
    
    merge_abundance(metaphlan.out.profile.map { it[1] }.collect())
    
    // Debugging: Print merged output
    merge_abundance.out.merged_output.view { "Merged Output: ${it}" }
    
    filter_abundance(merge_abundance.out.merged_output)
    
    // Debugging: Print phylum output
    filter_abundance.out.phylum_output.view { "Phylum Output: ${it}" }
    
    //Debugging: Print species output
    filter_abundance.out.species_output.view { "Species Output: ${it}" }

    heatmaps(filter_abundance.out.species_output, filter_abundance.out.phylum_output)

    //Debugging: Print species visual
    heatmaps.out.species_visual.view { "Species Visual: ${it}" }

    //Debugging: Print phylum visual
    heatmaps.out.phylum_visual.view { "Phylum Visual: ${it}" }
    
    emit:
    metaphlan.out.profile
    merge_abundance.out.merged_output
    filter_abundance.out.phylum_output
    filter_abundance.out.species_output
    heatmaps.out.species_visual
    heatmaps.out.phylum_visual
}
