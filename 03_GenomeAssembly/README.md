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

## Quality check

### N50

Questa metrica valuta la continuità dell'assembly, valori più alti sono considerati migliori e corrispondono della contig più corta utile a coprire il 50% del genoma assemblato quando sommata a tutte quelle più lunghe di essa. Più le contig sono lunghe più il genoma è continuo. Per ottenere questa informazione è stato lanciato il seguente comando:

```
assembly-stats Anoste_raw.fasta > Anoste_raw.stats
```

### BUSCO

BUSCO controlla la qualità non in base alla continuità dell'assembly ma in base al suo contenuto genetico. Nella pratica verifica la presenza di geni altamente conservati nel nostro assembly confrontandolo con una libreria di riferimento (in questo caso culicidae):

```
export NUMEXPR_MAX_THREADS= 80
busco -m geno -l $BUSCO/culicidae_odb12 -c 6 -o Anoste_raw.busco -i Anoste_raw.fasta
```









