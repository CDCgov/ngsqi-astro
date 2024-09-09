#!/usr/bin/env nextflow

/*
================================================================================
 In Silico  amr.nf subworkflow:
 Detection of Antimicrobial Resistance Genes (ARGs) in isolate data
================================================================================
*/

 
include {ABRICATE} from '../../modules/local/abricatemod.nf'
include {HARMABRICATE} from '../../modules/local/harm_abricate.nf'
include {AMRFinder} from '../../modules/local/amrfinderplus.nf'
//include {HARMAmrfinder} from '../../modules/local/harm_amrfinder.nf'
//include {HARMRGI} from '../../modules/local/harm_rgi.nf'
//include {RGI} from '../../modules/local/rgimod.nf'
//include {CATFILES} from '../../modules/local/join_files.nf'
 
   
workflow AMR {
   
    take: 
    ch_samples // input from sample sheet
    databases   // array containing databases
 
 
    main:
    ABRICATE(ch_samples, databases)
    HARMABRICATE(ABRICATE.out)
    //CATFILES(HARMABRICATE.out)
    //AMRFinder(ch_samples)
    //HARMAmrfinder(AMRFinder.out)
    //RGI(ch_samples)
    //HARMRGI(RGI.out)

 
    emit:
    ABRICATE.out
    HARMABRICATE.out
    //CATFILES.out
    
    //AMRFinder.out
    //HARMAmrfinder.out
    //RGI.out
    //HARMRGI.out
}

// This workflow is designed to concatonate the output files from HARMABRICATE
//Currently under construction 

workflow {
    Channel
        fromPath('HARMABRICATE.out/*')
        .map {file -> [file.baseName.split('_')[0], file]}
        .groupTuple()
        .set { grouped_files }

    joinFiles(grouped_files)
}








