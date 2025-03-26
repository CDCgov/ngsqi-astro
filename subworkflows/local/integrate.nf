include { CATCOPYNUMBER } from '../../modules/local/catcopynumber.nf'
include { CATISOLATES } from '../../modules/local/catisolates.nf'
include { CATMETAGENOMICS } from '../../modules/local/catmetagenomics.nf'
include { FASTQC as FASTQC_SIM } from '../../modules/nf-core/fastqc/main'

workflow INTEGRATE {
    take:
    ch_simreads
    reads

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files  = Channel.empty()

    CATCOPYNUMBER(ch_simreads)

    read1_files = CATCOPYNUMBER.out.copynumber_read1.map { id, file -> file }.collect()
    read2_files = CATCOPYNUMBER.out.copynumber_read2.map { id, file -> file }.collect()

    CATISOLATES(read1_files, read2_files)

    CATMETAGENOMICS(CATISOLATES.out.isolates_read1, CATISOLATES.out.isolates_read2, reads)
    integrated_reads = CATMETAGENOMICS.out.integrated_reads

    FASTQC_SIM(integrated_reads)

    ch_versions = ch_versions.mix(FASTQC_SIM.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC_SIM.out.zip)

    emit:
    integrated_reads
    versions = ch_versions
    multiqc = ch_multiqc_files
}