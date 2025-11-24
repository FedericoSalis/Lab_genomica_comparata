#!/bin/bash

# Mapping short reads on assembly. Mutate SAM into BAM

# Short reads
minimap2 -ax sr --MD -t 6 Anoste_raw.fasta SRR11672503_1_paired.fastq SRR11672503_2_paired.fastq > Anoste_raw_sr.sam
samtools view -Sb Anoste_raw_sr.sam > Anoste_raw_sr.bam
rm Anoste_raw_sr.sam
samtools sort -@6 -o Anoste_raw_sr_sorted.bam Anoste_raw_sr.bam
samtools index Anoste_raw_sr_sorted.bam
rm Anoste_raw_sr.bam

# Long reads
minimap2 -ax map-pb --MD -t 6 Anoste_raw.fasta SRR11672506.fastq.gz > Anoste_raw_lr.sam
samtools view -Sb Anoste_raw_lr.sam > Anoste_raw_lr.bam
rm Anoste_raw_lr.sam
samtools sort -@6 -o Anoste_raw_lr_sorted.bam Anoste_raw_lr.bam
samtools index Anoste_raw_lr_sorted.bam
rm Anoste_raw_lr.bam



