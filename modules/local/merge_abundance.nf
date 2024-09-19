process merge_abundance {
    container "./third_party/metaphlan.sif"
    input:
    file profile_list 

    output:
    path("merged_output.txt"), emit: merged_output
    
    script:
    def profiles_str = profile_list.join(' ')
    """
    echo "Running: python3 ${projectDir}/third_party/merge_metaphlan_tables.py ${profiles_str} > merged_output.txt"
    python3 ${projectDir}/third_party/merge_metaphlan_tables.py ${profiles_str} > merged_output.txt

    """
}
