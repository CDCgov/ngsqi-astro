include { MEGAHIT } from '../../modules/nf-core/megahit/main' 
include { QUAST } from '../../modules/local/quast.nf'

workflow CONTIGS {
    take:
    ch_clean  // channel: [ val(sampleID), [reads] ]

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files  = Channel.empty()

     MEGAHIT(ch_clean)
     ch_contigs = MEGAHIT.out.contigs
     ch_versions = ch_versions.mix(MEGAHIT.out.versions)

     QUAST(ch_contigs)
     ch_versions = ch_versions.mix(QUAST.out.versions)
     ch_multiqc_files = ch_multiqc_files.mix(QUAST.out.tsv)

     emit:
     versions = ch_versions
     contigs = ch_contigs
     quast_report = QUAST.out.tsv
     multiqc = ch_multiqc_files
    
}
