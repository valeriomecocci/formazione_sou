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
		
    #reindirizza il contenuto di metriche.txt all'input standard del ciclo while,
	#facendo sì che read legga una riga alla volta da quel file invece che dalla tastiera.
	done < metriche.txt


}


#stampal'elenco nome_server: media_utilizzo_cpu%

stampa_report() {

	echo "=== REPORT UTILIZZO MEDIO CPU ==="

	for server in "${!cpu_totale[@]}"
	do
        #calcolo della media (divisione prendendo sola la parte intera)
        media=$(( cpu_totale["$server"] / occorrenze["$server"] ))

		#stampa nome_server e media di utilizzo della cpu in percentuale
        echo "$server: ${media}%"

    done

}


#main

leggi_metriche
stampa_report

