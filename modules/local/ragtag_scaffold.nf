process  RAGTAG_SCAFFOLD {

    publishDir "${params.outdir}/ragtag_scaffold", mode: 'copy'

    label 'process_single'

    input:
        tuple val(Accession_Number), val(RefSeq_ID)

    output:
        /scicomp/home-pure/xvp4/

    script:
    """
    cd /ragtag_scaffold
    ragtag.py scaffold -C /scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/test/read_sim/sra_API_test/${Accession_Number}.fa /scicomp/groups-pure/Projects/CSELS_NGSQI_insillico/amr-metagenomics/test/read_sim/sra_API_test/${RefSeq_ID}.fa -o ${RefSeq_ID}

    """
 
}
