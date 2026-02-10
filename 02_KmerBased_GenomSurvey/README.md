# Kmer Based Genome Survey

## Controllo qualità delle short reads (Fastqc)

Il controllo qualità è stato svolto tramite Fastqc con il seguente comado:

```
fastqc SRR11672503_1.fastq.gz SRR11672503_2.fastq.gz
```

## Trimming delle reads (TRIMMOMATIC)

In seguito al controllo qualità sono state ripulite le reads, tagliando regioni a bassa qualità e adattatori ILLUMINA, e sono state rimosse le reads troppo corte:

```
trimmomatic PE -threads 8 -phred33 SRR11672503_1.fastq.gz SRR11672503_2.fastq.gz SRR11672503_1_paired.fastq SRR11672503_1_unpaired.fastq SRR11672503_2_paired.fastq SRR11672503_2_unpaired.fastq ILLUMINACLIP:/opt/miniforge3/envs/assembly/share/trimmomatic-0.40-0/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 2> stats_trimmomatic.log
```

## Compute k-mer frequency

Per analizzare la qualità e la struttura del genoma è stato utilizzato KAT:

```
kat hist -t 8 -m 27 -o Anoste SRR11672503_1_paired.fastq SRR11672503_2_paired.fastq
```

Con questo strumento siamo in grado di visualizzare la copertura del genoma e identificare gli errori di sequenziamento, le regioni ripetute, siti omozigoti ed eterozigoti.
