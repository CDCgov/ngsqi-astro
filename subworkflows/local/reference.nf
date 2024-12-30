include { DOWNLOADREF } from '../../modules/local/downloadref.nf'
include { DOWNLOADGENOME } from '../../modules/local/downloadgenome.nf'

workflow REFERENCE {
    take:
    input_data
    downloadref_script
    downloadgenome_script
    ncbi_email
    ncbi_api_key

    main:
    DOWNLOADREF(input_data, downloadref_script, ncbi_email, ncbi_api_key)
    DOWNLOADGENOME(DOWNLOADREF.out, downloadgenome_script, ncbi_email, ncbi_api_key)
    
   // DOWNLOADGENOME.out.gunzip.view { id, copy, species, accession, genome_file ->
   //     "Sample: $id, CopyNum: $copy, Species: $species, Accession: $accession, Genome file: ${genome_file.name}"
   // }

    ch_ref = DOWNLOADGENOME.out.gunzip

    emit:
    ch_ref
}
