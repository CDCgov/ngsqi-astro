// Modules for automated retrieval of isolate genomes
include { downloadref } from '../../modules/local/downloadref.nf'
include { downloadgenome } from '../../modules/local/downloadgenome.nf'

workflow REFERENCE {
    take:
    input_data
    downloadref_script
    downloadgenome_script
    ncbi_email
    ncbi_api_key

    main:
    downloadref(input_data,downloadref_script,ncbi_email,ncbi_api_key)
    downloadgenome(downloadref.out,downloadgenome_script,ncbi_email,ncbi_api_key)
    downloadgenome.out.genome_data.view { id, copy, file_path, species, accession, genome_file ->
        "Sample: $id, Species: $species, Accession: $accession, Genome file: ${genome_file.name}"
    }

    ch_ref=downloadgenome.out.genome_data

    emit:
    ch_ref
}
