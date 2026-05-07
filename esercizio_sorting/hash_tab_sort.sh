#!/usr/bin/env bash

#Lo script esegue le funzioni nel seguente ordine:
# 1) converte tutte le stringhe in lowercase
# 2) usa un array associativo per eliminare duplicati in modo più efficiente
# 3) ordina con Bubble Sort

#Il fatto di ordinare l'array dopo aver prima rimosso i duplicati, permette di evitare di dover confrontare 
#elementi duplicati durante l'ordinamento, permettendo di effettuare l'ordinamento eseguendo meno operazioni. 
#La complessità computazionnale complessiva è comunque O(n^2) a causa del bubble sort

string_array=(Apple cherry banana Pear orange grape cherry BANANA)


to_lowercase() {
    local input=("$@")
    local result=()

    for item in "${input[@]}"; do
        result+=("${item,,}")
    done

    echo "${result[@]}"
}



#RIMOZIONE DUPLICATI TRAMITE ARRAY ASSOCIATIVO

# l'idea della funzione remove_duplicates_assoc() è quella di iterare attraverso l'array di input e 
# utilizzare un array associativo "seen" per tenere traccia degli elementi già incontratii, 
# se un elemento non è presente in "seen", viene aggiunto sia all'array associativo che al risultato finale
#così da ottenere un array senza duplicati senza dover prima ordinare l'array, 


remove_duplicates_assoc() {
    local input=("$@")
    local result=()

    declare -A seen
    #seen["apple"]=1 significa che la chiave "apple" è già stata incontrata

    for item in "${input[@]}"; do
        if [[ -z "${seen[$item]}" ]]; then
        # se seen[$item] è vuoto, significa che l'elemento non è stato ancora incontrato, quindi lo aggiungo al risultato

            seen["$item"]=1
            #aggiungo l'elemento al risultato solo se non è già stato visto, in questo modo si evita di aggiungere duplicati

            result+=("$item")
            #aggiungo l'elemento all'array result, che conterrà solo elementi unici
        fi
    done

    echo "${result[@]}"
}


# BUBBLE SORT

sort_array() {
    local arr=("$@")
    local flag=1
    local stop=$((${#arr[@]} - 1))

    while [[ $flag -eq 1 ]]; do
        flag=0

        for ((i = 0; i < stop; i++)); do
            if [[ "${arr[i]}" > "${arr[i+1]}" ]]; then
                
                temp="${arr[i]}"
                arr[i]="${arr[i+1]}"
                arr[i+1]="$temp"
                flag=1

            fi
        done

        ((stop--))
    done

    echo "${arr[@]}"
}





# 1) lowercase
lowered=($(to_lowercase "${string_array[@]}"))

echo "Array dopo lowercase:"
printf "%s\n" "${lowered[@]}"

# 2) rimozione duplicati con array associativo
unique=($(remove_duplicates_assoc "${lowered[@]}"))

echo -e "\nArray dopo rimozione duplicati:"
printf "%s\n" "${unique[@]}"

# 3) sort finale
sorted=($(sort_array "${unique[@]}"))

echo -e "\nRisultato finale (lowercase + senza duplicati + ordinato):"
printf "%s\n" "${sorted[@]}"