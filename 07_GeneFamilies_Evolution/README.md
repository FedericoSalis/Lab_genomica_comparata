# Analisi evoluzione delle famiglie geniche

## Preparazione input per CAFE

CAFE usa un modello di birth and death per stimare la contrazione/espansione famiglie geniche.
Per avviare l'analsi cafe è necessario un time tree in formato .nwk e di una matrice di conteggio delle famiglie geniche.

L'albero generato in 06 è in formato .nex. Possiamo modificarne il formato tramite il sito iTOL, caricando il file .nex, esportandolo come .nwk e facendo copia e incolla del risultato in un file (qui denominato timetree.nwk).

La matrice di conteggio è presente tra i risultati di Orthofinder (Orthogroups.GeneCount.tsv), va però prima modificata per rimuovere l'ultima colonna, che non ci interessa:

```
sed $'s/^/NONE\t/g' Orthogroups.GeneCount.tsv | rev | cut -f 2- | rev > ../../../../07_GeneFamilies_Evolution/GeneCount_CAFE.tsv
```

Ora abbiamo tutto il necessarioper avviare l'analisi CAFE:

```
cafe5 -i GeneCount_CAFE.tsv -t timetree.nwk -o Error_model -e
```

## Parametrizzazione di CAFE 

L'analisi standard di CAFE considera le specie come se avessero lo stesso tasso di death and birth, quindi con un tasso di turnover delle famiglie geniche costante (una sola λ).
Questo parametro è variabile prendendo in considerazione più di un valore di λ.
All'aumento della parametrizzazione il modello si fa più complesso, adattandosi meglio ai dati forniti, permettendo  quindi a λ di variare in modo diverso per ogni specie si ottengono valori di likelihood più alti. Pertanto diventa necessario impiegare metodi di scelta che penalizzino le parametrizzazioni più alte (AIC/BIC).

A partire dalle nostre specie e dalla domanda biologica di ricerca decidiamo come far variare λ.
Il parametro gamma introduce eterogeneità nei tassi di espansione e contrazione tra famiglie geniche, mentre λ modella la variabilità tra specie. Gamma descrive la variabilità con una distribuzione di probabilità dei tassi tra famiglie.

