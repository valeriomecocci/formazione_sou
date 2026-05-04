#!/usr/bin/env bash

#controlla che i dati ricevuti siano validi, cioè che non siano vuoti:
check_received_data() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        #controllo fallito, uno dei due dati è vuoto
        return 1
    fi
    return 0
}


# funzione per stampare albero dei processi
print_process_tree() {
    local pid_parent="$1"


    local children=$(pgrep -P "$pid_parent" -f sleep)
    #le tonde dopo $ indicano che si sta scrivenod un comando
    #pgrep cerca i preocessi e con -P "$pid_padre" filtra quelli con padre pid_padre, con -f cerca quelli che contengono
    #"sleep" nella riga di comando, in modo da evitare il processo analizza_processi.sh stesso che non terminerebbe mai

    #children è una sequanza di caratteri che contiene i valori separati da ritorni a capo \n

    #se pgrep non trova processi figli, restituisce un codice di uscita diverso da zero
    if [ $? -ne 0 ]; then
        return 1
    fi


    echo "ALBERO PROCESSI:"
    echo "generatore.sh ($pid_parent)"

    for f in $children 
    #qui si esegue il world slitting di $children, che divide la stringa ai ritorni a capo, creando un array di PID dei processi figli
    do
        echo " |--> sleep ($f)"
    done
    return 0
}


#controlla in continuazione se i processi figli sono ancora attivi e, se non ce ne sono più, esce dal ciclo:

check_active_processes() {
    local pid_parent="$1"
    while true
    do
        children=$(pgrep -P "$pid_parent" -f sleep)

        if [ -z "$children" ]; then
            break
            #se la variabile children è vuota, significa che non ci sono più processi sleep attivi e quindi si esce dal ciclo
        fi

        sleep 1
        #aspetta 1 secondo prima di controllare di nuovo, in modo da non sovraccaricare la CPU con controlli continui
    done
    return 0
}


check_exit_status() {
    local status=$?
    #ottiene lo stato di uscita dell'ultima operazione eseguita, memorizzato nella variabile speciale $?
    if [ $status -ne 0 ]; then
        echo "$1"
        exit 1
    fi
}


#MAIN:

#leggo i dati dalla pipe
read children_number pid_parent 

#passo i dati alla funzione di validazione
check_received_data "$children_number" "$pid_parent"
check_exit_status "Errore: dati ricevuti non validi."

echo "MONITORAGGIO ESEGUITO DAL PROCESSO $$ :"
echo "Processo padre: $pid_parent"
echo "Figli attesi: $children_number"

echo

print_process_tree "$pid_parent"
check_exit_status "Errore durante la stampa dell'albero dei processi."
echo
echo "Monitoraggio terminazione..."

check_active_processes "$pid_parent"
check_exit_status "Errore durante il monitoraggio dei processi attivi."

echo
echo -e "\nTutti i processi sleep sono terminati"
exit 0
