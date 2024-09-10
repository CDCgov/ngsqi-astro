process HOSTILE {
    container './third_party/hostile.sif'

    input:
    tuple val(sample), path(decon_1), path(decon_2)
    path(hostile_ref)

    output:
    tuple val(sample_id), path("*_clean.fastq.gz"), emit: clean_reads
    tuple val(sample_id), path("${decon_1.baseName.replaceAll(/_[12].*$/, '')}.hostile.log"), emit: log
    
    script:
    def baseName1 = decon_1.baseName.replaceAll(/_[12].*$/, '')
    def baseName2 = decon_2.baseName.replaceAll(/_[12].*$/, '')
    def readNumber1 = decon_1.baseName.replaceAll(/.*_([12]).*/, '$1')
    def readNumber2 = decon_2.baseName.replaceAll(/.*_([12]).*/, '$1')
    def cleanName1 = "${baseName1}_1_clean.fastq.gz"
    def cleanName2 = "${baseName2}_2_clean.fastq.gz"

    """
    hostile clean --index ${hostile_ref} --fastq1 ${decon_1} --fastq2 ${decon_2} > ${baseName1}.hostile.log

    #Rename the output files
    mv ${baseName1}_${readNumber1}_phix.clean_${readNumber1}.fastq.gz ${cleanName1}
    mv ${baseName2}_${readNumber2}_phix.clean_${readNumber2}.fastq.gz ${cleanName2}
    """
}
