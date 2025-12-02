Statistic overall contiene tutte le informazioni sulle nostre specie (es. numero specie, numero geni, numero geni in ortogruppi, ecc...)

Orthofinder genera un solo file con tutti gli alberi, Disco ha bisogno di un file per albero. In esolved_gene_trees gli alberi sono nella seconda colonna. Facciamo un ciclo per leggere ogni riga della seconda colonna come file. 
(env tree)

```
while IFS=' ' read -r OG tree; do python3 /home/STUDENTI/federico.salis/Lab_genomica_comparata/99_scripts/disco.py -i <(echo "$tree") -o ../../../01_Disco/${OG/:/}.nwk -d "|" -m 4 --remove_in_paralogs --keep-labels --verbose >> ../../../01_Disco/disco.log; done < <(sed -E 's/[A-Z][a-z]{5}_//g; s/\)n[0-9]*+/\)/g' Resolved_Gene_Trees.txt)
```
alcuni file sono vuoti, li rimuoviamo per alleggerire l'analisi.

prima creiamo una copia in caso ci interessassero in futuro

```
find . -size 0 -print > empty_disco.txt

```
poi li rimuoviamo dal file che vogliamo utilizzare per analisi

```
find . -size 0 -delete
```

Disco split con script di Mirko (dentro 01_Disco),  

```
bash /home/PERSONALE/mirko.martini3/Lab_CompGeno/00_practice/99_scripts/split_disco_output.sh /home/STUDENTI/federico.salis/Lab_genomica_comparata/05_OG.Inference_Phylogenomic/00_OrthoFinder/Results_Dec01/Orthogroup_Sequence
```


#Paralog filtering 


