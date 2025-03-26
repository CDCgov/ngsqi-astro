process CATMETAGENOMICS {
    
    input:
    path(combined_isolates_read1)
    path(combined_isolates_read2)
    tuple val(meta), path(reads)
    
    output:
    tuple val(meta), path("*_integrated.fastq.gz"), emit: integrated_reads
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    zcat ${combined_isolates_read1} ${reads[0]} | gzip > "${prefix}_1_integrated.fastq.gz"
    zcat ${combined_isolates_read2} ${reads[1]} | gzip > "${prefix}_2_integrated.fastq.gz"
    """
}