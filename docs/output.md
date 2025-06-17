# astro: Output

## Introduction

This document describes the output produced by the pipeline. Most of the plots are taken from the MultiQC report, which summarises results at the end of the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

<!-- TODO nf-core: Write this documentation describing your workflow's output -->

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [Preprocessing](#preprocessing) - Performs QC, trims, and decontaminates the reads 
- [AMR](#amr) - Screens metagenomes for determinants of antimicrobial resistance, namely ARGs
- [Assembly](#assembly) - Assembles the preprocessed reads into contigs and assesses the quality of the assembled contigs 
- [Taxonomy](#taxonomy) - Classifies relative taxonomic abundance from metagenomes and generates species and phyla abundance heatmaps 
- [Reference, Simulation, Integrate](#simulation) - Simulates in silico sequencing reads and spikes the reads into cleaned metagenomic dataset 
- [PostSim](#postsim) - Executes optional functions: runs assembly, AMR, and taxonomy on simulated dataset 
- [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

## Preprocessing

[FastP](https://github.com/OpenGene/fastp)  trims adapters and low-quality regions from the reads to enhance sequence quality

Output files:
* `QC/fastp/`
    * `sample/`
      * `sample.html`
      * `sample.log`

[BBDuk](https://github.com/BioInfoTools/BBMap/blob/master/sh/bbduk.sh) Removes PhiX reads to eliminate unwanted spike-in sequences

Output files:
* `QC/bbduk/`
    * `sample.bbduk.log`

[Hostile](https://github.com/bede/hostile) Removes host reads to ensure that only relevant sequence data are retained

Output files:
* `QC/hostile/`
    * `sample.hostile.log`

[FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) generates quality reports on raw and cleaned reads. These reports include key metrics such as per-base sequence quality, GC content, and sequence length distribution. 

Output files:
* `QC/fastqc/`
    * `clean/`
      * `sample.html`
    * `raw/`
      * `sample.html`

## Assembly

[MegaHit](https://github.com/voutcn/megahit) performs the assembly of the preprocessed reads into contigs

Output files:
* `assembly/megahit/`
    * `sample.fa.gz`

[MetaQUAST](https://github.com/ablab/quast) conducts QC on the assembled contigs to evaluate metrics such as completeness, contiguity, and accuracy

Output files:
* `assembly/quast/`
    * `sample.tsv`

## AMR

[AMRFinderPlus](https://github.com/ncbi/amr) identifies the presence or absence of ARGs and associated point mutations in bacterial proteins and assembled nucleotide sequences

[Resistance Gene Identifier](https://github.com/arpcard/rgi) predicts antibiotic resistome(s) from protein or nucleotide data based on the homology and single-nucleotide polymorphism (SNP) models

[ABRicate](https://github.com/arpcard/rgi) predicts antibiotic resistome(s) from protein or nucleotide data based on the homology and single-nucleotide polymorphism (SNP) models

[hAMRonization ](https://github.com/arpcard/rgi) harmonizes and standardizes AMR gene annotations across various datasets by aligning different datasets to a common reference

Output files:
* `amr/hamronization/summarize`
    * `hamronization_combined_report.tsv`

## Taxonomy

[MetaPhlAn](https://github.com/biobakery/MetaPhlAn) identify microbial community composition in metagenomic samples

Output files:
* `taxonomy/metaphlan/`
    * `sample.txt`

[Hclust2](https://github.com/SegataLab/hclust2) generates abundance heat maps to visualize the taxonomic composition across samples at both the species and phyla level

Output files:
* `taxonomy/heatmaps/`
    * `merged_phylum.png`
    * `merged_species.png`

## Simulation

[RagTag](https://github.com/malonge/RagTag) performs assembly of isolate genomes

[NEAT](https://github.com/zstephens/neat-genreads) simulates next generation sequencing reads from isolate genomes

Output files:
* `simulation/neat`
    * `sample_read1.fq.gz`
    * `sample_read2.fq.gz`

## Integrate

**Copy Number** generates copies of sequencing reads per given copy number value

**Combine Isolates** combine all datasets of simulated reads

**Combine Isolates with Metagenomics** combine simulated isolate read datasets with metagenomic read datasets

Output files:
* `simulation/catmeta`
    * `sample_1_integrated.fastq.gz`
    * `sample_2_integrated.fastq.gz`

[FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) generates quality reports on simulated, combined dataset

Output files:
* `simulation/fastqc/sim`
    * `sample_1_fastqc.html`
    * `sample_2_fastqc.html`

## PostSim

Performs [Assembly](#assembly), [AMR](#amr), and [Taxonomy](#taxonomy) for simulated dataset

Assembly output files:
* `simulation/assembly/megahit/`
    * `sample.fa.gz`
* `simulation/assembly/quast/`
    * `sample.tsv`

AMR output files:
* `simulation/amr/hamronization/summarize`
    * `hamronization_combined_report.tsv`

Taxonomy output files:
* `simulation/taxonomy/metaphlan/`
    * `sample.txt`
* `simulation/taxonomy/heatmaps/`
    * `merged_phylum.png`
    * `merged_species.png`

## MultiQC

Aggregates and summarizes results from the various QC checkpoints throughout the pipeline

Output files:
* `multiqc/`
    * `multiqc_report.html`

## Versions Report

Generates a report to track the specific tool versions used throughout the pipeline

Output files:
* `versions/`
    * `software_versions.yml`

## Pipeline information

Output files:
- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
