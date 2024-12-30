process CATCOPYNUMBER {

    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(accession), path(neat_read1), path(neat_read2)

    output:
    tuple val(sample_id), path("${sample_id}_${accession}_copynumber_read1.fq.gz"), emit:copynumber_read1
    tuple val(sample_id), path("${sample_id}_${accession}_copynumber_read2.fq.gz"), emit:copynumber_read2


    script:
    """
    for i in \$(seq 1 ${added_copy_number}); do
        cat ${neat_read1} >> ${sample_id}_${accession}_copynumber_read1.fq.gz
    done

    for i in \$(seq 1 ${added_copy_number}); do
        cat ${neat_read2} >> ${sample_id}_${accession}_copynumber_read2.fq.gz
    done
    """
}
