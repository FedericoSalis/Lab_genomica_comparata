# Analisi evoluzione delle famiglie geniche

CAFE usa un modello di birth and death per stimare la contrazione/espansione famiglie geniche. Per avviarlo ci serve un time tree in formato .nwk e di una tabella (Orthogroups.GeneCount.tsv, presente tra i risultati di Orthofinder, va prima modificata però)
Il nostro albero è in formato .nex, lo trasformiamo con iTOL, caricando il file .nex, esportandolo come .nwk e facendo copia e incolla del risultato in un file (timetree.nwk).
La tabella di otogruppi è presente tra i risultati di Orthofinder (Orthogroups.GeneCount.tsv), va però prima modificata per rimuovere l'ultima colonna, che non ci interessa:

```
sed $'s/^/NONE\t/g' Orthogroups.GeneCount.tsv | rev | cut -f 2- | rev > ../../../../07_GeneFamilies_Evolution/GeneCount_CAFE.tsv
```
Ora possiamo avviare CAFE:

```
cafe5 -i GeneCount_CAFE.tsv -t timetree.nwk -o Error_model -e
```

# Parametrizzazione di CAFE 
L'analisi standard considera come le specie evolventi con stessa proporzione di death and birth (una sola λ). Noi possiamo giocare con questo parametro prendendo in considerazione λ diverse da 1. Assegnando una λ per specie abbiamo una likelihood più alta, ma il modello più semplice rimane quello più probabile. A partire dalle nostre specie decidiamo se attribuire diverse λ.è la proporzione tra birth and death.
Il parametro gamma aggiunge variabilità espansione/contrazione tra famiglie, dove λ lo fa tra specie, è una distribuzione di probabilità.

Facciamo 10 replicati tecnici per capire la variabilità di risposta dello strumento. Lo facciamo per 5 K (5 livelli di complessità parametrica). Con un for creiamo innanzitutto le cartelle dove inserire i nostri output. Poi avviamo l'analisi con 1 k e error model dall'output dell'analisi cafe precedente:

```
for k in {1..5}; do for n in {1..10}; do mkdir -p 00_1L/${k}K/${n}N; cafe5 -i GeneCount_CAFE.tsv -t timetree.nwk -o 00_1L/${k}K/${n}N -eError_model/Base_error_model.txt -k ${k}; done; done
```

Per l'analisi con 2 lambda abbiamo bisogno di un file per specificare i lambda, e lo facciamoa a partire dal .nwk, ottenendo qualcosa del genere:

```
((Anogam:2,Anoste:2):1,(Culqui:2,(Sabcya:1,(Aedalb:1,Aedaeg:1):1):1):1);
```

Una volta creato il file lanciamo il comando:

```
for k in {1..5}; do for n in {1..10}; do mkdir -p 00_2L/${k}K/${n}N; cafe5 -i GeneCount_CAFE.tsv -t timetree.nwk -o 00_2L/${k}K/${n}N  -y timetree2L.nwk -eError_model/Base_error_model.txt -k ${k}; done; done
```

## Scelta del modello

Per gamma = 1 (K1) 

```
for folder in */; do lnL=$(grep "lnL" ${folder}/Base_results.txt | grep -oE "[0-9]*\.[0-9]*"); L=$(grep "Lambda" ${folder}/Base_results.txt | grep -oE "[0-9]*\.[0-9]*"); E=$(grep "Epsilon" ${folder}/Base_results.txt | grep -oE "[0-9]*\.[0-9]*"); echo -e "$lnL\t$L\t$E" >> sum_results.tsv; done
```

Per gamma > 1

```
for i in */; do cd $i; for folder in */; do lnL=$(grep "lnL" ${folder}/Gamma_results.txt | grep -oE "[0-9]+(\.[0-9]+)?"); L=$(grep "Lambda" ${folder}/Gamma_results.txt | grep -oE "[0-9]*\.[0-9]*"); E=$(grep "Epsilon" ${folder}/Gamma_results.txt | grep -oE "[0-9]*\.[0-9]*"); A=$(grep "Alpha" ${folder}/Gamma_results.txt | grep -oE "[0-9]*\.[0-9]*"); echo -e "$lnL\t$L\t$E\t$A" >> sum_results.tsv; done; cd ..; done
```

pr stessa lambda troviamo la migliore con:

```
for f in */; do cut -f1 "$f"/sum_results.tsv | sort -n | head -n1; done > all_L.txt
```

```
paste --delimiters=$"\t" all_L.txt <(while IFS=$'\t' read -r L k; do echo "2*$k + 2*$L" | bc; done < all_L.txt) <(while IFS=$'\t' read -r L k; do echo "$k*9.26 + 2*$L" | bc; done < all_L.txt) | sort -k4,4n > AIC_BIC.tsv
```

```
paste --delimiters=$"\t" L_res.txt <(while IFS=$'\t' read -r L k; do echo "2*$k + 2*$L" | bc; done < L_res.txt) <(while IFS=$'\t' read -r L k; do echo "$k*9.26 + 2*$L" | bc; done < L_res.txt) | sort -k4,4n > AIC_BIC.tsv
```

## Risultati CAFE di interesse

