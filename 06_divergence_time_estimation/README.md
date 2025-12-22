Il primo albero è stato costruito in 05, in questa directory lo calibriamo temporalmente.
Creaiamo un file di testo con i nomi scientifici delle nostre specie e lo carichiamo su iTOL:

```
Anopheles gambiae
Culex quinquefasciatus
Aedes aegypti
Aedes albopictus
Sabethes cyaneus
Anopheles stephensi
```

iTOL ci dirà poi i tempi di divergenza stimati. Utilizziamo questi tempi per calibrare temporalmente l'albero precedentemente generato, inserendoli in un file di testo fatto in questo modo:

```
Anogam,Culqui,Aedaeg,Aedalb,Sabcya,Anoste -108.3
Aedaeg,Aedalb -48.0
```

Una volta generato questo file (calibration.txt) possiamo avviare la calibrazione temporale linkando nella directory di lavoro il file concatenato presente in /05_OG.Inference_Phylogenomic/04_trimmed/00_single_complete/, con il seguente comando:

```
iqtree -s conc_species_tree --date calibration.txt --date-tip 0 -o Anoste,Anogam -m Q.INSECT+F+I+R3 -nt 13 --prefix time_tree --date-options "-u 1"
```
