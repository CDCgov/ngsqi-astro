process FILTER_ABUNDANCE {
    
    input:
    path("merged_output.txt")

    output:
    path("merged_phylum.txt"), emit: phylum_output
    path("merged_species.txt"), emit: species_output

    script:
    """
    #!/bin/bash
    input_file="\$(realpath merged_output.txt)"

    # Skip the first line and extract the header from the second line
    raw_header=\$(sed -n '2p' "\$input_file")

    # Generate the header with sample IDs in their original order
    header=\$(echo "\$raw_header" | awk -F '\\t' '{for (i=2; i<=NF; i++) printf("%s%s", \$i, (i<NF) ? "\\t" : ""); print ""}')

    printf "Clade\\t%s\\n" "\$header" > merged_phylum.txt
    printf "Clade\\t%s\\n" "\$header" > merged_species.txt

    # Process the data lines for phylum-level without prefixes and ensure tab delimiters, skipping the 'clade_name' line
    grep -E 'p__|clade' "\$input_file" | grep -v 'c__' | grep -v 'clade_name' | sed -E 's/^.*p__//' | awk '{\$1=\$1; print}' OFS='\\t' >> merged_phylum.txt

    # Process the data lines for species-level without prefixes and ensure tab delimiters, skipping the 'clade_name' line
    grep -E 's__|clade' "\$input_file" | grep -v 't__' | grep -v 'clade_name' | sed -E 's/^.*s__//' | awk '{\$1=\$1; print}' OFS='\\t' >> merged_species.txt
    """
}
