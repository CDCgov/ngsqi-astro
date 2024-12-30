include { RAGTAGSCAFFOLD } from '../../modules/local/ragtag_scaffold.nf'
include { RAGTAGPATCH } from '../../modules/local/ragtag_patch.nf'
include { NEATPAIRED } from '../../modules/local/neat-genreads.nf'

workflow SIMULATION {
    take:
    ch_ref
    ch_readlength

    main:
    ch_versions = Channel.empty()

    RAGTAGSCAFFOLD(ch_ref)
    ch_versions = ch_versions.mix(RAGTAGSCAFFOLD.out.versions)

    RAGTAGPATCH(RAGTAGSCAFFOLD.out.ragtag_scaff_dirs)
    ch_versions = ch_versions.mix(RAGTAGPATCH.out.versions)
    
    NEATPAIRED(RAGTAGPATCH.out.ragtag_patch_dirs, ch_readlength.first().view())
    ch_simreads = NEATPAIRED.out.neat_reads
    ch_versions = ch_versions.mix(NEATPAIRED.out.versions)

    emit:
    ch_simreads
    versions = ch_versions
}
