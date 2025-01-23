include { FASTQC } from '../../modules/nf-core/fastqc/main' 
include { FASTQC as FASTQC_CLEAN } from '../../modules/nf-core/fastqc/main'
include { EXTRACT_READ_LENGTH } from '../../modules/local/read_lengths.nf'
include { FASTP } from '../../modules/local/fastp.nf'
include { BBMAP_BBDUK as BBDUK } from '../../modules/nf-core/bbmap/bbduk/main'
include { HOSTILE } from '../../modules/local/hostile.nf'

workflow PREPROCESSING {
    take:
    ch_reads // channel: [ val(sampleID), [reads] ]
    ref // channel: PHIX.fasta
    hostile_ref // channel: hostile reference

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files  = Channel.empty()

    FASTQC(ch_reads)
    ch_versions = ch_versions.mix(FASTQC.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip)

    FASTP(ch_reads)
    ch_trimmed = FASTP.out.trimmed_reads
    ch_versions = ch_versions.mix(FASTP.out.versions)

    BBDUK(ch_trimmed, ref)
    ch_decon = BBDUK.out.reads
    ch_versions = ch_versions.mix(BBDUK.out.versions)

    HOSTILE(ch_decon, hostile_ref)
    ch_clean = HOSTILE.out.clean_reads
    ch_versions = ch_versions.mix(HOSTILE.out.versions)

    FASTQC_CLEAN(ch_clean)
    ch_versions = ch_versions.mix(FASTQC_CLEAN.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC_CLEAN.out.zip)
    fastqc_zip = FASTQC_CLEAN.out.zip

    EXTRACT_READ_LENGTH(FASTQC_CLEAN.out.zip)
    ch_readlength=EXTRACT_READ_LENGTH.out.read_length

    emit:
    ch_trimmed
    ch_decon
    reads = ch_clean
    fastqc_zip
    ch_readlength
    versions = ch_versions
    multiqc = ch_multiqc_files
}

