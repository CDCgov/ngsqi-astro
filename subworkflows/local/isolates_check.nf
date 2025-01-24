// Check input samplesheet and get read channels

include { ISOLATE_CHECK } from '../../modules/local/isolate_check'

workflow ISOLATES_CHECK {
    take:
    isolates // file: /path/to/isolate_samplesheet.csv

    main:
    ISOLATE_CHECK ( isolates )
        .csv
        .splitCsv(header: true, sep: ',')
        .map { row -> 
            tuple(
                row.sample_id,
                row.added_copy_number,
                row.file_path,
                row.species_name
            ) 
        }
        .set { ch_isolates }

    emit:
    ch_isolates                                // channel: [ val(ID), [ isolates ] ]
    versions = ISOLATE_CHECK.out.versions        // channel: [ versions.yml ]
}
