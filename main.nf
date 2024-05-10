#!/usr/bin/env nextflow

nextflow.enable.dsl=2
include { FASTQC } from './modules/nf-core/modules/fastqc/main'
include {metaphlan} from './modules/local/metaphlan.nf'

params.outdir = 'results'  // default output directory
params.reads = 'assets/data/*_{1,2}.fastq.gz'  // default input reads pattern

Channel
    .fromFilePairs( params.reads, size: 2 )
    .set { ch_reads }

workflow {
    metaphlan(ch_reads)
}
