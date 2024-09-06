#!/usr/bin/env nextflow

/*
================================================================================
 In Silico  amr.nf subworkflow:
 Detection of Antimicrobial Resistance Genes (ARGs) in isolate data
================================================================================
*/

 
include {ABRICATE} from '/scicomp/home-pure/uql9/amr-metagenomics/abricatemod.nf'
include {HARMABRICATE} from '/scicomp/home-pure/uql9/amr-metagenomics/harm_abricate.nf'
include {AMRFinder} from '/scicomp/home-pure/uql9/amr-metagenomics/amrfinderplus.nf'
include {HARMAmrfinder} from '/scicomp/home-pure/uql9/amr-metagenomics/harm_amrfinder.nf'
include {HARMRGI} from '/scicomp/home-pure/uql9/amr-metagenomics/harm_rgi.nf'
include {RGI} from '/scicomp/home-pure/uql9/amr-metagenomics/rgimod.nf'
include {CATFILES} from '/scicomp/home-pure/uql9/amr-metagenomics/join_files.nf'
 
   
workflow AMR {
   
    take: 
    ch_samples
    databases
 
 
    main:
    ABRICATE(ch_samples, databases)
    HARMABRICATE(ABRICATE.out)
    CATFILES(HARMABRICATE.out)
    //AMRFinder(ch_samples)
    //HARMAmrfinder(AMRFinder.out)
    //RGI(ch_samples)
    //HARMRGI(RGI.out)

 
    emit:
    ABRICATE.out
    HARMABRICATE.out
    CATFILES.out
    
    //AMRFinder.out
    //HARMAmrfinder.out
    //RGI.out
    //HARMRGI.out
}
workflow {
    Channel
        fromPath('HARMABRICATE.out/*')
        .map {file -> [file.baseName.split('_')[0], file]}
        .groupTuple()
        .set { grouped_files }

    joinFiles(grouped_files)
}








