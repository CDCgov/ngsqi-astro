process CATCOPYNUMBER {

    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(accession), path(neat_read1), path(neat_read2)

    output:
    tuple val(sample_id), path("${sample_id}_${accession}_copynumber_read1.fq.gz"), emit:copynumber_read1
    tuple val(sample_id), path("${sample_id}_${accession}_copynumber_read2.fq.gz"), emit:copynumber_read2


    script:
    """
    zcat ${neat_read1} > temp_read1.fq
    for i in \$(seq 1 ${added_copy_number}); do
        zcat ${neat_read1} >> temp_read1.fq
    done
    gzip -c temp_read1.fq > ${sample_id}_${accession}_copynumber_read1.fq.gz
    rm temp_read1.fq

    zcat ${neat_read2} > temp_read2.fq
    for i in \$(seq 1 ${added_copy_number}); do
        zcat ${neat_read2} >> temp_read2.fq
    done
    gzip -c temp_read2.fq > ${sample_id}_${accession}_copynumber_read2.fq.gz
    rm temp_read2.fq
    """
}
