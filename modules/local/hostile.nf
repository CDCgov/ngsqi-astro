process HOSTILE {
    container './third_party/hostile.sif'

    input:
    tuple val(sample), path(decon_1), path(decon_2)
    path(hostile_ref)

    output:
    tuple val(sample), path("*_1_clean.fastq.gz"), path("*_2_clean.fastq.gz"), emit: clean_reads
    //tuple val(sample), path("*_clean.fastq.gz"), emit: clean_reads
    tuple val(sample), path("*.hostile.log"), emit: log
    path "versions.yml", emit: versions
    
    script:
    def readNumber1 = decon_1.baseName.replaceAll(/.*_([12]).*/, '$1')
    def readNumber2 = decon_2.baseName.replaceAll(/.*_([12]).*/, '$1')
    def cleanName1 = "${sample}_1_clean.fastq.gz"
    def cleanName2 = "${sample}_2_clean.fastq.gz"

    """
    hostile clean --index ${hostile_ref} --fastq1 ${decon_1} --fastq2 ${decon_2} > ${sample}.hostile.log

    #Rename the output files
     mv ${sample}_${readNumber1}_phix.clean_${readNumber1}.fastq.gz ${cleanName1}
     mv ${sample}_${readNumber2}_phix.clean_${readNumber2}.fastq.gz ${cleanName2}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hostile: \$(echo \$(hostile --version 2>&1))
    END_VERSIONS
    """
}
