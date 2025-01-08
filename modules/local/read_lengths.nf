process EXTRACT_READ_LENGTH {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(meta), path(fastqc_zip)

    output:
    env(read_length), emit: read_length
    path("*.txt"), emit: txt

    script:
    """
    for zip in ${fastqc_zip}; do
        unzip -o "\$zip" -d ./
        unzip_dir=\$(basename "\$zip" .zip)
        READ_LENGTH=\$(grep -m 1 "Sequence length" ./\$unzip_dir/fastqc_data.txt | cut -f2 | sed 's/.*-//g')
        echo \${READ_LENGTH} >> read_length.txt
    done

    #only extract the first read length
    read_length=\$(head -n 1 read_length.txt)
    echo "Read length: \${read_length}"
    """
}
