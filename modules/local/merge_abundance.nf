#!/usr/bin/env nextflow

process MERGE_ABUNDANCE {
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/neat:4.2.8--pyhdfd78af_0' :
    'biocontainers/neat:4.2.8--pyhdfd78af_0' }"

    input:
    path(profiles)

    output:
    path("merged_output.txt"), emit: merged_output
    
    script:
    def profiles = profiles.join(' ')
    """
    python3 ${projectDir}/bin/merge_metaphlan_tables.py ${profiles} > merged_output.txt
    """
}
