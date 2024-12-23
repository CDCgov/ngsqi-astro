process CATISOLATES {

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path(copynumber_read1)
    path(copynumber_read2)

    output:
    path("combined_isolates_read1.fq.gz"), emit:isolates_read1
    path("combined_isolates_read2.fq.gz"), emit:isolates_read2

    script:
    """
    cat ${copynumber_read1} >> combined_isolates_read1.fq.gz
    cat ${copynumber_read2} >> combined_isolates_read2.fq.gz
    """

}

