#!/usr/bin/env nextflow

include { FASTQC } from '../../modules/local/fastqc.nf'
include { FASTP } from '../../modules/local/fastp.nf'
include { BBDUK } from '../../modules/local/bbduk.nf'
include { HOSTILE } from '../../modules/local/hostile.nf'

workflow PREPROCESSING {
    take:
    ch_reads // channel: [ val(sampleID), [reads] ]
    ch_ref // channel: PHIX.fasta
    ch_hostile_ref // channel: hostile reference

    main:
    ch_reads
    .view()

    FASTQC(ch_reads)

    FASTP(ch_reads)
    ch_trimmed = FASTP.out.trimmed_reads
    
    ch_trimmed
    .view()

    BBDUK(ch_trimmed, ch_ref)
    ch_decon = BBDUK.out.decon_reads

    ch_decon
    .view()

    HOSTILE(ch_decon, ch_hostile_ref)
    ch_clean = HOSTILE.out.clean_reads

    ch_clean
    .view()
    
    emit:
    FASTQC.out.reports
    ch_trimmed
    ch_decon
    ch_clean
}

