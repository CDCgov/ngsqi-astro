include { MEGAHIT } from '../../modules/local/megahit.nf'
include { QUAST } from '../../modules/local/quast.nf'

workflow CONTIGS {
    take:
    reads

    main:
    ch_versions = Channel.empty()

     MEGAHIT(reads)
     ch_contigs = MEGAHIT.out.contigs
     ch_versions = ch_versions.mix(MEGAHIT.out.versions)

     QUAST(ch_contigs)
     ch_versions = ch_versions.mix(QUAST.out.versions)

     emit:
     versions = ch_versions
     ch_contigs
     QUAST.out.quast_report
     contigs = ch_contigs
     quast_report = QUAST.out.quast_report
    
}
