#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { PREPROCESSING } from './subworkflows/local/preprocessing.nf'
include { CONTIGS } from './subworkflows/local/assembly.nf'
include {AMR} from './subworkflows/local/arg.nf'
include { TAXONOMY } from './subworkflows/local/taxonomy.nf'
//include { MULTIQC } from './modules/nf-core/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from './modules/nf-core/custom/dumpsoftwareversions/main'
include { REFERENCE } from './subworkflows/local/reference.nf'
include { SIMULATION } from './subworkflows/local/simulation.nf'
include { INTEGRATE } from './subworkflows/local/integrate.nf'
include { TAXONOMY as TAXASIM} from './subworkflows/local/taxonomy.nf'
include { CONTIGS as CONTIGSIM } from './subworkflows/local/assembly.nf'
include {AMR as AMRSIM} from './subworkflows/local/arg.nf'
include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

params.hostile_ref = "$projectDir/assets/references/human-t2t-hla.argos-bacteria-985_rs-viral-202401_ml-phage-202401"
params.ref = "$projectDir/assets/references/phiX.fasta"
params.hclust2 = "$projectDir/third_party/hclust2.py"
params.input = null
params.input_isolates = "/scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/isolate_test_2.csv"
params.downloadref_script = "$projectDir/scripts/download_ref.py"
params.downloadgenome_script = "$projectDir/scripts/download_genome.py"
params.multiqc_config = "$projectDir/assets/multiqc_config.yml"
params.custom_multiqc_config = "$projectDir/assets/custom_multiqc_config.yml"
params.ncbi_email = null
params.ncbi_api_key = null
params.mode = 'download' // Default to download mode
params.amrfinderdb = "${baseDir}/assets/2024-07-22.1/" 
params.card = "${baseDir}/assets/card/"
params.databases = ["card", "plasmidfinder", "resfinder"]

Channel
    .fromPath(params.samplesheet)
    .splitCsv(header: true, sep: ',')
    .map { row ->
        tuple([id: row.sample], [file(row.fastq_1), file(row.fastq_2)])
    }
    .set { ch_reads }


ch_hostile_ref = params.hostile_ref
ch_ref = params.ref
ch_hclust2 = params.hclust2
ch_multiqc_config = Channel.fromPath(params.multiqc_config)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()
amrfinderdb = params.amrfinderdb
card = params.card

Channel
    .fromPath(params.isolates)
    .splitCsv(header: true, sep: ',')
    .map { row -> 
        tuple(
            row.sample_id,
            row.added_copy_number,
            row.file_path,
            row.species_name
        ) 
    }
    .set { input_data }

// Validate input parameters
validateParameters()

// Print summary of supplied parameters
log.info paramsSummaryLog(workflow)

def multiqc_report = []

workflow {
    
    ch_versions = Channel.empty()

/*
    ================================================================================
                                Preprocessing & QC
    ================================================================================
    */

    PREPROCESSING(ch_reads, ch_ref, ch_hostile_ref)
    ch_versions = ch_versions.mix(PREPROCESSING.out.versions)

/*
    ================================================================================
                                ASSEMBLY & QC
    ================================================================================
    */
    
    CONTIGS(PREPROCESSING.out.reads)
    ch_versions = ch_versions.mix(CONTIGS.out.versions)
    
        /*
    ================================================================================
                                ARG Detection
    ================================================================================
    */

    databases = ["card", "plasmidfinder", "resfinder"]
    AMR(CONTIGS.out.contigs, databases, amrfinderdb, card)
    ch_versions = ch_versions.mix(AMR.out.versions)

    /*
    ================================================================================
                               Taxonomic Classification
    ================================================================================
    */
    TAXONOMY(PREPROCESSING.out.reads, ch_hclust2)
    ch_versions = ch_versions.mix(TAXONOMY.out.versions)
    
       /*
    ================================================================================
                                Simulation & QC
    ================================================================================
    */
    REFERENCE(input_data, params.downloadref_script,params.downloadgenome_script, params.ncbi_email, params.ncbi_api_key)
    SIMULATION(REFERENCE.out.isolate_data, REFERENCE.out.ref_data, PREPROCESSING.out.ch_readlength)
    ch_versions = ch_versions.mix(SIMULATION.out.versions)
    
    INTEGRATE(SIMULATION.out.ch_simreads, PREPROCESSING.out.reads)
    ch_versions = ch_versions.mix(INTEGRATE.out.versions)

    /*
    ================================================================================
                                Simulation - Taxonomic Classification
    ================================================================================
    */
    TAXASIM(INTEGRATE.out.integrated_reads, ch_hclust2)
    ch_versions = ch_versions.mix(TAXASIM.out.versions)
    
        /*
    ================================================================================
                                Simulation - Assembly & QC
    ================================================================================
    */
    CONTIGSIM(INTEGRATE.out.integrated_reads)
    ch_versions = ch_versions.mix(CONTIGSIM.out.versions)

    /*
    ================================================================================
                                Simulation - ARG Detection
    ================================================================================
    */

    databases = ["card", "plasmidfinder", "resfinder"]
    AMRSIM(CONTIGSIM.out.contigs, databases, amrfinderdb, card)
    ch_versions = ch_versions.mix(AMRSIM.out.versions)

    /*
    ================================================================================
                                Versions Reports
    ================================================================================
    */
    ch_versions_unique = ch_versions.unique()
    CUSTOM_DUMPSOFTWAREVERSIONS(ch_versions_unique.collectFile(name: 'collated_versions.yml'))
    
    /*
    ================================================================================
                                MultiQC
    ================================================================================
    */

    //Still debugging Multiqc
    //workflow_summary = paramsSummaryLog(workflow)
    //ch_workflow_summary = Channel.value(workflow_summary)
    
    //ch_multiqc_files = Channel.empty()
    //ch_multiqc_files = ch_multiqc_files.mix(ch_multiqc_config)
    //ch_multiqc_files = ch_multiqc_files.mix(ch_multiqc_custom_config.collect().ifEmpty([]))
    //ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    //ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    //ch_multiqc_files = ch_multiqc_files.mix(PREPROCESSING.out.multiqc.collect{it[1]}.ifEmpty([]))

    //MULTIQC(ch_multiqc_files.collect())

    //multiqc_report = MULTIQC.out.report.toList()
    //ch_versions = ch_versions.mix(MULTIQC.out.versions)
}
