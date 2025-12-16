Date diverse isoforme di una proteina (dipendenti da diverso splicing) scegliamo di mantanere tra le varie isoforme quella più lunga

Ricerca dell'isoforma più lunga

```
 for gff in *.gff; do agat_sp_keep_longest_isoform.pl --gff "$gff" -o ${gff/.gff/_longest.gff}; done
```
Estrazione sequenza più lunga in formato .faa

```
for gff in *_longest.gff; do agat_sp_extract_sequences.pl -g "$gff" -f ../00_genome/${gff/_longest.gff/.fna} -t cds -p --cfs --output ../02_raw_proteoms/${gff/_longest.gff/.faa}; done
```

Rimozione pseudogeni in 02_proteome

```
bash /home/PERSONALE/mirko.martini3/Lab_CompGeno/00_practice/99_scripts/pseudogene_find_eliminate.sh/pseudogene_find_eliminate.sh 
```

conta degli pseudogeni

```
for pseudo in *.txt; do wc -l "$pseudo"; done
```

#cambio header

ora sono ultima colonna gff, a noi interessa il ```name```
  
```
sed -E 's/>(rna-XM_[0-9]+\.[0-9]) (gene=gene-.[^ ]+) name=(.[^ ]+) .+$/>\3/' <SIGLA SPECIE.faa> | grep ">"
```

```
for prot in *.faa; do ID=$(basename -s .faa "$prot"); sed -i.old -E "s/>(rna-XM_[0-9]+\.[0-9]) (gene=gene-.[^ ]+) name=(.[^ ]+) .+$/>"$ID"\|\3/" "$prot"; done 
```
per ANOSTE da fare dentro a 02 nell'env orthofinder

```
orthofinder -t 8 -a 8 -f .
```
