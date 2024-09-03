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
    FASTQC(ch_reads)

    FASTP(ch_reads)
    ch_trimmed = FASTP.out.trimmed_reads

    BBDUK(ch_trimmed, ch_ref)
    ch_decon = BBDUK.out.decon_reads

    HOSTILE(ch_decon, ch_hostile_ref)
    ch_clean = HOSTILE.out.clean_reads

    emit:
    FASTQC.out.reports
    FASTP.out.trimmed_reads
    BBDUK.out.decon_reads
    HOSTILE.out.clean_reads
}

