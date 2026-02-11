# Genome annotation

In questa directory ci si occupa dell'annotazione strutturale a livello genomico, andando cioè ad identificare le componenti genomiche (es. esoni, introni, pseudogeni, trasposoni, ecc).

## Transposons annotation

Il genoma è stato annotato tramite la raccolta di sequenze consensus con RepeatModeler.
La libreria di consens generata da RepeatModeler è stata poi utilizzata da RepeatMasker per l'annotazione vera e propria (in questa pipeline, questo passaggio è stato eseguito all'interno di MAKER).

La library di RepeatModeler è recuperabile con questo path:

```
/home/PERSONALE/mirko.martini3/01_2024/00_Data/02_annotation/Anoste_RepeatModeler_library.fa
```

## MAKER rnd 1

Innanzitutto è necessario raccogliere evidenze esterne (es. NCBI). In questo caso non disponiamo di un trascrittoma, ma teoricamente sarebbe importante. Nei prossimi passaggi viene descritto come generare i file di configurazione per MAKER.

```
maker -CTL
```

Vengono generati tre file:
- maker_bopts: parametri per i software utilizzati da MAKER, di default sono stati mantenuti i parametri standard.

- maker_exe: percorsi per tutti i software.

- maker_opts: parametri per l’esecuzione di MAKER, questi sono da modificare

Nel file opts.ctl vanno impostati i path per i file di input:

```
    #-----Genome (these are always required)
    genome= <GENOME> #genome sequence (fasta file or fasta embeded in GFF3 file)
    organism_type=eukaryotic #eukaryotic or prokaryotic. Default is eukaryotic
    
    #-----Re-annotation Using MAKER Derived GFF3
    maker_gff= #MAKER derived GFF3 file
    est_pass=0 #use ESTs in maker_gff: 1 = yes, 0 = no
    altest_pass=0 #use alternate organism ESTs in maker_gff: 1 = yes, 0 = no
    protein_pass=0 #use protein alignments in maker_gff: 1 = yes, 0 = no
    rm_pass=0 #use repeats in maker_gff: 1 = yes, 0 = no
    model_pass=0 #use gene models in maker_gff: 1 = yes, 0 = no
    pred_pass=0 #use ab-initio predictions in maker_gff: 1 = yes, 0 = no
    other_pass=0 #passthrough anyything else in maker_gff: 1 = yes, 0 = no
    
    #-----EST Evidence (for best results provide a file for at least one)
    est= #set of ESTs or assembled mRNA-seq in fasta format
    altest= #EST/cDNA sequence file in fasta format from an alternate organism
    est_gff= #aligned ESTs or mRNA-seq from an external GFF3 file
    altest_gff= #aligned ESTs from a closly relate species in GFF3 format
    
    #-----Protein Homology Evidence (for best results provide a file for at least one)
    protein= <PROTEOME> #protein sequence file in fasta format (i.e. from mutiple oransisms)
    protein_gff=  #aligned protein homology evidence from an external GFF3 file
    
    #-----Repeat Masking (leave values blank to skip repeat masking)
    model_org=<EMPTY> #select a model organism for RepBase masking in RepeatMasker
    rmlib= <RepeatModeler_library> #provide an organism specific repeat library in fasta format for RepeatMasker
    repeat_protein= #provide a fasta file of transposable element proteins for RepeatRunner
    rm_gff= #pre-identified repeat elements from an external GFF3 file
    prok_rm=0 #forces MAKER to repeatmask prokaryotes (no reason to change this), 1 = yes, 0 = no
    softmask=1 #use soft-masking rather than hard-masking in BLAST (i.e. seg and dust filtering)
    
    #-----Gene Prediction
    snaphmm= #SNAP HMM file
    gmhmm= #GeneMark HMM file
    augustus_species= #Augustus gene prediction species model
    fgenesh_par_file= #FGENESH parameter file
    pred_gff= #ab-initio predictions from an external GFF3 file
    model_gff= #annotated gene models from an external GFF3 file (annotation pass-through)
    est2genome=0 #infer gene predictions directly from ESTs, 1 = yes, 0 = no
    protein2genome=<0 OR 1> #infer predictions from protein homology, 1 = yes, 0 = no
    trna=0 #find tRNAs with tRNAscan, 1 = yes, 0 = no
    snoscan_rrna= #rRNA file to have Snoscan find snoRNAs
    unmask=0 #also run ab-initio prediction programs on unmasked sequence, 1 = yes, 0 = no
    
    #-----Other Annotation Feature Types (features MAKER doesn't recognize)
    other_gff= #extra features to pass-through to final MAKER generated GFF3 file
    
    #-----External Application Behavior Options
    alt_peptide=C #amino acid used to replace non-standard amino acids in BLAST databases
    cpus=<CPUS> #max number of cpus to use in BLAST and RepeatMasker (not for MPI, leave 1 when using MPI)
    
    #-----MAKER Behavior Options
    max_dna_len=100000 #length for dividing up contigs into chunks (increases/decreases memory usage)
    min_contig=1 #skip genome contigs below this length (under 10kb are often useless)
    
    pred_flank=200 #flank for extending evidence clusters sent to gene predictors
    pred_stats=<0 or 1> #report AED and QI statistics for all predictions as well as models
    AED_threshold=1 #Maximum Annotation Edit Distance allowed (bound by 0 and 1)
    min_protein=50 #require at least this many amino acids in predicted proteins
    alt_splice=0 #Take extra steps to try and find alternative splicing, 1 = yes, 0 = no
    always_complete=0 #extra steps to force start and stop codons, 1 = yes, 0 = no
    map_forward=0 #map names and attributes forward from old GFF3 genes, 1 = yes, 0 = no
    keep_preds=0 #Concordance threshold to add unsupported gene prediction (bound by 0 and 1)
    
    split_hit=10000 #length for the splitting of hits (expected max intron size for evidence alignments)
    single_exon=0 #consider single exon EST evidence when generating annotations, 1 = yes, 0 = no
    single_length=250 #min length required for single exon ESTs if 'single_exon is enabled'
    correct_est_fusion=0 #limits use of ESTs in annotation to avoid fusion genes
    
    tries=2 #number of times to try a contig if there is a failure for some reason
    clean_try=0 #remove all data from previous run before retrying, 1 = yes, 0 = no
    clean_up=0 #removes theVoid directory with individual analysis files, 1 = yes, 0 = no
    TMP= #specify a directory other than the system default temporary directory for temporary files
```

