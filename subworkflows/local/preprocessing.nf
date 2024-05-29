#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
========================================================================================
    Preprocessing/QC Subworkflow
========================================================================================

/*
========================================================================================
  Include Modules
========================================================================================
*/
include {FASTQC} from '../../modules/local/fastqc.nf'
include {FASTP} from '../../modules/local/fastp.nf'
include {BBDUK} from '../../modules/local/bbduk.nf'
include {HOSTILE} from '../../modules/local/hostile.nf'

/*
========================================================================================
 Worklow PREPROCESSING
========================================================================================
*/
workflow PREPROCESSING {
    take:
    ch_reads
    ch_ref
    ch_hostile_ref

    main:
    FASTQC(ch_reads)
    FASTP(ch_reads)
    BBDUK(FASTP.out)
    HOSTILE(BBDUK.out, ch_hostile_ref)
   
    emit:
    ch_reads
}
