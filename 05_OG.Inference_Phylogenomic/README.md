# Inferenza filogenomica a partire dagli ortogruppi
I genomi sono stati scaricati da NCBI, puliti con BUSCO (in realtà in questa pipeline questo passaggio è stato saltato) e ne sono stati modificatiti gli header. Questi passaggi preliminari sono presenti nel README.md di 00_data, e sempre in questa cartella è stata generata la cartella con i risultati dell'analisi Orthofinder, poi spostata in questa directory).
L'analisi con orthofinder cerca gruppi di ortologia, che comprendono anche i paraloghi. Basandosi sulle sequenze, DISCO aumenta i gruppi di ortologi e allo stesso tempo rimuovee i paraloghi (altri programmi fanno lo stesso a partire dagli alberi). Il risultato di DISCO sono alberi, "districa le radici", spacchetto i miei ortogruppi (single copy non complete, una sequenza per specie, non necessariamente per tutte le specie). Da albero iniziale grande e sporco trovo alberi piccoli relative a singoli ortogruppi.

Statistic overall contiene tutte le informazioni sulle nostre specie (es. numero specie, numero geni, numero geni in ortogruppi, ecc...)

Orthofinder genera un solo file con tutti gli alberi, DISCO ha bisogno di un file per albero. In resolved_gene_trees gli alberi sono nella seconda colonna. Facciamo un ciclo per leggere ogni riga della seconda colonna come file. 
(env tree)

## Paralog filtering

```
while IFS=' ' read -r OG tree; do python3 /home/STUDENTI/federico.salis/Lab_genomica_comparata/99_scripts/disco.py -i <(echo "$tree") -o ../../../01_Disco/${OG/:/}.nwk -d "|" -m 4 --remove_in_paralogs --keep-labels --verbose >> ../../../01_Disco/disco.log; done < <(sed -E 's/[A-Z][a-z]{5}_//g; s/\)n[0-9]*+/\)/g' Resolved_Gene_Trees.txt)
```

Alcuni file sono vuoti, li rimuoviamo per alleggerire l'analisi.
Prima creiamo una copia in caso ci interessassero in futuro:

```
find . -size 0 -print > empty_disco.txt

```
poi li rimuoviamo dal file che vogliamo utilizzare per analisi:

```
find . -size 0 -delete
```

Disco split con script di Mirko (dentro 01_Disco, filtra i paraloghi), 

```
bash /home/PERSONALE/mirko.martini3/Lab_CompGeno/00_practice/99_scripts/split_disco_output.sh /home/STUDENTI/federico.salis/Lab_genomica_comparata/05_OG.Inference_Phylogenomic/00_OrthoFinder/Results_Dec01/Orthogroup_Sequence
```

## Allineamento e trimming per costruzione alberi

Noi vogliamo studiare espansione e contrazione famiglie geniche. Usiamo cafe per conoscere numerosità e ripartizione famiglie geniche nelle varie specie e ci dice se differenze in queste contrazioni/espansioni sono significative. Ci serve tabella e time tree. Dobbiamo creare albero e calibrarlo, per farlo uso i sengle copy complete, se ci mancassero cercheremmmo tra i risultati di DISCO, se non li trovassimo neanche li accetteremmo di avviare l'analisi con specie in meno.

Da 00_OrthoFinder/Results_Dec01/Single_Copy_Orthologue_Sequences estraiamo randomicamente 200 righe. 

```
ls | shuf -n 200 > species_tree_OG.txt
```

Allinemento:

```
for OG in $(cat species_tree_OG.txt); do mafft --auto --anysymbol "$OG" > ../../../03_aligned/${OG/.fa/_aligned.faa} ; done
```

Trimming:

```
for OG in *; do bmge -i "$OG" -t AA -m BLOSUM62 -e 0.5 -g 0.4 -of ../04_trimmed/${OG/_aligned.faa/_trimmed.faa}; done
```

Per far funzionare AMAS abbiamo bisogno di avere solo il nome, senza ciò che segue la pipe

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

## Allineamento e trimming per studio contrazione/espansione famiglie geniche

Ora dobbaimo fare (partendo da 02_disco, che contiene i risultati di 01_disco filtrati dai paraloghi) l'allineamento e il trimming di tutti i disco (non gli alberi) per studiare le famiglie geniche, quindi ci servono dati sull'intero genoma, non solo i single complete.

Allineamento:

```
for file in *faa; do mafft --auto --anysymbol "$file" > ../03_aligned/prova/${file/.faa/_aligned.faa} ; done
```

Trimming:

```
for file in *; do bmge -i "$file" -t AA -m BLOSUM62 -e 0.5 -g 0.4 -of ../../04_trimmed/prova/${file/_aligned.faa/_trimmed.faa}; done
```
