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

Facciamo 10 replicati tecnici per capire la variabilità di risposta dello strumento. Lo facciamo per 5 K (5 livelli di complessità parametrica. Con un for creiamo innanzitutto le cartelle dove inserire i nostri output. Poi avviamo l'analisi con 1 k  e error model dall'output dell'analisi cafe precedente:

```
for k in {1..5}; do for n in {1..10}; do mkdir -p 00_1L/${k}K/${n}N; cafe5 -i GeneCount_CAFE.tsv -t timetree.nwk -o 00_1L/${k}K/${n}N -eError_model/Base_error_model.txt -k ${k}; done; done
```


Per l'analisi con 2 lambda abbiamo bisogno di un file per specificare i lambda, e lo facciamoa apartire dal .nwk, ottenendo qualcosa di simile a:

```
((Anogam:2,Anoste:2):1,(Culqui:2,(Sabcya:1,(Aedalb:1,Aedaeg:1):1):1):1);
```

