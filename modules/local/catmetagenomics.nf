process CATMETAGENOMICS {

    input:
    tuple val(meta), path(reads)
    path isolates_read1 
    path isolates_read2

    output:
    tuple val(meta), path("*_integrated.fastq.gz"), emit: integrated_reads

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    cat "${isolates_read1}" "${reads[0]}" > "${prefix}_1_integrated.fastq.gz"
    cat "${isolates_read2}" "${reads[1]}" > "${prefix}_2_integrated.fastq.gz"
    """
}