Base_results.txt -> ci informa su quanto fitta il modello, likelihood, Lambda (turnover famiglie nel tempo), Epsilon (porzione famiglie geniche statiche, che non hanno un turnover), lambda massima (treshold valori prodotti), numero di iterazioni
Base_asr.tre -> numeri in <> sono i numeri dei nodi (numerati da più recente a più antico), i numeri senza <> sono membri di famiglia genica per specie (ricordiamo di considerare gli ortogruppi coime fossero famiglie geniche). Per specie in realtà li sappiamo già in questo file abbiamo però anche il calcolo dei numeri per i nodi interni. Viene inferito stato ancestrale, calcolando prima i modelli migliori. Parte da info distribuzione stato delle tip e ricostruisce lungo il tempo passato. Alcuni nodi hanno asterisco, questo indica una modificazione del numero significativa rispetto al numero precedente, questo ci aiuta poi a provare ad interpretare se correlazione è spuria o meno.
Base_change.tab -> Tabella con colonne per specie e per nodi interni, contiene la differenza tra numero membri inferiti per un nodo e nodo precedente per ogni famiglia genica.
Base_clade_results.txt -> numero famiglie significativamente incrementate o decrementate.
Base_count.tab -> conta pura dei membri per famiglia per specie.
Base_family_results -> colonne con famiglie, p-value contrazione/espansione, significatività (y/n) (almeno un nodo in cui famiglia è significativamente diversa. 

Stessi file con Gamma al posto che Base per quando viene analizzata con più gamma:

Gamma_results.txt -> famiglie più grandi sono più difficile da far aderire al modello, hanno naturalmente più fallimenti, non le escludiamo dall'analisi ma interpretiamo con attenzione. Parametro alfa (unica vera differenza rispetto a Base per quanto riguarda i parametri) determina forma della gamma distribution, più è grande più sono le evoluzioni lente rispetto alle veloci


Con lo script extract.sh otteniamo i valori di likelihood, scegliamo quella più bassa (5K/5N) 

## patter di ricerca ortogruppi interessanti 

```
(tree) STUDENTI^federico.salis@SGBGA-D142242S:~/Lab_genomica_comparata/07_GeneFamilies_Evolution/00_2L/5K/6N$ grep -E 'Anogam<[^>]*>\*' Gamma_asr.tre \
| grep -E 'Anoste<[^>]*>\*' \
| grep -E 'Culqui<[^>]*>\*' \
| grep -Ev '(Sabcya|Aedalb|Aedaeg)<[^>]*>\*'
  TREE OG0000047 = ((Anogam<1>*_3:31.4355,Anoste<2>*_10:31.4355)<8>_6:76.8645,(Culqui<3>*_30:80.6431,(Sabcya<4>_5:79.6431,(Aedalb<5>_4:48,Aedaeg<6>_4:48)<11>*_4:31.6431)<10>_6:1)<9>_6:27.6569)<7>_6;
(tree) STUDENTI^federico.salis@SGBGA-D142242S:~/Lab_genomica_comparata/07_GeneFamilies_Evolution/00_2L/5K/6N$ grep -E 'Anogam<[^>]*>[^*]' Gamma_asr.tre \
| grep -E 'Anoste<[^>]*>[^*]' \
| grep -E 'Culqui<[^>]*>[^*]' \
| grep -E 'Sabcya<[^>]*>\*' \
| grep -E 'Aedalb<[^>]*>\*' \
| grep -E 'Aedaeg<[^>]*>\*'
  TREE OG0000006 = ((Anogam<1>_3:31.4355,Anoste<2>_2:31.4355)<8>*_4:76.8645,(Culqui<3>_18:80.6431,(Sabcya<4>*_57:79.6431,(Aedalb<5>*_41:48,Aedaeg<6>*_1:48)<11>_22:31.6431)<10>_22:1)<9>*_22:27.6569)<7>_17;
  TREE OG0000016 = ((Anogam<1>_1:31.4355,Anoste<2>_1:31.4355)<8>*_2:76.8645,(Culqui<3>_12:80.6431,(Sabcya<4>*_7:79.6431,(Aedalb<5>*_36:48,Aedaeg<6>*_35:48)<11>*_29:31.6431)<10>_12:1)<9>_12:27.6569)<7>_10;
  TREE OG0000045 = ((Anogam<1>_5:31.4355,Anoste<2>_5:31.4355)<8>_5:76.8645,(Culqui<3>_11:80.6431,(Sabcya<4>*_4:79.6431,(Aedalb<5>*_29:48,Aedaeg<6>*_3:48)<11>_8:31.6431)<10>_7:1)<9>_7:27.6569)<7>_7;
  TREE OG0000049 = ((Anogam<1>_2:31.4355,Anoste<2>_1:31.4355)<8>*_2:76.8645,(Culqui<3>_5:80.6431,(Sabcya<4>*_36:79.6431,(Aedalb<5>*_11:48,Aedaeg<6>*_0:48)<11>_7:31.6431)<10>_8:1)<9>_8:27.6569)<7>_7;
  TREE OG0000296 = ((Anogam<1>_3:31.4355,Anoste<2>_3:31.4355)<8>_3:76.8645,(Culqui<3>_3:80.6431,(Sabcya<4>*_1:79.6431,(Aedalb<5>*_1:48,Aedaeg<6>*_7:48)<11>_3:31.6431)<10>_3:1)<9>_3:27.6569)<7>_3;

```

