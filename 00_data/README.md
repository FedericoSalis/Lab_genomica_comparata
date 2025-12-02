```
 for gff in *.gff; do agat_sp_keep_longest_isoform.pl --gff "$gff" -o ${gff/.gff/_longest.gff}; done
```

Non fatto
```
sed 's/NC_XXX/chr1/'
```


```
for gff in *_longest.gff; do agat_sp_extract_sequences.pl -g "$gff" -f ../00_genome/${gff/_longest.gff/.fna} -t cds -p --cfs --output ../02_raw_proteoms/${gff/_longest.gff/.faa}; done
```

In 02_proteom

```
bash /home/PERSONALE/mirko.martini3/Lab_CompGeno/00_practice/99_scripts/pseudogene_find_eliminate.sh/pseudogene_find_eliminate.sh 
```

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
