#!/usr/bin/env nextflow

process MERGE_ABUNDANCE {

    input:
    path(profiles)

    output:
    path("merged_output.txt"), emit: merged_output
    
    script:
    def profiles = profiles.join(' ')
    """
    echo "Running: python3 ${projectDir}/third_party/merge_metaphlan_tables.py ${profiles} > merged_output.txt"
    python3 ${projectDir}/third_party/merge_metaphlan_tables.py ${profiles} > merged_output.txt
    """
}
