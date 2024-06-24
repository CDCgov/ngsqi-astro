## Introduction

**amr-metagenomics** is a bioinformatics pipeline that performs taxonomic profiling, screens metagenomes and isolate genomes for determinants of antimicrobial resistance, simulates reads, and generates a bacterial HAI in silico reference dataset.



<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

1.	Input paired-end metagenomics reads (.fastq) and isolate data (.fna) with samplesheet
2.	Perform pre-processing on metagenomics reads (FastQC, FastP, PHIX, Hostile*)
3.	Screen metagenomes and isolate data for ARGs (AMRFinderPlus, Ariba, ABRICATE, RGI*)
4.	Perform taxonomic profiling on metagenomics reads to identify microbial community composition (MetaPhlAn v4.1)
5.	Integrate isolate data with taxonomic profiling results to link specific bacterial strains with their abundance in the metagenomics dataset
6.	Simulate sequencing reads (NEAT)
7.	Integrate in silico reads into empirical dataset
8.	Perform taxonomic profiling on in silico dataset as quality control (MetaPhlAn v4.1)
9.	Generate summary, visualizations and other output files (AMR: HARMONIZATION, TAXONOMY: Hclust2, etc.*)

## Usage

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
> to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
> with `-profile test` before running the workflow on actual data.

<!-- TODO nf-core: Describe the minimum required steps to execute the pipeline, e.g. how to prepare samplesheets.
     Explain what rows and columns represent. For instance (please edit as appropriate):

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2
Sample1,amr-metagenomics/assets/data/ERR4678562_1.fastq.gz,amr-metagenomics/assets/data/ERR4678562_2.fastq.gz
Sample2,amr-metagenomics/assets/data/ERR4678563_1.fastq.gz,amr-metagenomics/assets/data/ERR4678563_2.fastq.gz
```

Each row represents a pair of fastq files (paired end metagenomics reads).

-->

Now, you can run the pipeline using:

<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->

```bash
nextflow run main.nf \
--input samplesheet.csv \
-profile singularity \
--outdir <OUTDIR>

```

> **Warning:**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those
> provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

## Credits

amr-metagenomics was originally written by NGSQI In Silico team.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use  tb/prototype for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
