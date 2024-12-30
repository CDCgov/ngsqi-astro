include { MEGAHIT } from '../../modules/nf-core/megahit/main' 
//include { QUAST } from '../../modules/nf-core/quast/main' 
//include { MEGAHIT } from '../../modules/local/megahit.nf'
include { QUAST } from '../../modules/local/quast.nf'

workflow CONTIGS {
    take:
    ch_clean

    main:
    ch_versions = Channel.empty()

     MEGAHIT(ch_clean)
     ch_contigs = MEGAHIT.out.contigs
     ch_versions = ch_versions.mix(MEGAHIT.out.versions)

     QUAST(ch_contigs)
     ch_versions = ch_versions.mix(QUAST.out.versions)

     emit:
     versions = ch_versions
     ch_contigs
     QUAST.out.tsv
     contigs = ch_contigs
     quast_report = QUAST.out.tsv
    
}
