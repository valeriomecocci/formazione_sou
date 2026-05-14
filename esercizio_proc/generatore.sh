#!/usr/bin/env bash

is_numeric_valid() {
    local value="$1"
    if [ -z "$value" ] || ! [[ "$value" =~ ^[1-9][0-9]*$ ]]; then
    #le parentesi quadre indicano che si sta valutando una espressione condizionale
    #"$value" =~ ^[1-9][0-9]*$ verifica che sia un numero intero positivo 

        #input non valido
        return 1
        #return 1 indica che la funzione ha fallito, restituendo un codice di uscita diverso da zero,
        #che può essere utilizzato per gestire l'errore nel flusso del programma
    fi
    return 0
}


input_processes() {
    local attempts=3
    local user_input

    while [ $attempts -gt 0 ]
    #per limitare il numero di tentativi si usa contatore e si decrementa ad ogni input non valido
    #in questo modo si evita un ciclo infinito in caso di input errati ripetuti
    do
        read -p "Quanti processi figli di $$ vuoi generare? " num_processes

    
        if is_numeric_valid "$num_processes"; then
            #is_numeric_valid "$num_processes" è una condizione vera quando viene restituito 0 e più in genenale in bash
            #un comando ha successo quando restituisce 0, mentre un comando ha fallito quando restituisce un codice di
            # uscita diverso da 0
            
            return 0
            #esco con successo e $? sarà 0, indicando che l'input è valido
        fi

        #input non valido, continua a chiedere:
        attempts=$((attempts - 1))
        echo "Riprova! Tentativi rimasti: $attempts"
    done

    #se si esce dal ciclo senza un input valido, significa che l'utente ha esaurito i tentativi    
    return 1 
}


process_generation() {
    for (( i=1; i<=num_processes; i++ ))
    #le tonde più interne indicano che si sta valutando una espressione ariitmetica
    do
        sleep 10 &
        #con sleep 10 si avvia un processo che rimane attivo per 10 secondi, con & si esegue in background,
        #permettendo al ciclo di continuare a creare altri processi senza aspettare che il precedente termini

        pid=$!
        #$! contiene il PID dell'ultimo processo avviato in background, in questo caso il processo sleep appena creato

        echo "Creato processo figlio $i con PID $pid" 
    done
    return 0
}


#questa funzione viene utilizzata per verificare lo stato di uscita dell'ultima operazione eseguita,
#e deve essere richiamata dopo ogni funzione da controllare perché $? restituisce lo stato dell'ultima operazione eseguita
check_exit_status() {
    if [ $? -ne 0 ]; then
        echo "$1"
        #$1 rappresenta il primo argomento passato alla funzione,
        #in questo caso un messaggio di errore specifico per la funzione che ha fallito

        exit 1
    fi
}


#MAIN:

input_processes
check_exit_status "Inserimento fallito per esaurimento tentativi."
#con le "" si passa una stringa come argomento alla funzione
# che viene utilizzata per stampare un messaggio di errore specifico se l'input non è valido. Il messaggio viene visualizzato
#quando la funzione input_processes restituisce un codice di uscita diverso da zero, indicando che si è verificato un errore durante l'input dei processi
#quando ad esempio l'utente inserisce un input non valido per 3 volte, la funzione restituisce un codice di uscita di 1, che viene catturato da check_exit_status
#che a sua volta stampa il messaggio di errore e termina lo script con exit 1

process_generation
check_exit_status "Errore durante la generazione dei processi."
echo

#passo i dati al secondo script con una pipe
echo "$num_processes $$" | ./analizza_processi.sh

exit 0
