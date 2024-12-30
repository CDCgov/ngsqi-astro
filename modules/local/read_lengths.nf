#!/usr/bin/env nextflow

process EXTRACT_READ_LENGTH {
    input:
    tuple val(meta), path(fastqc_zip)

    output:
    tuple val(meta), path("*.txt"), emit: read_length

    script:
    """
    for zip in ${fastqc_zip}; do
        unzip -o "\$zip" -d ./
        unzip_dir=\$(basename "\$zip" .zip)
        READ_LENGTH=\$(grep "Sequence length" ./\$unzip_dir/fastqc_data.txt | cut -f 2)
        echo \${READ_LENGTH} >> read_length.txt
    done
    """
}


