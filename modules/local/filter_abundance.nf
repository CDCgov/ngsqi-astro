process filter_abundance {
    debug = true
    
    input:
    path("merged_output.txt")

    output:
    path("merged_phylum.txt"), emit: phylum_output
    path("merged_species.txt"), emit: species_output

    script:
    """
    #!/bin/bash

    #Debugging:
    #Print the current working directory
    echo "Current working directory: \$(pwd)"
    echo "Files in working directory: \$(ls)"

    #Define the input file path
    input_file="\$(realpath merged_output.txt)"

    echo "Input file: \$input_file"

    #Check if the input file exists and is readable
    if [ ! -r "\$input_file" ]; then
        echo "Error: Input file does not exist or is not readable"
        exit 1
    fi

    #Extract the second line and generate new header
    raw_header=\$(sed -n '2p' "\$input_file")
    echo "Raw header: \$raw_header"

    #Generate the header with sample IDs in their original order
    header=\$(echo "\$raw_header" | awk -F '\\t' '{for (i=2; i<=NF; i++) printf("%s%s", \$i, (i<NF) ? "," : ""); print ""}')
    echo "Generated header: \$header"

    #Print the header to the phylum output file
    printf "Clade,%s\\n" "\$header" > merged_phylum.txt

    #Print the header to the species output file
    printf "Clade,%s\\n" "\$header" > merged_species.txt

    #Process the data lines for phylum-level without prefixes and ensure comma delimiters
    grep -E 'p__|clade' "\$input_file" | grep -v 'c__' | sed -E 's/^.*p__//' | awk '{\$1=\$1; print}' OFS=',' >> merged_phylum.txt

    #Process the data lines for species-level without prefixes and ensure comma delimiters
    grep -E 's__|clade' "\$input_file" | grep -v 't__' | sed -E 's/^.*s__//' | awk '{\$1=\$1; print}' OFS=',' >> merged_species.txt

    echo "Phylum-level and species-level abundance tables generated for merged samples"
    """
}
