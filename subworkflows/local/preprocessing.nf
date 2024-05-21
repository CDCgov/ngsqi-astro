#!/usr/bin/env nextflow
nextflow.enable.dsl=2
params.reads = './samplesheet.csv'

include {FASTQC} from '../../modules/local/fastqc.nf'
include {FASTP} from '../../modules/local/fastp.nf'
include {BBDUK} from '../../modules/local/bbduk.nf'
include {HOSTILE} from '../../modules/local/hostile.nf'

workflow PREPROCESSING {
    take:
    ch_reads
    ch_ref
    ch_hostile_ref

    main:
    //FASTQC: QC on raw reads
    FASTQC(ch_reads)

    //FASTP: Filtering, adapter trimming, read correction on raw reads
   // FASTP(ch_reads)
   // ch_fastp_reads = FASTP.out.reads.collect()

    //BBDUK: PhiX read decontamination - takes output from FastP
    //BBDUK(ch_fastp_reads, ch_ref) // pass the tuple to BBDUK
    //ch_bbduk_reads = BBDUK.out.cleaned_reads1.findAll { it.toString().endsWith('.fq.gz') || it.toString().endsWith('.fastq.gz') }

    //HOSTILE: Host read decontamination - takes output from BBDuk
    //HOSTILE(ch_bbduk_reads, ch_hostile_ref) // pass the tuple to HOSTILE

    emit:
    FASTQC.out.fastqc_output
    //HOSTILE.out.hostile_output
}
