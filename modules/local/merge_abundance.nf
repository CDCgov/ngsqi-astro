nextflow.enable.dsl=2

process merge_abundance {
    input:
    file profile_list 

    output:
    path("merged_output.txt"), emit: merged_output
    
    script:
    def profiles_str = profile_list.join(' ')
    """
    ml Python/3

    python ~/amr-metagenomics/third_party/merge_metaphlan_tables.py ${profiles_str} > merged_output.txt

    """
}
