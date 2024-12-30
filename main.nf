#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { PREPROCESSING } from './subworkflows/local/preprocessing.nf'
include { CONTIGS } from './subworkflows/local/assembly.nf'
//include {AMR} from './subworkflows/local/arg.nf'
include { TAXONOMY } from './subworkflows/local/taxonomy.nf'
//include { MULTIQC } from './modules/nf-core/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from './modules/nf-core/custom/dumpsoftwareversions/main'
//include { REFERENCE } from './subworkflows/local/reference.nf'
//include { SIMULATION } from './subworkflows/local/simulation.nf'
//include { INTEGRATE } from './subworkflows/local/integrate.nf'
include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

params.hostile_ref = "$projectDir/assets/references/human-t2t-hla.argos-bacteria-985_rs-viral-202401_ml-phage-202401"
params.ref = "$projectDir/assets/references/phiX.fasta"
params.hclust2 = "$projectDir/third_party/hclust2.py"
params.samplesheet = "$projectDir/samplesheet.csv"  // default samplesheet
params.input_isolates = "$projectDir/data/isolates_input_26_copynumber.csv"
params.downloadref_script = "$projectDir/scripts/download_ref.py"
params.downloadgenome_script = "$projectDir/scripts/download_genome.py"
params.multiqc_config = "$projectDir/assets/multiqc_config.yml"
params.custom_multiqc_config = "$projectDir/assets/custom_multiqc_config.yml"
params.ncbi_email = null
params.ncbi_api_key = null
params.amrfinderplus = "${baseDir}/assets/AMR_CDS.fasta" 

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

Channel
    .fromPath(params.input_isolates)
    .splitCsv(header: true, sep: ',')
    .map { row -> tuple(row.sample_id, row.added_copy_number, file(row.file_path), row.species_name) }
    .set { input_data }

// Validate input parameters
validateParameters()

// Print summary of supplied parameters
log.info paramsSummaryLog(workflow)

// Create a new channel of metadata from a sample sheet passed to the pipeline through the --input parameter
ch_input = Channel.fromList(samplesheetToList(params.input, "assets/schema_input.json"))

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

    //databases = ["card", "plasmidfinder", "resfinder"]
    //AMR(CONTIGS.out.contigs, databases)
    //ch_versions = ch_versions.mix(AMR.out.versions)

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
    // REFERENCE(input_data, params.downloadref_script, params.downloadgenome_script, params.ncbi_email, params.ncbi_api_key)
    // SIMULATION(REFERENCE.out.ch_ref, PREPROCESSING.out.ch_readlength)
   // ch_versions = ch_versions.mix(SIMULATION.out.versions)
    // INTEGRATE(SIMULATION.out.ch_simreads, PREPROCESSING.out.reads)

    /*
    ================================================================================
                                Versions Reports
    ================================================================================
    */
    // Generate versions report
    ch_versions_unique = ch_versions.unique()
    CUSTOM_DUMPSOFTWAREVERSIONS(ch_versions_unique.collectFile(name: 'collated_versions.yml'))
        //CUSTOM_DUMPSOFTWAREVERSIONS (ch_versions.unique().collectFile(name: 'collated_versions.yml'))
    
    /*
    ================================================================================
                                MultiQC
    ================================================================================
    */

    // Run MultiQC
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
