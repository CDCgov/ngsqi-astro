process ragtagscaffold {

    publishDir "${params.outdir}", mode: 'copy'

    //label 'process_single'

    container "/scicomp/home-pure/xvp4/amr-metagenomics/third_party/ragtag.sif"

    input:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(species_name), val(accession), path(ref_file)

    output:
    tuple val(sample_id), val(added_copy_number), path(file_path), val(accession), path(ref_file), path("scaff_${sample_id}_${accession}"), emit:ragtag_scaff_dirs

    script:
    """
    ragtag.py scaffold -C ${ref_file} ${file_path} -o "scaff_${sample_id}_${accession}"
    """
 
}
