include { ABRICATE_RUN as ABRICATE } from '../../modules/nf-core/abricate/run/main'
include { ABRICATE_SUMMARY } from '../../modules/nf-core/abricate/summary/main'
include { RGI_MAIN as RGI } from '../../modules/nf-core/rgi/main'
include { AMRFINDERPLUS_RUN as AMRFINDERPLUS } from '../../modules/nf-core/amrfinderplus/run/main'
include { HAMRONIZATION_ABRICATE } from '../../modules/nf-core/hamronization/abricate/main.nf'
include { HAMRONIZATION_AMRFINDERPLUS } from '../../modules/nf-core/hamronization/amrfinderplus'
include { HAMRONIZATION_RGI } from '../../modules/nf-core/hamronization/rgi'
include { HAMRONIZATION_SUMMARIZE } from '../../modules/nf-core/hamronization/summarize.nf'

workflow AMR {

    take:
    contigs
    databases
    amrfinderdb
    card

    main:
    ch_versions = Channel.empty()
    ch_hamronization_input = Channel.empty()
    ch_hamronization_summarize = Channel.empty()

    /* Abricate & Harmonization Modules */
    ch_abricate_reports = Channel.empty()

    // Combine contigs and databases
    contigs_with_dbs = contigs
        .map { contig ->
            databases.collect { db ->
                tuple(contigs, db)
            }
        }
        .flatten()

    ABRICATE(contigs_with_dbs, databases)
    ch_abricate_reports = ABRICATE.out.report
    ch_versions = ch_versions.mix(ABRICATE.out.versions)

    HAMRONIZATION_ABRICATE(ch_abricate_reports, 'json', '1.0.0', '3.2.5')
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
    ch_rgi_report = RGI.out.tsv
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
