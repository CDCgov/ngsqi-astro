#!/usr/bin/env nextflow

/*
================================================================================
 In Silico  amr.nf subworkflow:
 Detection of Antimicrobial Resistance Genes (ARGs) in isolate data
================================================================================
*/

 
include {ABRICATE} from '../../modules/local/abricatemod.nf'
include {HARMABRICATE} from '../../modules/local/harm_abricate.nf'
include {AMRFINDERPLUS_UPDATE} from '../../modules/local/amr_db_update.nf'
include {AMRFinder} from '../../modules/local/amrfinderplus.nf'
include {CONCATENATE_REPORTS} from '../../modules/local/concatenate_reports.nf'
include {HARMAmrfinder} from '../../modules/local/harm_amrfinder.nf'
include {HARMRGI} from '../../modules/local/harm_rgi.nf'
include {RGI} from '../../modules/local/rgimod.nf'
include {HARMSUMMARY} from '../../modules/local/harm_summary.nf'

 
   
workflow AMR {
   
    take: 
    ch_samples // input from sample sheet
    databases   // array containing databases
 
 
    main:

    ABRICATE(ch_samples, databases)
    HARMABRICATE(ABRICATE.out.report1, ABRICATE.out.report2, ABRICATE.out.report3, databases)
    AMRFinder(ch_samples)
    HARMAmrfinder(AMRFinder.out)
    RGI(ch_samples)
    HARMRGI(RGI.out)
    HARMSUMMARY( HARMABRICATE.out.harmabr_report1, HARMAmrfinder.out.hamr_amrfinder, HARMRGI.out.harmrgi_report)
    //HARMSUMMARY( HARMABRICATE.out.harmabr_report1, HARMRGI.out.harmrgi_report)


    // Collect all output TSV files into a single channel
    collectedReports = HARMSUMMARY.out.reports.collectFile(name: 'final_combined_report.tsv')

    // Pass the collected reports to the CONCATENATE_REPORTS process
    CONCATENATE_REPORTS(collectedReports)


    emit:
    ABRICATE.out.report1
    ABRICATE.out.report2
    ABRICATE.out.report3
    HARMABRICATE.out.harmabr_report1
    AMRFinder.out
    HARMAmrfinder.out.hamr_amrfinder
    RGI.out
    HARMRGI.out.harmrgi_report
    HARMSUMMARY.out.reports
    CONCATENATE_REPORTS.out
    

}








