 // Modules for RagTag genome assembly
include { ragtagscaffold } from '../../modules/local/ragtag_scaffold.nf'
include { ragtagpatch } from '../../modules/local/ragtag_patch.nf'
// Module for read simulation
include { neatpaired } from '../../modules/local/neat-genreads.nf'

workflow SIMULATION {
    take:
    ch_ref
    ch_readlength

    main:
    ragtagscaffold(ch_ref)
    ragtagpatch(ragtagscaffold.out.ragtag_scaff_dirs)
    neatpaired(ragtagpatch.out.ragtag_patch_dirs, ch_readlength.first().view())

    ch_simreads=neatpaired.out.neat_reads

    emit:
    ch_simreads
}
