# Annotazione famiglie geniche

In questa directory l’obiettivo è categorizzare funzionalmente le proteine associate agli alle famiglie geniche di interesse, per interpretare eventuali pattern di espansione/contrazione in chiave biologica.

## Preparazione dataset di partenza

Partendo dalla directory 05/02_disco, che contiene gli ortogruppi filtrati dai paraloghi tramite DISCO, eseguiamo l’allineamento e il trimming di tutti gli ortogruppi (non solo i single-copy complete, utili invece per la costruzione dell'albero filogenomico).

Allineamento con MAFFT:

```
for file in *faa; do mafft --auto --anysymbol "$file" > ../03_aligned/prova/${file/.faa/_aligned.faa} ; done
```

Trimming con BMGE:

```
for file in *; do bmge -i "$file" -t AA -m BLOSUM62 -e 0.5 -g 0.4 -of ../../04_trimmed/prova/${file/_aligned.faa/_trimmed.faa}; done
```

## Selezione seqenza rappresentativa per ogni famiglia genica

Per l’annotazione funzionale è necessario creare un database non ridondante, selezionando un rappresentante per ciascuna famiglia genica.
In questo caso viene scelta la sequenza originale più lunga ottenuta da allineamento e trimming precedenti.

Lo script (commentato) per la scelta dell'isoforma più lunga si trova in 99_scripts ed è stato lanciato all'interno di /home/STUDENTI/federico.salis/Lab_genomica_comparata/05_OG.Inference_Phylogenomic/04_trimmed/prova/.
Il risultato longest_protein_OGs.txt ha gli header delle sequenze con questa struttura:

```
>OG0000000_00_trimmed@Aedalb|LOC134291446
```

Vogliamo togliere "_trimmed":

```
sed -i 's/_trimmed//' longest_protein_OGs.txt 
```

## Annotazione funzionale e gene ontology

I GO terms sono identificatori numerici che descrivono la funzione delle proteine e sono organizzati in tre ontologie principali:
- Molecular Function;
- Cellular Component;
- Biological process.

I GO terms sono gerarchici (parent/child) e permettono di studiare l’arricchimento funzionale confrontando un insieme di proteine di interesse con un background genomico. L’arricchimento viene calcolato separatamente per ciascuna ontologia.

InterProScan viene utilizzato per assegnare annotazioni funzionali ai nostri ortogruppi:

```
/home/PERSONALE/dbs/interproscan-5.65-97.0/interproscan.sh -i <LONGEST_PROTEINS_INPUT> -goterms -pa -b <OUTPUT-FILE-BASE> -cpu <N_CPUS>
```

A partire dal file di output delle sequenze più lunghe annotate, viene costruito il background GO:

```
awk -F'\t' '{
  gsub(/@.*/,"",$1); gsub(/\([^)]*\)/,"",$2); gsub(/\|/,",",$2);
  split($2, a, ",");
  for(i in a) if(a[i]!="") seen[$1,a[i]]=1
}
END {
  for(k in seen){
    split(k, b, SUBSEP)
    groups[b[1]] = (groups[b[1]] ? groups[b[1]] "," b[2] : b[2])
  }
  for(g in groups) print g "\t" groups[g]
}' <(cut -f1,14 longest_federico.faa.tsv) | grep -v "-" > go_back.tsv
```

Questo file è stato poi elaborato insieme ad un altro (contenete la lista dei nomi degli ortogruppi risultati interessanti al termine di 07) tramite lo script GO_enrichment.R, disponibile a questo path:

```
Lab_CompGeno/2025/09_GeneAnnotation_functional_enrichment/00_script/GO_Enrichment.R
```

## Diamond

L'annotazione con DIAMOND (blastp) esegue un blast delle nostre sequenze confrontandole con un database di riferimento (NCBI). Per ogni sequenza di riferimento restituisce una lista delle 25 proteine più simili presenti nel database, fornendo, quando disponibili anche le descrizioni funzionali per le proteine caratterizzate.

```
diamond makedb --in /var/local/diamond_db/nr.gz --db ./nr_diamond
```
