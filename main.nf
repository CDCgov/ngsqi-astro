#!/usr/bin/env nextflow

nextflow.enable.dsl=2
include {FASTQC} from './modules/local/fastqc.nf'
include {FASTP} from './modules/local/fastp.nf'
include {BBDUK} from './modules/local/bbduk.nf'
include {HOSTILE} from './modules/local/hostile.nf'

params.outdir = 'results'  // default output directory
params.reads = 'assets/data/*_{1,2}.fastq.gz'  // default input reads pattern
params.ref = "./assets/references/human-t2t-hla.argos-bacteria-985_rs-viral-202401_ml-phage-202401" // add this line

Channel
    .fromFilePairs( params.reads, size: 2 )
    .set { ch_reads }

Channel
    .fromPath('./assets/references/phiX.fasta')
    .set { ch_ref } // changed refGenome to ch_ref

Channel
    .fromPath(params.ref) 
    .set { ch_hostile_ref } 

workflow {
    FASTQC(ch_reads)
    FASTP(ch_reads)
    BBDUK(ch_reads, ch_ref)
    HOSTILE(ch_reads, ch_hostile_ref)
}
