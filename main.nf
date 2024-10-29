#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//include { custom_dumpsoftwareversions } from './modules/nf-core/custom/dumpsoftwareversions/main'
include {PREPROCESSING} from './subworkflows/local/preprocessing.nf'
include {CONTIGS} from './subworkflows/local/assembly.nf'
include {TAXONOMY} from './subworkflows/local/taxonomy.nf'
include {REFERENCE} from './subworkflows/local/reference.nf'
include {SIMULATION} from './subworkflows/local/simulation.nf'
include {INTEGRATE} from './subworkflows/local/integrate.nf'

params.hostile_ref = "$projectDir/assets/references/human-t2t-hla.argos-bacteria-985_rs-viral-202401_ml-phage-202401"
params.ref = "$projectDir/assets/references/phiX.fasta"
params.hclust2 = "$projectDir/third_party/hclust2.py"
params.samplesheet = 'samplesheet.csv'  // default samplesheet
params.input_isolates = "$projectDir/data/isolates_input_26_copynumber.csv"
params.input_metagenomics = "$projectDir/data/metagenomics_samplesheet.csv"
params.downloadref_script = "$projectDir/scripts/download_ref.py"
params.downloadgenome_script = "$projectDir/scripts/download_genome.py"
params.ncbi_email = null
params.ncbi_api_key = null


Channel
    .fromPath(params.samplesheet)
    .splitCsv(header: true, sep: ',')
    .map { row -> [row.sample, file(row.fastq_1), file(row.fastq_2)] }
    .set { ch_reads }

ch_hostile_ref = params.hostile_ref

ch_ref = params.ref
ch_hclust2 = params.hclust2

Channel
    .fromPath(params.input_isolates)
    .splitCsv(header: true, sep: ',')
    .map { row -> tuple(row.sample_id, row.added_copy_number, file(row.file_path), row.species_name) }
    .set { input_data }

//Channel
//    .fromPath(params.input_metagenomics)
//   .splitCsv(header: true, sep: ',')
//    .map { row -> tuple(row.sample_id, file(row.read_1), file(row.read_2)) }
//    .set { input_meta }


workflow {
    PREPROCESSING(ch_reads, ch_ref, ch_hostile_ref)
    CONTIGS(PREPROCESSING.out.reads)
    TAXONOMY(PREPROCESSING.out.reads, ch_hclust2)
    REFERENCE(input_data,params.downloadref_script,params.downloadgenome_script,params.ncbi_email,params.ncbi_api_key)
    SIMULATION(REFERENCE.out.ch_ref,PREPROCESSING.out.ch_readlength)
    INTEGRATE(SIMULATION.out.ch_simreads,PREPROCESSING.out.reads)
}




