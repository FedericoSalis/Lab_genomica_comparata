Genomi vengono scaricati, generalmente puliti (con BUSCO, noi non lo abbiamo fatto) e cambaiti gli header. Analisi con orthofinder cerca gruppi di ortologia, che comprende anche i paraloghi. DISCO aumenta gruppi di ortologi e allo stesso tempo toglie i paraloghi (basandosi sulle sequenze, altri programmi lo fanno con alberi). Risultato di DISCO sono alberi, "districa le radici", spacchetto i miei ortogruppi (single copy non complete, una sequenza per specie, non necessariamente per tutte le specie). Da albero iniziale grande e sporco trovo alberi piccoli relative a singoli ortogruppi.



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

Disco split con script di Mirko (dentro 01_Disco, filtra i paraloghi), 

```
bash /home/PERSONALE/mirko.martini3/Lab_CompGeno/00_practice/99_scripts/split_disco_output.sh /home/STUDENTI/federico.salis/Lab_genomica_comparata/05_OG.Inference_Phylogenomic/00_OrthoFinder/Results_Dec01/Orthogroup_Sequence
```

#Allineamento e trimming per costruzione alberi

Noi vogliamo studiare espansione e contrazione famiglie geniche. Usiamo cafe per conoscere numerosità e ripartizione famiglie geniche nelle varie specie e ci dice se differenze in queste contrazioni/espansioni sono significative. Ci serve tabella e time tree. Dobbiamo creare albero e calibrarlo, per farlo uso i sengle copy complete, se ci mancassero cercheremmmo tra i risultati di DISCO, se non li trovassimo neanche li accetteremmo di avviare l'analisi con specie in meno.

Da 00_OrthoFinder/Results_Dec01/Single_Copy_Orthologue_Sequences estraiamo randomicamente 200 righe. 

```
ls | shuf -n 200 > species_tree_OG.txt
```

comando di allenamento

```
for OG in $(cat species_tree_OG.txt); do mafft --auto --anysymbol "$OG" > ../../../03_aligned/${OG/.fa/_aligned.faa} ; done
```

trimming

```
for OG in *; do bmge -i "$OG" -t AA -m BLOSUM62 -e 0.5 -g 0.4 -of ../04_trimmed/${OG/_aligned.faa/_trimmed.faa}; done
```

per far funzionare AMAS abbiamo bisogno di avere solo il nome, senza ciò che segue la pipe

```
sed -i.old -E 's/\|.+$//' *
```

Creiamo il file concatenato delle sequenze

```
~/Lab_genomica_comparata/99_scripts/AMAS.py concat -y nexus -i *.faa -f fasta -d aa -t conc_species_tree
```

facciamo partire la costruzione dell'albero

```
iqtree -m TESTNEW -b 100 -s conc_species_tree --prefix species_tree -nt 9
```


Ora dobbaimo fare (in 02_) l'allineamento e il trimming di tutti i disco (non gli alberi)

```
for file in *faa; do mafft --auto --anysymbol "$file" > ../03_aligned/prova/$file/ da completareeeefguyewg7ofiuwehaoiruc9o4muweirghweriogvhjewio
```




