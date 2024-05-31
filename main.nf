#!/usr/bin/env nextflow

nextflow.enable.dsl=2
include { TAXONOMY } from './subworkflows/local/taxonomy.nf'

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
