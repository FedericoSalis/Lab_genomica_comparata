# Genome assembly

In questa directory ci occupiamo dell'assemblaggio delle short reads filtrate in 02.

Durante il sequenziamento del nostro organismo il genoma è stato frammentato e va ora ricostruito computazionalmente cercando i punti di sovapposizione tra le varie reads.

L'assemblaggio è suddiviso in vari livelli:

### Contig

Viene definita "contig" una sequenza di DNA continua, quindi senza gap, ottenuta tramite sovrapposizione di parti di sequenza identiche.

### Scaffold

Lo scaffold si occupa invece di unire le contig preparate precedentemente. A questo livello vengono accettati gap. Questo procedimento tende a ricostruire l'interezza dei singoli cromosomi.

## Raw assembly

### Contig level assembly

Per l'assemblaggio è stato utilizzato Wtdbg2:

```
wtdbg2 -x rs -g 227054799 -t 8 -i SRR11672506.fastq.gz -fo Anoste_raw
```
In seguito è stato performato il polishing della sequenza a partire da dati di long reads con wtpoa-cns, per ottenere la sequenza finale di consenso:

```
wtpoa-cns -t 8 -i Anoste_raw.ctg.lay.gz -fo Anoste_raw
```

### Raw assembly quality check

#### N50

Questa metrica valuta la continuità dell'assembly, valori più alti sono considerati migliori e corrispondono della contig più corta utile a coprire il 50% del genoma assemblato quando sommata a tutte quelle più lunghe di essa. Più le contig sono lunghe più il genoma è continuo. Per ottenere questa informazione è stato lanciato il seguente comando:

```
assembly-stats Anoste_raw.fasta > Anoste_raw.stats
```

#### BUSCO

BUSCO controlla la qualità non in base alla continuità dell'assembly ma in base al suo contenuto genetico. Nella pratica verifica la presenza di geni altamente conservati nel nostro assembly confrontandolo con una libreria di riferimento (in questo caso culicidae):

```
export NUMEXPR_MAX_THREADS= 80
busco -m geno -l $BUSCO/culicidae_odb12 -c 6 -o Anoste_raw.busco -i Anoste_raw.fasta
```

#### KAT

Teoricamente questa pipline avrebbe dovuto contenere un controllo qualità anche tramite KAT, ma in questo caso non è stato svolto.

## Polishing

Prima di tutto le reads vanno riallineate rispetto all'assembly (mapping), e lo facciamo per le short reads:

```
minimap2 -ax sr --MD -t 6 Anoste_raw.fasta SRR11672503_1_paired.fastq SRR11672503_2_paired.fastq > Anoste_raw_sr.sam
samtools view -Sb Anoste_raw_sr.sam > Anoste_raw.bam
rm Anoste_raw_sr.sam
samtools sort -@6 -o Anoste_raw_sr_sorted.bam Anoste_raw_sr.bam
samtools index Anoste_raw_sr.bam
rm Anoste_raw_sr.bam
```

e per le long reads:

```
minimap2 -ax map-pb --MD -t 6 Anoste_raw.fasta SRR11672506.fastq.gz > Anoste_raw_lr.sam
samtools view -Sb Anoste_raw_lr.sam > Anoste_raw_lr.bam
rm Anoste_raw_lr.sam
samtools sort -@6 -o Anoste_raw_lr_sorted.bam Anoste_raw_lr.bam
samtools index Anoste_raw_lr_sorted.bam
rm Anoste_raw_lr.bam
```

A questo punto per eseuire il polishing manca solo l'informazione sulla copertura del genoma, ovvero quante volte in media una base è stata letta dalle short reads. La otteniamo con mosdepth:

```
mosdepth -n --fast-mode --by 500 Anoste_raw_sr Anoste_raw_sr_sorted.bam
```

Hypo è il tool che esegue il polishing e lo avviamo con:

```
echo -e "$R1\n$R2" > Sr.Path
hypo -d Anoste_raw.fasta -r @Sr.path -s 227m -c 136 -b Anoste_raw_sr_sorted.bam -B Anoste_raw_lr_sorted.bam -t 6
```

