# Creazione del dataset

## Downoload del dataset

I genomi di altre cinque specie di zanzara sono stati scaricati da NCBI, dopo aver creato la tabella con gli accession number presente in questa directory. I genomi scelti sono stati filtrati come reference genome, annotated e scaffold level.

Sono stati scaricati con lo scipt downoload_dataset.sh presente nella cartella 99_scripts:

```
bash download_dataset.sh dataset.tsv
```

## Ricerca dell'isoformaa più lunga

Date diverse isoforme di una proteina (dipendenti da diverso splicing) scegliamo di mantanere tra le varie isoforme quella più lunga

Ricerca dell'isoforma più lunga

```
 for gff in *.gff; do agat_sp_keep_longest_isoform.pl --gff "$gff" -o ${gff/.gff/_longest.gff}; done
```
Estrazione sequenza più lunga in formato .faa

```
for gff in *_longest.gff; do agat_sp_extract_sequences.pl -g "$gff" -f ../00_genome/${gff/_longest.gff/.fna} -t cds -p --cfs --output ../02_raw_proteoms/${gff/_longest.gff/.faa}; done
```

## Rimozione pseudogeni 

All'interno di 02_proteoms, per rimuovere gli pseudogeni; è stato lanciato:

```
bash /home/PERSONALE/mirko.martini3/Lab_CompGeno/00_practice/99_scripts/pseudogene_find_eliminate.sh/pseudogene_find_eliminate.sh 
```

Per contare gli pseudogeni:

```
for pseudo in *.txt; do wc -l "$pseudo"; done
```

Vanno modificati gli header: ora sono ultima colonna gff, a noi interessa il ```name```:
  
```
sed -E 's/>(rna-XM_[0-9]+\.[0-9]) (gene=gene-.[^ ]+) name=(.[^ ]+) .+$/>\3/' <SIGLA SPECIE.faa> | grep ">"
```

```
for prot in *.faa; do ID=$(basename -s .faa "$prot"); sed -i.old -E "s/>(rna-XM_[0-9]+\.[0-9]) (gene=gene-.[^ ]+) name=(.[^ ]+) .+$/>"$ID"\|\3/" "$prot"; done 
```

## Orthofinder

Per cercare ortogruppi tra i genomi scaricati è stato utilizzato Orthofinder:

```
orthofinder -t 8 -a 8 -f .
```
