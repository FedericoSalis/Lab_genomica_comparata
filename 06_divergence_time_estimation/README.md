# Calibrazione temporale albero

Il primo albero è stato costruito in 05_OG.Inference_Phylogenomic, in questa directory lo calibriamo temporalmente.
Creaiamo un file di testo con i nomi scientifici delle nostre specie e lo carichiamo su timetree.org:

```
Anopheles gambiae
Culex quinquefasciatus
Aedes aegypti
Aedes albopictus
Sabethes cyaneus
Anopheles stephensi
```

Il sito ci restituirà ci poi i tempi di divergenza stimati. 
In questo caso Anopheles stephensi presenta un asterisco. Questo indica la mancanza di informazioni per la specie, che viene quindi sostituita con un'altra appaertenente allo stesso genere (Anopheles karwari), la divergenza tra le due specie del genere Anopheles non viene quindi presa in considerazione nel prossimo passaggio.
Utilizziamo i tempi ottenuti su timetree.org per calibrare temporalmente l'albero precedentemente generato, inserendoli in un file di testo con questa struttura (calibration.txt):

```
Anogam,Culqui,Aedaeg,Aedalb,Sabcya,Anoste -108.3
Aedaeg,Aedalb -48.0
```

Una volta generato questo file di calibrazione possiamo avviare la calibrazione temporale (linkando prima nella directory di lavoro il file concatenato presente in /05_OG.Inference_Phylogenomic/04_trimmed/00_single_complete/, la cui generazione è spiegata in 05) con il seguente comando. Il modello (-m) lo troviamo specificato nel file .iqtree ottenuto durante la generazione dell'albero originale.

```
iqtree -s conc_species_tree --date calibration.txt --date-tip 0 -o Anoste,Anogam -m Q.INSECT+F+I+R3 -nt 13 --prefix time_tree --date-options "-u 1"
```
