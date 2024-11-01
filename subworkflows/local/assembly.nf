include { MEGAHIT } from '../../modules/local/megahit.nf'
include { QUAST } from '../../modules/local/quast.nf'

workflow CONTIGS {
    take:
    reads

    main:
    
     MEGAHIT(reads)
     ch_contigs = MEGAHIT.out.contigs

     QUAST(ch_contigs)

     emit:
     contigs = ch_contigs
     quast_report = QUAST.out.quast_report
    
}
