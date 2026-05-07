#!/usr/bin/env bash

#Questo script contiene un array di stringhe alfanumeriche che possono essere disordinate, 
#duplicate e scritte con caratteri maiuscoli e minuscoli. 
#Questo array nel file string_array.sh deve essere utilizzato
#nella shell in modo da modificare l'output e visualizzare un array ordinato, senza duplicati e in minuscolo.



string_array=(apple CheRry apple BANANA pear cherry oranGe gRape)

print_array() {
    for element in "${string_array[@]}"; do
        echo "$element"
    done
}

print_array

#in questo modo con comando sort si possono ordinare le stringhe perché SORT ordina le RIGHE di testo, 
#non le parole all'interno di una riga.

# comando da shell
# print_array | tr '[:upper:]' '[:lower:]' | sort | uniq
#con tr '[:upper:]' '[:lower:]' si convertono tutte le lettere maiuscole in minuscole,
#con sort si ordinano le stringhe in ordine alfabetico, e con uniq si rimuovono le stringhe duplicate,
# restituendo un elenco ordinato, senza duplicati e in minuscolo.