Al termine di questo procedimento il file di output è stato rinominato:

```
mv hypo_Anoste_raw.fasta Anoste_pol.fasta
```

### Polished assembly quality check

Terminati questi passaggi sono stati eseguiti gli stessi passaggi di quality check sopra descritti.

N50:

```
assembly-stats Anoste_pol.fasta > Anoste_pol.stats
```

BUSCO:

```
export NUMEXPR_MAX_THREADS=80
busco -m geno -l $Busco/culicidae_odb12 -c 8 -o Anoste_pol_busco -i Anoste_pol.fasta
```

## Decontamination

Durante il sequenziamento, nel preparato, troviamo non solo il DNA dell'organismo di interesse, ma anche quello di organismi che vivono sopra o all'interno di esso o quello entrato nel campione a causa di errori tecnici. In questa fase andiamo ad eliminare questi residui.

Prima di tutto le reads vanno rimappate rispetto al nuovo assemblaggio, quello ottenuto con il polishing:

```
minimap2 -ax sr --MD -t 8 Anoste_pol.fasta SRR11672503_1_paired_fastq SRR11672503_2_paired_fastq | samtools view -Sb - > Anoste-pol_sr.bam
samtools sort -@8 -o Anoste_pol_sr_sorted.bam Anoste_pol_sr.bam
samtools index Anoste_pol_sr_sorted.bam
rm Anoste_pol_sr.bam
```

Con blastn andiamo ad eseguire l'annotazione tassonomica delle contig (questo passaggio non è stato realmente eseguito in questa pipeline, le successive analisi sono state eseguite con un file preesistente):

```
blastn -query <ASSEMBLY> -db <PATH/TO/nt/> -outfmt '6 qseqid staxids bitscore std sscinames sskingdoms stitle' -max_target_seqs 25 -max_hsps 1 -num_threads 25 -evalue 1e-25 -out <OUTFILE>
```

I contaminanti sono stati poi rintracciati e rimossi con blobtools, che si basa su coverage, GC content e annotazione tassonomica:

```
blobtools create -i Anoste_pol.fasta -b Anoste_pol_sorted.bam -t Anoste_blast.tsv -o Anoste_blob
blobtools view -i Anoste_blob.blobDB.json -o Anoste
blobtools plot -i Anoste_blob.blobDB.json -o Anoste
```

Per rendere il file visualizzabile in modo semplice lo modifichiamo con:

```
grep 'Arthropoda' Anoste.Anoste_blob.blobDB_table.txt | column -t -s $'\t' | less`
```

Estraiamo infine le sequenze relative ad Arthropoda per ottenere l'assembly decontaminato:

```
awk '{ if ((NR>1)&&($0~/^>/)) { printf("\n%s", $0); } else if (NR==1) { printf("%s", $0); } else { printf("\t%s", $0); } }' Anoste_pol.fasta | grep -w -Ff <(cut -f1 contig_arthropoda.tsv) - | tr "\t" "\n" > Anoste_decontaminated.fasta
#The first part ensures the FASTA is in oneline form and reformat the file obtaing ">header\tsequence". In this way it is easier to process the file with grep. Then filters out everything is contained inside the patterns file, outputting a fasta file oneline with only desired contigs.
```

## Scaffolding

Per migliorare la qualità e la continuità dell’assembly è stato utilizzato il tool RagTag. 
Prima è stato corretto l'assembly confrontandolo con un genoma di riferimento:

```
ragtag.py correct -t 20 <REFERENCE_GENOME> <DRAFT_GENOME>
```

Successivamente è stato eseguito lo scaffolding vero e proprio:

```
ragtag.py scaffold -C -t 20 -o <OUTPUT_DIR> <REFERENCE_GENOME> <CORRECTED_DRAFTGENOME>
```

Questi ultimi passaggi non sono stati realmente eseguiti, ma i risultati sono stati forniti da analisi precedenti.











