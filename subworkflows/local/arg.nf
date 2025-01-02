//Depreciating custom mods
//include {ABRICATE} from '../../modules/local/abricatemod.nf'
//include {HARMABRICATE} from '../../modules/local/harm_abricate.nf'
//include {AMRFINDERPLUS_UPDATE} from '../../modules/local/amr_db_update.nf'
//include {AMRFinder} from '../../modules/local/amrfinderplus.nf'
//include {CONCATENATE_REPORTS} from '../../modules/local/concatenate_reports.nf'
//include {HARMAmrfinder} from '../../modules/local/harm_amrfinder.nf'
//include {HARMRGI} from '../../modules/local/harm_rgi.nf'
//include {RGI} from '../../modules/local/rgimod.nf'
//include {HARMSUMMARY} from '../../modules/local/harm_summary.nf'

//Integrating nf-core mods
include {ABRICATE_RUN as ABRICATE} from '../../modules/nf-core/abricate/run/main'
include {ABRICATE_SUMMARY} from '../../modules/nf-core/abricate/summary/main'
include {RGI} from '../../nf-core/rgi/main'
include {AMRFINDERPLUS_RUN as AMRFINDERPLUS} from '../../modules/nf-core/amrfinderplus/run/main'

   
workflow AMR {
   
    take: 
    contigs
    databases
    amrfinderdb
 
 
    main:
    ch_versions = Channel.empty()
    ch_hamronization_input = Channel.empty()
    ch_hamronization_summarize = Channel.empty()

    /*Abricate & Harmonization Modules */
    if ( params.execute_ABRICATE) {
    ch_abricate_report1 = Channel.empty()
    ch_abricate_report2 = Channel.empty()
    ch_abricate_report3 = Channel.empty()

    ABRICATE(contigs, databases)
    ch_abricate_report1 = ABRICATE.out.report1
    ch_abricate_report2 = ABRICATE.out.report2
    ch_abricate_report3 = ABRICATE.out.report3
    ch_versions = ch_versions.mix(ABRICATE.out.versions)

    HAMRONIZATION_ABRICATE (ch_abricate_report1, ch_abricate_report2, ch_abricate_report3, databases, 'json', '1.0.0', '3.2.5')
    ch_versions = ch_versions.mix(HAMRONIZATION_ABRICATE.out.versions)
    ch_hamronization_input = ch_hamronization_input.mix(HAMRONIZATION_ABRICATE.out.report)

     }

 /*AMRFinderPlus & Harmonization Modules */
    if ( params.execute_AMRFinder) {
    ch_amrfinderplus_db = Channel.empty()
    ch_amrfinderplus_report = Channel.empty()

    AMRFINDERPLUS(contigs, amrfinderdb)
    ch_amrfinderplus_report = AMRFINDERPLUS_RUN.out.report
    ch_versions = ch_versions.mix(AMRFINDERPLUS_RUN.out.versions)


   HAMRONIZATION_AMRFINDERPLUS (ch_amrfinderplus_report,'json', AMRFINDERPLUS_RUN.out.db_version, AMRFINDERPLUS_RUN.out.tool_version)
   ch_versions = ch_versions.mix(HAMRONIZATION_AMRFINDERPLUS.out.versions)
   ch_hamronization_input = ch_hamronization_input.mix(HAMRONIZATION_AMRFINDERPLUS.out.json)

    }

 /* RGI & Harmonization Modules */
    
    if (params.execute_RGI) 
    {
    ch_rgi_report = Channel.empty()

    RGI(contigs)
    ch_rgi_report = RGI_MAIN.out.tsv
    ch_versions = ch_versions.mix(RGI.out.versions)

    HAMRONIZATION_RGI(ch_rgi_report, 'json')
    ch_versions = ch_versions.mix(HAMRONIZATION_RGI.out.versions)
    ch_hamronization_input = ch_hamronization_input.mix(HAMRONIZATION_RGI.out.json)
    }

  if (params.execute_ABRICATE || params.execute_AMRFinder || params.execute_RGI) {
    ch_hamronization_input
        .map{
            it[1]
        }
        .collect()
        .set { ch_hamronization_summarize }

    HAMRONIZATION_SUMMARIZE (ch_hamronization_summarize, 'tsv')
    ch_versions = ch_versions.mix(HAMRONIZATION_SUMMARIZE.out.versions)
    }

    emit:
    versions = ch_versions
}