process ragtagscaffold {

    publishDir "${params.outdir}", mode: 'copy'

    label 'process_single'

    container "/scicomp/home-pure/xvp4/amr-metagenomics/third_party/ragtag.sif"

    input:
    tuple val(sample_id), val(added_copy_number), val(file_path), val(species_name), val(accession_numbers)
    file "Species_ID_with_Accessions.csv"

    output:
    path "scaff_*"

    script:
    """
    head ${params.outdir}/Species_ID_with_Accessions.csv
    ragtag.py scaffold -C /scicomp/home-pure/xvp4/amr-metagenomics/results/${accession_numbers}.fa /scicomp/home-pure/xvp4/amr-metagenomics/results/${sample_id}_genomic.fna -o "scaff_${sample_id}_${accession_numbers}"
    """
 
}
