// Modules for integration
include { catcopynumber } from '../../modules/local/catcopynumber.nf'
include { catisolates } from '../../modules/local/catisolates.nf'
include { catmetagenomics } from '../../modules/local/catmetagenomics.nf'
include { FASTQC as FASTQC_SIM } from '../../modules/nf-core/fastqc/main'

workflow INTEGRATE {
    take:
    ch_simreads
    reads

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files  = Channel.empty()

    catcopynumber(ch_simreads)

    catisolates(catcopynumber.out.copynumber_read1.collect(),catcopynumber.out.copynumber_read2.collect())

    catmetagenomics(reads,catisolates.out.isolates_read1,catisolates.out.isolates_read2)
    ch_catmetaR1=catmetagenomics.out.catmetagenomics_read1
    ch_catmetaR2=catmetagenomics.out.catmetagenomics_read2

    FASTQC_SIM(catmetagenomics.out.catmetagenomics_read1,catmetagenomics.out.catmetagenomics_read1)
    ch_versions = ch_versions.mix(FASTQC_SIM.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC_SIM.out.zip)

    emit:
    ch_catmetaR1
    ch_catmetaR2
    versions = ch_versions
    multiqc = ch_multiqc_files
}
}