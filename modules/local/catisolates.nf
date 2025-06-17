process CATISOLATES {
    
    input:
    path(copynumber_read1)
    path(copynumber_read2)

    output:
    path "combined_isolates_read1.fq.gz", emit: isolates_read1
    path "combined_isolates_read2.fq.gz", emit: isolates_read2

    script:
    """
    zcat ${copynumber_read1} | gzip > combined_isolates_read1.fq.gz
    zcat ${copynumber_read2} | gzip > combined_isolates_read2.fq.gz
    """
}

