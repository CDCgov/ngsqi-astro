#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {metaphlan} from '../../modules/local/metaphlan.nf'

workflow TAXONOMY {
    take:
    ch_samples // channel: [ val(sampleID), [reads] ]
    

    main:
    metaphlan(ch_samples)
   
    emit:
    metaphlan.out.profile
}