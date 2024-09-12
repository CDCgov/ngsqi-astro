#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//include { custom_dumpsoftwareversions } from './modules/nf-core/custom/dumpsoftwareversions/main
include {PREPROCESSING} from './subworkflows/local/preprocessing.nf'
include {CONTIGS} from './subworkflows/local/assembly.nf'
//include { TAXONOMY } from './subworkflows/local/taxonomy.nf'

params.hostile_ref = "$projectDir/assets/references/human-t2t-hla.argos-bacteria-985_rs-viral-202401_ml-phage-202401"
params.ref = "$projectDir/assets/references/phiX.fasta"

params.samplesheet = 'samplesheet.csv'  // default samplesheet

Channel
    .fromPath(params.samplesheet)
    .splitCsv(header: true, sep: ',')
    .map { row -> [row.sample, file(row.fastq_1), file(row.fastq_2)] }
    .set { ch_reads }



ch_hostile_ref = params.hostile_ref

ch_ref = params.ref



workflow {
    PREPROCESSING(ch_reads, ch_ref, ch_hostile_ref)
    CONTIGS(PREPROCESSING.out.reads)
    //TAXONOMY(processed_reads)
}
