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
    ch_versions

    main:

    FASTQC(ch_reads)
    ch_versions = ch_versions.mix(FASTQC.out.versions)


    FASTP(ch_reads)
    ch_trimmed = FASTP.out.trimmed_reads
    ch_versions = ch_versions.mix(FASTP.out.versions)

    BBDUK(ch_trimmed, ch_ref)
    ch_decon = BBDUK.out.decon_reads
    ch_versions = ch_versions.mix(BBDUK.out.versions)

    HOSTILE(ch_decon, ch_hostile_ref)
    ch_clean = HOSTILE.out.clean_reads
    ch_versions = ch_versions.mix(HOSTILE.out.versions)
    
    emit:
    FASTQC.out.reports
    ch_trimmed
    ch_decon
    reads = ch_clean
    versions = ch_versions
}

