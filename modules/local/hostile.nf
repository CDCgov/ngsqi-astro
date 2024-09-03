process HOSTILE {
    container './third_party/hostile.sif'

    input:
    tuple val(sample_id), path(decon_1), path(decon_2)
    path(hostile_ref)

    output:
    tuple val(sample_id), path("*_clean.fastq.gz"), path("*_clean.fastq.gz"), emit: clean_reads
    tuple val(sample_id), path("${decon_1.baseName.replaceAll(/_[12].*$/, '')}.hostile.log"), emit: log
    
    script:
    def baseName1 = decon_1.baseName.replaceAll(/_[12].*$/, '')
    def baseName2 = decon_2.baseName.replaceAll(/_[12].*$/, '')
    def readNumber1 = decon_1.baseName.replaceAll(/.*_([12]).*/, '$1')
    def readNumber2 = decon_2.baseName.replaceAll(/.*_([12]).*/, '$1')
    def hostileOutput1 = "${decon_1.baseName}.clean_${readNumber1}.fastq.gz"
    def hostileOutput2 = "${decon_2.baseName}.clean_${readNumber2}.fastq.gz"
    def cleanName1 = "${baseName1}_${readNumber1}_clean.fastq.gz"
    def cleanName2 = "${baseName2}_${readNumber2}_clean.fastq.gz"

    """
    echo "Running hostile on ${decon_1} and ${decon_2}"
    hostile clean --index ${hostile_ref} --fastq1 ${decon_1} --fastq2 ${decon_2} > ${baseName1}.hostile.log

    # Rename the output files to the desired format
    mv ${baseName1}_${readNumber1}_phix.clean_${readNumber1}.fastq.gz ${cleanName1}
    mv ${baseName2}_${readNumber2}_phix.clean_${readNumber2}.fastq.gz ${cleanName2}
    """
}

