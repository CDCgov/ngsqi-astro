nextflow.enable.dsl=2

//profiles = Channel.fromPath('./results/081924/metaphlan/*.txt')

process merge_abundance {
    input:
    file profiles_list 

    output:
    path("merged_output.txt"), emit: merged_output
    
    script:
    def profiles_str = profiles_list.join(' ')
    """
    ml Python/3
    echo profiles: ${profiles_str}
    echo python ~/amr-metagenomics/third_party/merge_metaphlan_tables.py ${profiles_str} > merged_output.txt
    python ~/amr-metagenomics/third_party/merge_metaphlan_tables.py ${profiles_str} > merged_output.txt
    echo "Merged abundance table generated for all samples"

    """
}
