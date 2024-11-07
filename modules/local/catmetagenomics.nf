process catmetagenomics {
    
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), path(read_1), path(read_2)
    path(isolates_read1)
    path(isolates_read2)

    output:
    tuple val(sample_id), path("*_1_integrated.fastq.gz"), emit: catmetagenomics_read1
    tuple val(sample_id), path("*_2_integrated.fastq.gz"), emit: catmetagenomics_read2

    script:
    def baseName1 = read_1.toString().replaceAll(/_[12].*$/, '')
    def baseName2 = read_2.toString().replaceAll(/_[12].*$/, '')
    def cleanName1 = "${baseName1}_1_integrated.fastq.gz"
    def cleanName2 = "${baseName2}_2_integrated.fastq.gz"
    """
    cat "${isolates_read1}" "${read_1}" > "${cleanName1}"
    cat "${isolates_read2}" "${read_2}" > "${cleanName2}"
    """
}