Per valutare la variabilità di risposta dello strumento eseguiamo dieci replicati tecnici (l'analisi non è deterministica). Consideriamo cinque livelli di complessità parametrica (K=5).
Per ciascuna combinazione di K e replicato tecnico creiamo le directory di output e avviamo CAFE utilizzando l’error model stimato nell'analisi CAFE precedente.

```
for k in {1..5}; do for n in {1..10}; do mkdir -p 00_1L/${k}K/${n}N; cafe5 -i GeneCount_CAFE.tsv -t timetree.nwk -o 00_1L/${k}K/${n}N -eError_model/Base_error_model.txt -k ${k}; done; done
```

Per l'analisi con 2 lambda abbiamo bisogno di un file per specificare i diversi regimi di λ.
Il file può essere prodotto a partire dal file .nwk, ottenendo come risultato un file con una struttura di questo tipo:

```
((Anogam:2,Anoste:2):1,(Culqui:2,(Sabcya:1,(Aedalb:1,Aedaeg:1):1):1):1);
```

Una volta creato il file possiamo lanciare il seguente comando:

```
for k in {1..5}; do for n in {1..10}; do mkdir -p 00_2L/${k}K/${n}N; cafe5 -i GeneCount_CAFE.tsv -t timetree.nwk -o 00_2L/${k}K/${n}N  -y timetree2L.nwk -eError_model/Base_error_model.txt -k ${k}; done; done
```

## Scelta del modello

Per la scelta del modello migliore l'analisi è stata suddivida in due parti:
- confronto tra i dieci replicati per ogni parametrizzazione di λ;
- confronto tra i modelli migliori delle due λ (1λ vs 2λ).

Per Gamma = 1 (K1) 

```
for folder in */; do lnL=$(grep "lnL" ${folder}/Base_results.txt | grep -oE "[0-9]*\.[0-9]*"); L=$(grep "Lambda" ${folder}/Base_results.txt | grep -oE "[0-9]*\.[0-9]*"); E=$(grep "Epsilon" ${folder}/Base_results.txt | grep -oE "[0-9]*\.[0-9]*"); echo -e "$lnL\t$L\t$E" >> sum_results.tsv; done
```

Per Gamma > 1 (K2-5)

```
for i in */; do cd $i; for folder in */; do lnL=$(grep "lnL" ${folder}/Gamma_results.txt | grep -oE "[0-9]+(\.[0-9]+)?"); L=$(grep "Lambda" ${folder}/Gamma_results.txt | grep -oE "[0-9]*\.[0-9]*"); E=$(grep "Epsilon" ${folder}/Gamma_results.txt | grep -oE "[0-9]*\.[0-9]*"); A=$(grep "Alpha" ${folder}/Gamma_results.txt | grep -oE "[0-9]*\.[0-9]*"); echo -e "$lnL\t$L\t$E\t$A" >> sum_results.tsv; done; cd ..; done
```

Per selezionare modello migliore a parità di λ:

```
for f in */; do cut -f1 "$f"/sum_results.tsv | sort -n | head -n1; done > all_L.txt
```

Calcolo AIC e BIC per i migliori replicati:

```
paste --delimiters=$"\t" all_L.txt <(while IFS=$'\t' read -r L k; do echo "2*$k + 2*$L" | bc; done < all_L.txt) <(while IFS=$'\t' read -r L k; do echo "$k*9.26 + 2*$L" | bc; done < all_L.txt) | sort -k4,4n > AIC_BIC.tsv
```

Confronto finale tra i modelli migliori a 1λ e 2λ:

```
paste --delimiters=$"\t" L_res.txt <(while IFS=$'\t' read -r L k; do echo "2*$k + 2*$L" | bc; done < L_res.txt) <(while IFS=$'\t' read -r L k; do echo "$k*9.26 + 2*$L" | bc; done < L_res.txt) | sort -k4,4n > AIC_BIC.tsv
```

## Risultati CAFE di interesse

### Output Base:

- Base_results.txt
Riassume le statistiche generali del modello: qualità del fit (likelihood), valore di λ (tasso di turnover delle famiglie geniche nel tempo), ε (frazione di famiglie geniche statiche, senza turnover), valore massimo di λ consentito (threshold dei valori prodotti) e numero di iterazioni effettuate.

- Base_asr.tre
Albero con ricostruzione degli stati ancestrali.
I numeri tra <> indicano i nodi interni (numerati dal più recente al più antico), mentre i numeri senza <> rappresentano il numero di membri di ciascuna famiglia genica nelle specie terminali (ortogruppi considerati come famiglie geniche).
In questo file vengono stimati anche i valori per i nodi interni, partendo dalla distribuzione osservata nelle tip.
La presenza di un asterisco su un nodo indica una variazione significativa del numero di membri rispetto al nodo precedente.

- Base_change.tab
Tabella con colonne per specie e per nodi interni, contenente la differenza nel numero di membri di ciascuna famiglia genica tra un nodo e il nodo precedente.

- Base_clade_results.txt
Riporta il numero di famiglie geniche significativamente espanse o contratte per ciascun clade.

- Base_count.tab
Conteggio grezzo del numero di membri per famiglia genica in ciascuna specie.

- Base_family_results.txt
Tabella riassuntiva con l’elenco delle famiglie geniche, il p-value associato all’espansione/contrazione e l’indicazione di significatività (y/n), ovvero se la famiglia presenta almeno un nodo con variazione significativa.

### Output Gamma:

Quando l’analisi viene eseguita includendo il parametro gamma, i file di output sono analoghi, ma con prefisso Gamma al posto di Base.

Gamma_results.txt
Contiene le statistiche del modello con gamma. Le famiglie più grandi tendono ad adattarsi peggio al modello e mostrano più fallimenti; non vengono escluse dall’analisi, ma devono essere interpretate con attenzione.
Il parametro α definisce la forma della distribuzione gamma: valori più alti indicano un’evoluzione più lenta delle famiglie, mentre valori più bassi riflettono tassi di evoluzione più rapidi.

## Ricerca di famiglie geniche con pattern interessanti in base alla domanda biologica

La domanda biologica (su cui si è scelto di provare ad analizzare anche con 2λ) divide il gruppo di specie in esame in due.
Sono stati quindi ricercati all'interno del file contenente tutti gli alberi (5K/6N) quelli con pattern di espansione/contrazione significativi relativi alle specie di interesse. Dato che non c'è un motivo per cui ha senso l'espansione/contrazione di uno solo dei due gruppi cerchiamo se ci sono differenze significative in entrambi i gruppi rispetto all'altro:

```
grep '1>\*' Gamma_asr.tre | grep '2>\*' | grep '3>\*' | grep '4>_' | grep '5>_' | grep '6>_' | less
grep '1>_' Gamma_asr.tre | grep '2>_' | grep '3>_' | grep '4>\*' | grep '5>\*' | grep '6>\*' | less
```

A seguito di questa estrazione sono risultati interessanti, rispettivamente, per il primo comando:

```
OG0000047
```

per il secondo:

```
OG0000006
OG0000016
OG0000045
OG0000049
OG0000296
```

Dato che una delle specie poteva introdurre bias nell'analisi, non rispecchiando adeguatamente le caratteristiche del gruppo assegnatole, sono stati estratti secondariamente altre famiglie geniche senza contare questa sepecie (Sabethes cyaneus):

```
grep '1>\*' Gamma_asr.tre | grep '2>\*' | grep '3>\*' | grep '5>_' | grep '6>_' | less
grep '1>_' Gamma_asr.tre | grep '2>_' | grep '3>_' | grep '5>\*' | grep '6>\*' | less
```

A seguito di questa estrazione sono stati aggiunti, per il primo comando:

```
OG0000022
OG0000039
```

con il secondo:

```
OG0000009
OG0000080
OG0000198
OG0000636
OG0000721
```
