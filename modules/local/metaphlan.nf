process metaphlan {

container './third_party/metaphlan.sif'

    tag "metaphlan_${sample}"
    publishDir "${params.outdir}/metaphlan", mode: 'copy'

    input:
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path("${sample}.txt"), emit: profile


    script:
    """
    metaphlan ${reads[0]},${reads[1]} \\
        --bowtie2out ${sample}_metagenome.bowtie2.bz2 \\
        --nproc ${task.cpus} \\
        --input_type fastq \\
        -o ${sample}.txt \\
        --bowtie2db ./assets/databases/metaphlan_databases
    """
}

