include { ABRICATE_RUN as ABRICATE } from '../../modules/nf-core/abricate/run/main'
include { RGI_MAIN as RGI } from '../../modules/nf-core/rgi/main'
include { AMRFINDERPLUS_RUN as AMRFINDERPLUS } from '../../modules/nf-core/amrfinderplus/run/main'
include { HAMRONIZATION_ABRICATE } from '../../modules/nf-core/hamronization/abricate/main.nf'
include { HAMRONIZATION_AMRFINDERPLUS } from '../../modules/nf-core/hamronization/amrfinderplus'
include { HAMRONIZATION_RGI } from '../../modules/nf-core/hamronization/rgi'
include { HAMRONIZATION_SUMMARIZE } from '../../modules/nf-core/hamronization/summarize.nf'

workflow AMR {

    take:
    contigs
    megares
    resfinder
    plasmidfinder
    card
    amrfinderdb

    main:
    ch_versions = Channel.empty()
    ch_hamronization_input = Channel.empty()
    ch_hamronization_summarize = Channel.empty()
    
    /* Abricate & Harmonization Modules */
    ch_abricate_megares = Channel.empty()
    ch_abricate_resfinder = Channel.empty()
    ch_abricate_plasmid = Channel.empty()
    ch_abricate_reports = Channel.empty()

    ABRICATE(contigs, megares, plasmidfinder, resfinder)
    ch_abricate_megares = ABRICATE.out.report_megares
    ch_abricate_resfinder = ABRICATE.out.report_resfinder
    ch_abricate_plasmid = ABRICATE.out.report_plasmid
    ch_versions = ch_versions.mix(ABRICATE.out.versions)

    HAMRONIZATION_ABRICATE(ch_abricate_megares, ch_abricate_resfinder, ch_abricate_plasmid, 'json', '1.0.1',  ABRICATE.out.db_megares, ABRICATE.out.db_plasmid, ABRICATE.out.db_resfinder)
    ch_versions = ch_versions.mix(HAMRONIZATION_ABRICATE.out.versions)
    ch_hamronization_input = ch_hamronization_input.mix(HAMRONIZATION_ABRICATE.out.json)

    /* AMRFinderPlus & Harmonization Modules */
    ch_amrfinderplus_db = Channel.empty()
    ch_amrfinderplus_report = Channel.empty()

    AMRFINDERPLUS(contigs, amrfinderdb)
    ch_amrfinderplus_report = AMRFINDERPLUS.out.report
    ch_versions = ch_versions.mix(AMRFINDERPLUS.out.versions)

    HAMRONIZATION_AMRFINDERPLUS(ch_amrfinderplus_report, 'json', AMRFINDERPLUS.out.db_version, AMRFINDERPLUS.out.tool_version)
    ch_versions = ch_versions.mix(HAMRONIZATION_AMRFINDERPLUS.out.versions)
    ch_hamronization_input = ch_hamronization_input.mix(HAMRONIZATION_AMRFINDERPLUS.out.json)

    /* RGI & Harmonization Modules */
    ch_rgi_report = Channel.empty()

    RGI(contigs, card)
    ch_rgi_report = RGI.out.txt
    ch_versions = ch_versions.mix(RGI.out.versions)

    HAMRONIZATION_RGI(ch_rgi_report, 'json', RGI.out.tool_version, RGI.out.db_version)
    ch_versions = ch_versions.mix(HAMRONIZATION_RGI.out.versions)
    ch_hamronization_input = ch_hamronization_input.mix(HAMRONIZATION_RGI.out.json)

    /* Harmonization Summary */
    ch_hamronization_input
        .map {
            it[1]
        }
        .collect()
        .set { ch_hamronization_summarize }

    HAMRONIZATION_SUMMARIZE(ch_hamronization_summarize, 'tsv')
    ch_versions = ch_versions.mix(HAMRONIZATION_SUMMARIZE.out.versions)

    emit:
    versions = ch_versions
}