Per avviare MAKER:

```
maker -base <OUTPUT PREFIX>
```

Per creare il file gff3 e il file di proteine/trascrittoma:

```
fasta_merge -d <DATASTORE INDEX FILE>
gff3_merge -d <DATASTORE INDEX FILE>
```

Per riassumere i risultati dell'analisi possiamo utilizzare AGAT:

```
agat_sp_statistics.pl --gff file.gff -o <output_file>        #Summary statistics of gene models
agat_sq_repeats_analyzer.pl -i <input_file> -o <output_file> #Summary statistics of repeats
```

## SNAP and Augustus training

### SNAP

Per annotare geni codificanti in genomi de novo utilizziamo SNAP.
SNAP impiega un approccio probabilistico basato su HMM per modellare le caratteristiche dei geni e può essere addestrato per migliorarne l’accuratezza su organismi specifici. Può essere utilizzato anche in parallelo ad altri strumenti, per incrociare poi i risultati e ottenere un’annotazione di consenso.

Per preparare, addestrare ed elaborare la predizione genica viene utilizzato Fathom, parte del pacchetto SNAP.

```
#I suggest you to create a small script with all these commands because are really fast
maker2zff -c 0 -e 0  -l 80 -x 0.1 -d <datastore_index> #To extract gene models based on mutiple filter criterion. It transforms maker output into .zff files, the format for SNAP
fathom <.ANN FILE> <.DNA FILE> -gene-stats #Print some summary statistics of the selected gene models
fathom <.ANN FILE> <.DNA FILE> -validate #Validate gene models and print summary statistics. output is in the stdout and cannot be redirected
fathom <.ANN FILE> <.DNA FILE> -categorize 1000 #Extract gene modeles together with 1000 bp at both ends for training
fathom <UNI.ANN FILE> <UNI.DNA FILE> -export 1000 -plus #Export and convert unique genes to strand plus. Tipically, only the unique genes are sued for training and testing. The value limits the intergenic sequence at the ends.
forge <export.ann> <export.dna> #call the parameter estimation program, better in another directory
hmm-assembler.pl <NAME> <FORGE DIRECTORY> > <OUTPUT HMM FILE>
```

### Augustus

L'addestramento in questo caso è molto più dispendioso a livello computazionale, ma è anche molto performate nella predizione. In questo caso ci si concentra sulla separazione esoni/introni.

Per accorciare i tempi in questo caso il training di Augustus è avvenuto all'interno di BUSCO:

```
busco -i ../../03_GenomeAssembly/03_scaffolding/Anoste_chr.fasta -c 30 -l $BUSCO/culicidae_odb12 --augustus --long -m genome --out Anoste_cu --augustus_parameters='--progress=true'
```

## MAKER rnd 2

Dopo aver adeguatamente modificato i file di configurazione di MAKER per adattarli a questo secondo round, possiamo avviare MAKER

## Evaluation of a gene set

Per valutare l’annotazione del genoma possiamo confrontare le statistiche dei geni con dati bibliografici, eseguire BUSCO sulle proteine predette, riassumere i valori di AED o allineare il trascrittoma de novo con le predizioni basate sul genoma.

Per ottenere le statistiche:

```
gaas_maker_merge_outputs_from_datastore.pl Anoste_rnd2.maker.output/ #script for summary statistic, merge fastas and gffs
agat_sq_repeats_analyzer.pl --gff maker_mix.gff -o Anoste_rnd2_repeats.txt #use maker_mix, which is the complete one
```
