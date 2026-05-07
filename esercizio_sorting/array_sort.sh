#!/usr/bin/env bash

#script che ordina un array, rimuovendo i duplicati e trasformando tutto in lowecase



string_array=(Apple cherry banana Pear orange grape cherry BANANA)

#LOWECASE

#rendiamo tutto lowercase, in questo modo la comparazione per l'ordinamento e la rimozione dei duplicati sarà case-insensitive,
# trattando "Apple" e "apple" come lo stesso elemento.

to_lowercase() {
    local input=("$@")
    #input=("$@") crea una copia dell'array passato come argomento, in modo da lavorare su una versione 
    #locale senza modificare l'originale

    local result=()
    #result=() è un array vuoto che verrà popolato con le versioni lowercase degli elementi dell'array di input

    for item in "${input[@]}"; do

        lower_item="${item,,}"
        #questa istruzione utilizza la sintassi ${var,,} per convertire la stringa contenuta in $item in minuscolo,
        #e assegna il risultato alla variabile lower_item   

        result+=("$lower_item")
        #result+=("$lower_item") aggiunge la stringa lowercase all'array result, mantenendo la struttura dell'array
        #il += è un operatore di append che aggiunge l'elemento alla fine dell'array, e le "" intorno a $lower_item 
        #assicurano che venga trattato come un singolo elemento anche se contiene spazi
        
    done

    echo "${result[@]}"

}




#BUBBLE SORT


sort_array() {
    local arr=("$@")
    #arr=("$@") crea una copia dell'array passato come argomento, in modo da lavorare su una versione 
    #locale senza modificare l'originale

    local flag=1
    #flag per tenere traccia degli scambi, se alla fine di un ciclo non ci sono stati scambi (flag=0) 
    #significa che l'array è ordinato e si può uscire dal ciclo

    local stop=$((${#arr[@]} - 1))
    #stop è inizializzato a ${#arr[@]} - 1, che rappresenta l'indice dell'ultimo elemento dell'array,
    #poiché l'array è indicizzato da 0, l'ultimo elemento si trova a ${#arr[@]} - 1

    while [[ $flag -eq 1 ]]; do
        flag=0

        for ((i = 0; i < stop; i++)); do
            if [[ "${arr[i]}" > "${arr[i+1]}" ]]; then
               #qui scambio gli elementi se arr[i] è maggiore di arr[i+1], sintassi [[ ... ]]  confrontare le stringhe

                temp="${arr[i]}"
                arr[i]="${arr[i+1]}"
                arr[i+1]="$temp"
                flag=1
                #se viene effettuato uno scambio, flag viene impostato a 1, indicando che l'array potrebbe non essere ancora ordinato
            fi
        done

        ((stop--))
        #dopo ogni passaggio completo, stop viene decrementato di 1, poiché l'ultimo elemento è ordinato per costruzione 
        #e non deve essere più confrontato
    done

    echo "${arr[@]}"
    #
}


# RIMOZIONE DUPLICATI

#l'idea della funzione remove_duplicates() è quella di iterare attraverso l'array ordinato e confrontare ogni elemento 
#con il precedente, se l'elemento corrente è diverso dal precedente, viene aggiunto a un nuovo array result, 
#altrimenti viene saltato, in questo modo si ottiene un array senza duplicati

remove_duplicates() {
    local arr=("$@")
    local result=()
    local prev=""
    #con prev="" inizializzo una variabile vuota che terrà traccia dell'ultimo elemento aggiunto a result,
    #in modo da confrontarlo con il prossimo elemento dell'array arr e decidere se aggiungerlo a result o saltarlo se è un duplicato

    for item in "${arr[@]}"; do
        if [[ "$item" != "$prev" ]]; then
            result+=("$item")
            #se l'elemento corrente $item è diverso da $prev, significa che non è un duplicato dell'ultimo elemento aggiunto a result,
            #quindi viene aggiunto a result e prev viene aggiornato a $item per il prossimo confronto

            #con la scrittura result+=("$item") si aggiunge l'elemento $item all'array result,
            #mantenendo la struttura dell'array e assicurando che ogni elemento venga trattato come un singolo 
            #elemento anche se contiene spazi
        fi
        prev="$item"
        #prev="$item" aggiorna la variabile prev con il valore dell'elemento corrente $item, 
        #in modo che al prossimo ciclo possa essere confrontato con il prossimo elemento dell'array arr
    done

    echo "${result[@]}"
}



# 1) lowercase
lowered=($(to_lowercase "${string_array[@]}"))

echo "Array dopo lowercase:\n"
printf "%s\n" "${lowered[@]}"
#printf "%s\n" "${lowered[@]}" stampa ogni elemento dell'array lowered su una nuova riga,
#utilizzando la sintassi "${lowered[@]}" per espandere l'array in modo che ogni elemento venga trattato 
#come un argomento separato, e "%s\n" specifica che ogni elemento deve essere stampato come stringa seguito da una nuova riga.

# 2) sort
sorted=($(sort_array "${lowered[@]}"))

echo -e "\n Array dopo sort:\n"
printf "%s\n" "${sorted[@]}"

# 3) rimozione duplicati
unique=($(remove_duplicates "${sorted[@]}"))

echo -e "\nRisultato finale (ordinato + senza duplicati + lowercase):\n"
printf "%s\n" "${unique[@]}"



