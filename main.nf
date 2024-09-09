#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/* include { TAXONOMY } from './subworkflows/local/taxonomy.nf'

params.outdir = 'results'  // default output directory
params.samplesheet = 'samplesheet.csv'  // default samplesheet

Channel
    .fromPath(params.samplesheet)
    .splitCsv(header: true, sep: ',')
    .map { row -> [row.sample, file(row.fastq_1), file(row.fastq_2)] }
    .set { ch_samples }

workflow {
    TAXONOMY(ch_samples)
}
*/
/*

include {ABRICATE} from '/scicomp/home-pure/uql9/amr-metagenomics/abricatemod.nf'

//move to config file once created (i think)
params.outdir = 'arg_results' //default directory
params.isolate_csv = '/scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate_reference_samplesheet.csv' //samplesheet

Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
	.map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }
	//inputfiles = Channel.fromPath('/scicomp/home-pure/uql9/ARG_subworkflow/isolate_data/GCA_016490125.3/*.fna')
    
 workflow {
    databases = ['card', 'plasmidfinder', 'resfinder']
	ABRICATE(ch_samples, databases) | view { "$it" }
}
*/
/*
include {RGI} from '/scicomp/home-pure/uql9/amr-metagenomics/rgimod.nf'

//move to config file once created (i think)
params.outdir = 'arg_results' //default directory
params.isolate_csv = '/scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate_reference_samplesheet.csv' //samplesheet

Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
	.map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }
	//inputfiles = Channel.fromPath('/scicomp/home-pure/uql9/ARG_subworkflow/isolate_data/GCA_016490125.3/*.fna')
    
 workflow {
	RGI(ch_samples) | view { "$it" }
}

*/
/*

include {RGI} from '/scicomp/home-pure/uql9/amr-metagenomics/rgimod.nf'
include {HARMRGI} from '/scicomp/home-pure/uql9/amr-metagenomics/harm_rgi.nf'

//move to config file once created (i think)
params.outdir = 'arg_results' //default directory
params.isolate_csv = '/scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate_reference_samplesheet.csv' //samplesheet

Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
	.map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }
    //call module and get the output
    
 workflow {
    //define the channel for input data
    RGI{ch_samples }
    HARMRGI {RGI.out.RGI_results}
   //ch_report=RGI().RGI_results
   
   

}
*/

/*

include {ABRICATE} from '/scicomp/home-pure/uql9/amr-metagenomics/abricatemod.nf'
include {HARMABRICATE} from '/scicomp/home-pure/uql9/amr-metagenomics/harm_abricate.nf'


params.outdir = 'arg_results' //default directory
params.isolate_csv = '/scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate_reference_samplesheet.csv' //samplesheet
Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
	.map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }
    //call module and get the output   
 workflow {
    //define the channel for input data
    databases = ['card', 'plasmidfinder', 'resfinder']
    ABRICATE(ch_samples, databases)
    HARMABRICATE{ABRICATE.out.ab_results}
 }
 */
/*
 include {AMRFinder} from '/scicomp/home-pure/uql9/amr-metagenomics/amrfinderplus.nf'

//move to config file once created (i think)
params.outdir = 'arg_results' //default directory
params.isolate_csv = '/scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate_reference_samplesheet.csv' //samplesheet
params.database = '/scicomp/home-pure/uql9/miniconda3/envs/amrfinder/share/amrfinderplus/data/2024-01-31.1'

Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
	.map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }
	//inputfiles = Channel.fromPath('/scicomp/home-pure/uql9/ARG_subworkflow/isolate_data/GCA_016490125.3/*.fna')
    
 workflow {
	AMRFinder(ch_samples) | view { "$it" }
}
*/
/*
include {AMRFinder} from '/scicomp/home-pure/uql9/amr-metagenomics/amrfinderplus.nf'
include {HARMAmrfinder} from '/scicomp/home-pure/uql9/amr-metagenomics/harm_amrfinder.nf'

//move to config file once created (i think)
params.outdir = 'arg_results' //default directory
params.isolate_csv = '/scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate_reference_samplesheet.csv' //samplesheet

Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
	.map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }
    //call module and get the output
    
 workflow {
    //define the channel for input data
    files = AMRFinder(ch_samples)
    //files.view() 
    HARMAmrfinder{AMRFinder.out.amrfinder_results}
 }
 */
 /*
include {ABRICATE} from '/scicomp/home-pure/uql9/amr-metagenomics/abricatemod.nf'
include {HARMABRICATE} from '/scicomp/home-pure/uql9/amr-metagenomics/harm_abricate.nf'
include {AMRFinder} from '/scicomp/home-pure/uql9/amr-metagenomics/amrfinderplus.nf'
include {HARMSUMMARY} from '/scicomp/home-pure/uql9/amr-metagenomics/harm_summary.nf'
include {HARMAmrfinder} from '/scicomp/home-pure/uql9/amr-metagenomics/harm_amrfinder.nf'
include {HARMRGI} from '/scicomp/home-pure/uql9/amr-metagenomics/harm_rgi.nf'
include {RGI} from '/scicomp/home-pure/uql9/amr-metagenomics/rgimod.nf'

//move to config file once created
params.outdir = 'arg_results' //default directory
params.isolate_csv = '/scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate_reference_samplesheet.csv' //samplesheet
//params.harmamr = '/scicomp/home-pure/uql9/amr-metagenomics/arg_results/harmamrfinder/*.tsv'
params.harmrgi = '/scicomp/home-pure/uql9/amr-metagenomics/arg_results/harmrgi/*.tsv'
params.hamronize_abricate = '/scicomp/home-pure/uql9/amr-metagenomics/abricatemod.nf/*.tsv'
Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
	.map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }
    //call module and get the output

//Channel
   //.fromPath(params.harmrgi)
    //.set{ harmrgi_ch }
    
Channel
   .fromPath(params.hamronize_abricate)
   .set{ ch_hamrabricate }
//channel_harmrgi=params.harmrgi

 workflow {
    databases = ['card', 'plasmidfinder', 'resfinder']
    ABRICATE(ch_samples, databases)
    HARMABRICATE{ABRICATE.out.ab_results}
   // RGI{ch_samples }
    //HARMRGI {RGI.out.RGI_results}
    //AMRFinder(ch_samples)
    //HARMAmrfinder{AMRFinder.out.amrfinder_results}
    HARMSUMMARY(HARMABRICATE.out.tsv)
 }
 */

// This main.nf file is a work in progress. Please no judgment
include {AMR} from './subworkflows/local/arg.nf'
 
params.outdir = 'arg_results' //default directory
params.isolate_csv = '/scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate_reference_samplesheet.csv' //samplesheet
 
 
Channel
    .fromPath(params.isolate_csv)
    .splitCsv(header: true, sep: ',')
    .map{row -> [row.sample, row.refseq] }
    .set{ ch_samples }

 
workflow {
 
    databases = ['card', 'plasmidfinder', 'resfinder']
    AMR(ch_samples, databases)
   
   
}
