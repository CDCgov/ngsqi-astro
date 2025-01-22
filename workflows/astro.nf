nextflow.enable.dsl=2

    /*
    ================================================================================
                                Import Modules/Subworkflows
    ================================================================================
        */
include { INPUT_CHECK } from '../subworkflows/local/input_check.nf'
include { ISOLATES_CHECK } from '../subworkflows/local/isolates_check.nf'
include { PREPROCESSING } from '../subworkflows/local/preprocessing.nf'
include { CONTIGS } from '../subworkflows/local/assembly.nf'
include { AMR } from '../subworkflows/local/arg.nf'
include { TAXONOMY } from '../subworkflows/local/taxonomy.nf'
include { MULTIQC } from '../modules/nf-core/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'
include { REFERENCE } from '../subworkflows/local/reference.nf'
include { SIMULATION } from '../subworkflows/local/simulation.nf'
include { INTEGRATE } from '../subworkflows/local/integrate.nf'
include { TAXONOMY as TAXASIM } from '../subworkflows/local/taxonomy.nf'
include { CONTIGS as CONTIGSIM } from '../subworkflows/local/assembly.nf'
include { AMR as AMRSIM } from '../subworkflows/local/arg.nf'
include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-schema'
/*
    ================================================================================
                                Print Params Summary
    ================================================================================
    */

def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
//def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
//log.info logo + paramsSummaryLog(workflow) + citation

 //WorkflowAstro.initialise(params, log)

/*
    ================================================================================
                                Validate Inputs
    ================================================================================
    */

// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.multiqc_config, params.isolates ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
if (params.isolates) { isolates = file(params.isolates) } else { exit 1, 'Isolate samplesheet not specified!' }
if (params.ncbi_api_key) { ncbi_api_key = params.ncbi_api_key } else { exit 1, 'NCBI API key not specified!' }
if (params.ncbi_email) { ncbi_email = params.ncbi_email } else { exit 1, 'NCBI email not specified!' }

/*
    ================================================================================
                                Config Files
    ================================================================================
    */

ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

/*
    ================================================================================
                                Run Main Workflow
    ================================================================================
    */

def multiqc_report = []

workflow ASTRO {
    
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

/*
    ================================================================================
                                Samplesheet Validation
    ================================================================================
    */
    
    INPUT_CHECK(ch_input)
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)

    ISOLATES_CHECK(isolates)
    ch_versions = ch_versions.mix(ISOLATES_CHECK.out.versions)
/*
    ================================================================================
                                Preprocessing & QC
    ================================================================================
    */

    PREPROCESSING(INPUT_CHECK.out.reads, params.ref, params.hostile_ref)
    ch_versions = ch_versions.mix(PREPROCESSING.out.versions)
    //ch_multiqc_files = ch_multiqc.mix(PREPROCESSING.out.log)
/*
    ================================================================================
                                ASSEMBLY & QC
    ================================================================================
    */
    
   // CONTIGS(PREPROCESSING.out.reads)
   // ch_versions = ch_versions.mix(CONTIGS.out.versions)
    
    /*
    ================================================================================
                                ARG Detection
    ================================================================================
    */

   // databases = ["card", "plasmidfinder", "resfinder"]
   // AMR(CONTIGS.out.contigs, databases, params.amrfinderdb, params.card)
  //  ch_versions = ch_versions.mix(AMR.out.versions)

    /*
    ================================================================================
                               Taxonomic Classification
    ================================================================================
    */
  //  TAXONOMY(PREPROCESSING.out.reads, params.hclust2)
   // ch_versions = ch_versions.mix(TAXONOMY.out.versions)
    
    /*
    ================================================================================
                                Simulation & QC
    ================================================================================
    */
   // REFERENCE(input_data, params.downloadref_script, params.downloadgenome_script, params.ncbi_email, params.ncbi_api_key)
  //  SIMULATION(REFERENCE.out.paired_data, PREPROCESSING.out.ch_readlength)
  //  ch_versions = ch_versions.mix(SIMULATION.out.versions)
    
  //  INTEGRATE(SIMULATION.out.ch_simreads, PREPROCESSING.out.reads)
  //  ch_versions = ch_versions.mix(INTEGRATE.out.versions)

    /*
    ================================================================================
                                Simulation - Taxonomic Classification
    ================================================================================
    */
  //  if (params.postsim) {
   // TAXASIM(INTEGRATE.out.integrated_reads, params.hclust2)
   // ch_versions = ch_versions.mix(TAXASIM.out.versions)
    
    /*
    ================================================================================
                                Simulation - Assembly & QC
    ================================================================================
    */
    //CONTIGSIM(INTEGRATE.out.integrated_reads)
    //ch_versions = ch_versions.mix(CONTIGSIM.out.versions)

    /*
    ================================================================================
                                Simulation - ARG Detection
    ================================================================================
    */

  //  databases = ["card", "plasmidfinder", "resfinder"]
  //  AMRSIM(CONTIGSIM.out.contigs, databases, params.amrfinderdb, params.card)
  //  ch_versions = ch_versions.mix(AMRSIM.out.versions)
  //  }
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
     // MODULE: MultiQC
   // workflow_summary    = WorkflowASTRO.paramsSummaryMultiqc(workflow, summary_params)
   // ch_workflow_summary = Channel.value(workflow_summary)

  //  methods_description    = WorkflowASTRO.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description, params)
  //  ch_methods_description = Channel.value(methods_description)

  //  ch_multiqc_files = Channel.empty()
  //  ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
   // ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
   // ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
  //  ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]}.ifEmpty([]))

 //   MULTIQC (
 //       ch_multiqc_files.collect(),
 //       ch_multiqc_config.toList(),
 //       ch_multiqc_custom_config.toList(),
 //       ch_multiqc_logo.toList()
 //   )
 //   multiqc_report = MULTIQC.out.report.toList()
 //   ch_versions = ch_versions.mix(MULTIQC.out.versions)
}
