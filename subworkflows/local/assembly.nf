include { MEGAHIT } from '../../modules/local/megahit.nf'
include { QUAST } from '../../modules/local/quast.nf'

workflow CONTIGS {
    take:
    reads

    main:
    reads
    .view()

     MEGAHIT(reads)
     ch_contigs = MEGAHIT.out.contigs

     QUAST(ch_contigs)

     emit:
     ch_contigs
     QUAST.out.quast_report
    
}
