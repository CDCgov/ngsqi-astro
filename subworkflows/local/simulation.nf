 // Modules for RagTag genome assembly
include { RAGTAGSCAFFOLD } from '../../modules/local/ragtag_scaffold.nf'
include { RAGTAGPATCH } from '../../modules/local/ragtag_patch.nf'
// Module for read simulation
include { NEATPAIRED } from '../../modules/local/neat-genreads.nf'

workflow SIMULATION {
    take:
    isolate_data
    ref_data
    ch_readlength
    

    main:
    ch_versions = Channel.empty()

    RAGTAGSCAFFOLD(isolate_data, ref_data)

    //RAGTAGSCAFFOLD(references,isolates)
    ch_versions = ch_versions.mix(RAGTAGSCAFFOLD.out.versions)

    RAGTAGPATCH(RAGTAGSCAFFOLD.out.ragtag_scaff_dirs,ref_data)
    //ch_versions = ch_versions.mix(RAGTAGPATCH.out.versions)
    
    NEATPAIRED(RAGTAGPATCH.out.ragtag_patch_dirs, ch_readlength.first().view())
    ch_simreads= NEATPAIRED.out.neat_reads
    ch_versions = ch_versions.mix(NEATPAIRED.out.versions)

    emit:
    ch_simreads
    versions = ch_versions
}
