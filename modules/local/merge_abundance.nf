// File: merge_and_filter.nf

process merge_and_filter {

    // Input parameters
    input:
    tuple val(sample), path(sample1), path(sample2)

    // Output parameters
    output:
    path("${sample}_phylum.txt") into phylum_output

    // Script to merge and filter
    script:
    """
    // Merge MetaPhlAn tables
    def merged_output = "${sample}_merged.txt"
    "metaphlan/utils/merge_metaphlan_tables.py $sample1 $sample2 > $merged_output".execute()

    // Create phylum-level abundance table
    def phylumData = "grep -E 'p__|clade' $merged_output | grep -v 'c__' | sed -E 's/^.*p__//'".execute().text
    file(phylum_output).text = "Species\tSample1\tSample2\\n" + phylumData
    echo "Phylum-level abundance table generated for $sample"
    """
}
