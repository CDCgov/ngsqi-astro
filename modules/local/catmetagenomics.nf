process catmetagenomics {

    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), path(read_1), path(read_2)
    path(isolates_read1)
    path(isolates_read2)

    output:
    path("combined_isolates_metagenomics_${sample_id}_read1.fq.gz"), emit:catmetagenomics_read1
    path("combined_isolates_metagenomics_${sample_id}_read2.fq.gz"), emit:catmetagenomics_read2

    script:
    """
    cat ${isolates_read1} ${read_1} > combined_isolates_metagenomics_${sample_id}_read1.fq.gz
    cat ${isolates_read2} ${read_2} > combined_isolates_metagenomics_${sample_id}_read2.fq.gz
    """
}


