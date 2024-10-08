// Modules for integration
include { catcopynumber } from '../../modules/local/catcopynumber.nf'
include { catisolates } from '../../modules/local/catisolates.nf'
include { catmetagenomics } from '../../modules/local/catmetagenomics.nf'

workflow INTEGRATE {
    take:
    ch_simreads
    reads

    main:
    catcopynumber(ch_simreads)
    catisolates(catcopynumber.out.copynumber_read1.collect(),catcopynumber.out.copynumber_read2.collect())
    catmetagenomics(reads,catisolates.out.isolates_read1,catisolates.out.isolates_read2)

    ch_catmetaR1=catmetagenomics.out.catmetagenomics_read1
    ch_catmetaR2=catmetagenomics.out.catmetagenomics_read2

    emit:
    ch_catmetaR1
    ch_catmetaR2
}