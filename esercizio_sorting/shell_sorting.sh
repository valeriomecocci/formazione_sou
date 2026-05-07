#!/usr/bin/env bash

# comando da scrivere nella shell:

./string_array.sh | tr '[:upper:]' '[:lower:]' | sort | uniq

#con tr '[:upper:]' '[:lower:]' si convertono tutte le lettere maiuscole in minuscole
#con sort si ordinano le stringhe in ordine alfabetico
#con uniq si rimuovono le stringhe duplicate

# viene restituendo un elenco ordinato, senza duplicati e in minuscolo.