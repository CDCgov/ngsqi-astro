# :rocket: ASTRO: AMR Metagenomics Detection, Simulation, Taxonomic Classification, and Read Optimization

### :rocket: **Pipeline Under Development** :rocket:

![Pipeline Status](https://img.shields.io/badge/status-in%20development-blue?style=flat&logo=rocket)


## Introduction

**ASTRO: AMR Metagenomics Detection, Simulation, Taxonomic Classification, and Read Optimization** is a bioinformatics pipeline that performs taxonomic profiling, screens metagenomes and isolate genomes for determinants of antimicrobial resistance, simulates reads, and generates a bacterial metagenomic in silico reference dataset.

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.6-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)


The three primary objectives of the ASTRO workflow entail:

* Simulate sequencing reads with identified species and phyla of interest
* Perform taxonomic profiling and antimicrobial resistance gene (ARG) detection on empirical metagenomes and simulated reads
* Verify quality of simulated datasets mimic empirical datasets

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

This workflow is being built with [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) and utilizes docker and singularity containers to modularize the workflow for optimal maintenance and reproducibility.

# Pipeline Summary
1.	Input paired-end metagenomic reads (.fastq) and isolate data (.fna)
2.	Perform preprocessing on metagenomic reads (`FastQC`, `FastP`, `BBDuk`, `Hostile`)
3.	Assemble the preprocessed reads into contigs and assess the quality of the assembled contigs (`MEGAHIT`, `QUAST`)
4.	Screen metagenomes for ARGs (`AMRFinderPlus`, `ABRICATE`, `RGI`)
5.	Perform taxonomic profiling on metagenomic reads to identify microbial community composition (`METAPHLAN`)
6.	Simulate next generation sequencing reads and spike into cleaned, empirical metagenomic dataset (`NEAT`, `RAGTAG`)
7.	Perform quality control (QC) on simulated dataset (`FastQC`)
8.	Optionally perform taxonomic profiling and ARG detection on in silico dataset
9.	Generate versions and `MultiQC` reports

![ASTRO Diagram](assets/ASTRO_v1.0.0.png)

## Usage

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
> to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
> with `-profile test` before running the workflow on actual data. 

> To run the astro pipeline minimal test, you will need to add your user-specific credentials for the --ncbi_email, 
> --ncbi_api_key, and --metaphlan parameters to the profile script located at conf/test.config. 

> Once complete, you can run the minimal test
> with the following command:
> `nextflow run main.nf -profile test,singularity --outdir <OUTDIR>`

### Set Up:

First, prepare a samplesheet with your input metagenomic data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2
Sample1,assets/data/ERR4678562_1.fastq.gz,assets/data/ERR4678562_2.fastq.gz
Sample2,assets/data/ERR4678563_1.fastq.gz,assets/data/ERR4678563_2.fastq.gz
```

Each row represents a pair of fastq files (paired end metagenomics reads).

You will need to also prepare a samplesheet for isolate genomes to be used in simulation. 

`isolate_samplesheet.csv`:
```csv
sample_id,added_copy_number,file_path,species_name
GCA_018454105.3,1,assets/data/GCA_018454105.3_PDT001044797.3_genomic.fna,Acinetobacter baumannii
GCA_016490125.3,1,assets/data/GCA_016490125.3_PDT000725303.3_genomic.fna,Acinetobacter baumannii
```
Each row corresponds to the following information:

- `sample_id`: Sample ID or name

- `added_copy_number`: Option to include a given number of copies of simulated genomes. If copy number variation is not desired, input '0'

- `file_path`: Path to isolate genome file (.fna)

- `species_name`: Name of isolate species

For instructions on creating an NCBI account and obtaining an API key, please visit the [National Library of Medicine Support Center](https://support.nlm.nih.gov/kbArticle/?pn=KA-05317).

### Running ASTRO:
Now, you can run the pipeline using:


```bash
nextflow run main.nf \
--input samplesheet.csv \
--isolates isolate_samplesheet.csv \
--ncbi_email <USER NCBI EMAIL> \
--ncbi_api_key <API KEY> \
--postsim \
-profile singularity \
--outdir <OUTDIR> \
--mode <local> or <download> \
--taxadb $PATH_TO_DB \

```
Note that _**--postsim**_ is an optional parameter. If used, simulated data will be processed for ARG detection and taxonomic classification. 

> **Warning:****
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those
> provided by the `-c` Nextflow option can be used to provide configuration;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

## Credits

ASTRO was originally written by the Next Generation Sequencing (NGS) Quality Initiative (QI) In silico Team.

We thank the following partners for their extensive assistance in the development of this pipeline:

- CDC Clinical and Environmental Microbiology Branch (CEMB)
- CDC Office of Advanced Molecular Detection (OAMD)
- CDC Office of Laboratory Science and Safety (OLSS)
- CDC Division of Laboratory Systems (DLS)


## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
