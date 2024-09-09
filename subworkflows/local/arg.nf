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
//include {CONCATENATE_REPORTS} from '../../modules/local/concatenate_reports.nf'
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
    HARMABRICATE(ABRICATE.out.report1, ABRICATE.out.report2, ABRICATE.out.report3, databases)

    //CONCATENATE_REPORTS(HARMABRICATE.out.harmabr_report1, HARMABRICATE.out.harmabr_report2, HARMABRICATE.out.harmabr_report3, databases)

    //CATFILES(HARMABRICATE.out)
    //AMRFinder(ch_samples)
    //HARMAmrfinder(AMRFinder.out)
    //RGI(ch_samples)
    //HARMRGI(RGI.out)

 
    emit:
    ABRICATE.out.report1
    ABRICATE.out.report2
    ABRICATE.out.report3
    HARMABRICATE.out.harmabr_report1
   // HARMABRICATE.out.harmabr_report2
   // HARMABRICATE.out.harmabr_report3
   // CONCATENATE_REPORTS.out
    //CATFILES.out
    
    //AMRFinder.out
    //HARMAmrfinder.out
    //RGI.out
    //HARMRGI.out
}








