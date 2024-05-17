#!/usr/bin/env nextflow

nextflow.enable.dsl=2
//include {FASTQC} from './modules/local/fastqc.nf'
//include {FASTP} from './modules/local/fastp.nf'
include {BBDUK} from './modules/local/bbduk.nf'
//include {hostile} from './modules/local/hostile.nf'


params.outdir = 'results'  // default output directory
params.reads = 'assets/data/*_{1,2}.fastq.gz'  // default input reads pattern

Channel
    .fromFilePairs( params.reads, size: 2 )
    .set { ch_reads }

Channel
    .fromPath('./assets/references/phiX.fasta')
    .set {refGenome}
    
workflow {
    //FASTQC(ch_reads)
    //FASTP(ch_reads)
    BBDUK(ch_reads)
   // HOSTILE(ch_reads)
}
