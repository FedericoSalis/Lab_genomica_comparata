# Annotazione famiglie geniche
 
Qui cerchiamo di categorizzare le nostre proteine 

Dobbiamo creare un database identificando un rappresentante per ortogruppo scegliendo la sequenza originale più lunga dopo allineamento e trimming. Sequenze associate a GOterm, li confronto con la variabilità del mio genoma e vedo se ci sono geni significativi legati al tratto biologico che mi interessa. Con bibliografia poi cerchiamo di capire se effettivamente c'è un legame o correlazione spuria. 
GOterm -> codice numerico (la parte alfa è GO) che determina funzione proteina. Ci sono tre tipi di annotazione (ontologies): funzione molecolare, cellular components (collocazione all'interno della cellula o processo biologico (funzione all'interno di una determinata via)
Arricchimento avviene invece per singole ontologie. Dato un gruppo di proteine di interesse cerchiamo  i loro Go e confrontiamo loro variabilità con variabilità di intero background, cechiamo quindi quelle che sono evolute in modo significvativamente diverso
GOterm hanno gerarchicità e vengono divisi in parent e child, ad esempio un parent può essere genericamente collegato ad una via metabolica mentre child è una specifica di questo (ad esempio degradazione di una molecola di quella via.
KEGG è un database che classifica qualunque proteina ortologa di specie diverse con un codice KO, molto utile quando abbiamo simboli o descrizione diverse per confrontare le ortologie.

QUESTO VA IN 06 O 07 -> Leghiamo differenza dei tratti a espansione/contrazione famiglie geniche differenziale. ho varie lambda, che acaratterizzano mie specie in modo diverso, cerchiamo migliori lambda per modello. vale comunque che più parametri aumentano calcolo computazionale e non necessariamente ne vale la pena

Lo script (commentato) per la scelta dell'isoforma più lunga si trova in 99_scripts, quest'ultimo è stato lanciato all'interno di /home/STUDENTI/federico.salis/Lab_genomica_comparata/05_OG.Inference_Phylogenomic/04_trimmed/prova/. Il risultato longest_protein_OGs.txt ha gli header delle sequenze con questa struttura:

```
>OG0000000_00_trimmed@Aedalb|LOC134291446
```
Vogliamo togliere "trimmed":

```
sed -i 's/trimmed//' longest_protein_OGs.txt 
```

I nomi delle proteine li otteniamo prendendo il locus (ciò che segue la pipe negli header) e cercandolo su ncbi 

Diamond fa un blast p (proteico) e otteniamo le 25 proteine più simili alla nostra sequenza. Diamond viene attivato con lo script info_gene_didattica.sh. Enrichment con  script R GO_enrichment.R in Script_box.

## 
