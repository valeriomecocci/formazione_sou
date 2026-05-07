# Ordinamento dell'array in shell

Comando shell che ordina un array di stringhe contenute nel file string_array.sh. 
Converte tutto in lettere minuscole e rimuove i duplicati utilizzando comandi standard Unix.

## Comando 

```sh
./string_array.sh | tr '[:upper:]' '[:lower:]' | sort | uniq
```

## Spiegazione

- `tr '[:upper:]' '[:lower:]'`: trasforma tutte le lettere maiuscole in minuscole.
- `sort`: ordina le stringhe in ordine alfabetico.
- `uniq`: rimuove le righe duplicate adiacenti, lasciando solo un occorrenza di ogni valore.

## Risultato finale

Il risultato è un elenco di stringhe in minuscolo, ordinato alfabeticamente e privo di duplicati.




# File array_sort.sh

Questo script ordina un array di stringhe in Bash, trasforma tutti gli elementi in minuscolo e rimuove i duplicati.

## Come funziona

Lo script definisce un array iniziale (`string_array`) con elementi in maiuscolo e minuscolo.
Vengono poi usate tre funzioni principali:

1. `to_lowercase()`
   - Converte ogni elemento dell'array in minuscolo usando la sintassi `${item,,}`.
   - Restituisce un nuovo array in cui tutti i valori sono normalized in lowercase.

2. `sort_array()`
   - Applica un algoritmo di bubble sort sull'array di stringhe.
  

3. `remove_duplicates()`
   - Scorre l'array ordinato e confronta ogni elemento con il precedente.
   - Aggiunge l'elemento al risultato solo se è diverso dall'ultimo inserito, eliminando i duplicati consecutivi.


## Esempio di array iniziale

```bash
string_array=(Apple cherry banana Pear orange grape cherry BANANA)
```

## Risultato finale atteso

Un elenco di parole tutte in minuscolo, ordinate alfabeticamente e con duplicati rimossi, ad esempio:

```text
apple
banana
cherry
grape
orange
pear
```




# hash_tab_sort.sh

Script Bash che ordina un array di stringhe, converte tutti i valori in minuscolo e rimuove i duplicati usando un array associativo.

## Descrizione

Il file `hash_tab_sort.sh` esegue tre operazioni principali, in questo ordine:

1. `to_lowercase()` — trasforma tutte le stringhe in minuscolo.
2. `remove_duplicates_assoc()` — elimina i duplicati usando un array associativo `seen`.
3. `sort_array()` — ordina l'array risultante con Bubble Sort.

Questa sequenza è utile perché elimina i duplicati prima dell'ordinamento, riducendo il numero di confronti richiesti dal Bubble Sort.
Tuttavia la complessità computazionale rimane la stessa dello script precedente, ossia è quadratica nell'ordine dell'input.

## Funzione per rimuovere duplicati


### `remove_duplicates_assoc()`
- Definisce un array associativo `declare -A seen`.
- Aggiunge ogni elemento a `result` solo se non è già presente in `seen`.
- Restituisce un array senza duplicati.


## Esempio di array iniziale

```bash
string_array=(Apple cherry banana Pear orange grape cherry BANANA)
```

## Risultato atteso

```text
apple
banana
cherry
grape
orange
pear
```
EOF

