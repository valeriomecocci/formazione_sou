
# Scripting Bash, Strutture Dati (Array) e Controllo di Flusso

## Prerequisiti

Prima di iniziare l'esercizio, si deve generare il file di log su cui si lavorerà. Si crea un file chiamato `generatore_log.sh`
in cui si incolla il codice fornito e si esegue da terminale. 
Questo script creerà un file chiamato `metriche.txt` contenente 100 righe di dati casuali associati a 4 server aziendali.

## Descrizione del problema

L'azienda deve analizzare l'efficienza dei propri sistemi partendo dal file `metriche.txt` appena generato.
Ogni riga del file rappresenta una misurazione e contiene due informazioni separate da uno spazio: il nome del server e la percentuale di utilizzo della CPU registrata in quel momento.


## Obiettivo
Scrivere uno script Bash (un file chiamato `analizza_metriche.sh`) che legga il file `metriche.txt` riga per riga e calcoli la media di utilizzo della CPU per ogni singolo server presente nel file.


## Soluzione: script `analizza_metriche.sh`

```bash
#!/bin/bash


#array associativi

declare -A cpu_totale
#per memorizzare la somma dei valori di CPU per ogni server

declare -A occorrenze
#per memorizza quante volte ciascun server compare nel file



#lettura del file metriche.txt riga per riga
leggi_metriche() {

    while read -r server cpu
    do
        #aggiorna la somma totale della cpu del server
        cpu_totale["$server"]=$(( cpu_totale["$server"] + cpu ))

        #incrementa il numero di occorrenze del server
        occorrenze["$server"]=$(( occorrenze["$server"] + 1 ))
    
    #reindirizza il contenuto di metriche.txt all'input standard del ciclo while
    #facendo sì che read legga una riga alla volta da quel file invece che dalla tastiera.
    done < metriche.txt

}


#stampal'elenco nome_server: media_utilizzo_cpu%
stampa_report() {

    echo "=== REPORT UTILIZZO MEDIO CPU ==="

    for server in "${!cpu_totale[@]}"
    do
        #calcolo della media (divisione intera di Bash)
        media=$(( cpu_totale["$server"] / occorrenze["$server"] ))

        echo "$server: ${media}%"
    done

}


#main

leggi_metriche
stampa_report

```

## Spiegazione script

### Dichiarazione degli array

```bash
declare -A cpu_totale
declare -A occorrenze
```

Vengono creati due **array associativi**:

* `cpu_totale`: contiene la somma dei valori di CPU registrati per ogni server;
* `occorrenze`: contiene il numero di misurazioni associate a ciascun server.



---

### `leggi_metriche()`
Legge il file `metriche.txt` riga per riga e per ogni server somma il valore di cpu corrispondente e conta quante volte appare un server nel file.

```bash
while read -r server cpu
do
    ...
done < metriche.txt
```

Il ciclo `while` legge il file `metriche.txt` una riga alla volta e, dato che ogni riga è del tipo `nome_server valore_cpu`, la variabile `server` riceve il nome del server, mentre `cpu` riceve il valore numerico della CPU. Con `done < metriche.txt`
si reindirizza il contenuto di metriche.txt all'input standard del ciclo while facendo sì che `read` legga una riga alla volta da quel file invece che dalla tastiera.

Con le istruzioni

```bash
cpu_totale["$server"]=$(( cpu_totale["$server"] + cpu ))
occorrenze["$server"]=$(( occorrenze["$server"] + 1 ))
```

per ogni riga letta, il valore della CPU viene aggiunto alla somma totale del server corrispondente e ad ogni apparizione di un server, il relativo contatore viene incrementato di uno.


---

### `stampa_report()`

La funzione `stampa_report()` stampa, per ogni server, il nome del server e l'utilizzo medio
percentuale della CPU.

L'espressione

```bash
"${!cpu_totale[@]}"
```

restituisce tutte le chiavi presenti nell'array associativo, cioè l'elenco dei server individuati nel file.

Con l'istruzione seguente, viene eseguito il calcolo della media aritmetica per un server 

```bash
media=$(( cpu_totale["$server"] / occorrenze["$server"] ))
```


Bash esegue una divisione considerando solo la parte intera del quoziente.

## Output finale

![Report](screenshots/report.png)