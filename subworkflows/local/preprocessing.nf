#!/usr/bin/env nextflow

include { FASTQC } from '../../modules/local/fastqc.nf'
include { FASTQC_CLEAN } from '../../modules/local/fastqc_clean.nf'
include { FASTP } from '../../modules/local/fastp.nf'
include { BBDUK } from '../../modules/local/bbduk.nf'
include { HOSTILE } from '../../modules/local/hostile.nf'

workflow PREPROCESSING {
    take:
    ch_reads // channel: [ val(sampleID), [reads] ]
    ch_ref // channel: PHIX.fasta
    ch_hostile_ref // channel: hostile reference

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files  = Channel.empty()

    FASTQC(ch_reads)
    ch_versions = ch_versions.mix(FASTQC.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip)
    ch_readlength=FASTQC.out.read_length

    FASTP(ch_reads)
    ch_trimmed = FASTP.out.trimmed_reads
    ch_versions = ch_versions.mix(FASTP.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.log)

    BBDUK(ch_trimmed, ch_ref)
    ch_decon = BBDUK.out.decon_reads
    ch_versions = ch_versions.mix(BBDUK.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(BBDUK.out.log)

    HOSTILE(ch_decon, ch_hostile_ref)
    ch_clean = HOSTILE.out.clean_reads
    ch_versions = ch_versions.mix(HOSTILE.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(HOSTILE.out.log)

    FASTQC_CLEAN(ch_clean)
    clean_reports = FASTQC_CLEAN.out.reports
    ch_versions = ch_versions.mix(FASTQC_CLEAN.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC_CLEAN.out.zip)

    emit:
    FASTQC.out.reports
    clean_reports
    ch_readlength
    ch_trimmed
    ch_decon
    reads = ch_clean
    versions = ch_versions
    multiqc = ch_multiqc_files
}

