include { MEGAHIT } from '../../modules/local/megahit.nf'
include { RENAME_HEADERS } from '../../modules/local/rename_contigs.nf'
include { QUAST } from '../../modules/local/quast.nf'

workflow CONTIGS {
    take:
    cleaned_reads

    main:

     MEGAHIT(cleaned_reads)
     ch_contigs = MEGAHIT.out.contigs

     RENAME_HEADERS(ch_contigs)
     ch_cleaned_contigs = RENAME_HEADERS.out.renamed_contigs

     QUAST(ch_cleaned_contigs)

     emit:
     ch_cleaned_contigs
    
}
