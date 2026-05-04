Il primo script, generatore.sh, genera un numero di processi figli deciso dall’utente, valida l’input, genera i processi in background (sleep) e poi passa il numero di processi e l’identificativo del processo padre allo script analizza_processi.sh

Il secondo script riceve i dati dal primo tramite pipe, mostra l’albero dei processi radicato nel processo padre e monitora la loro terminazione.

generatore.sh

 is_numeric_value() controlla che l’input sia un numero intero positivo (non è ammesso un input vuoto e la scrittura di un numero che inizia per 0) e restituisce 0, se l'input è valido e 1, se l’input non è valido

input_processes() richiede il numero di processi da generare al  massimo con 3 tentativi. Richiama la funzione is_numeric_value()

process_generator() avvia un numero di processi in backgroud che rimangono attivi per 10 secondi in modo da permettere al ciclo di creare altri processi senza aspettare che i precedenti termini.

check_exit_status() controlla se l’ultima funzione ha avuto successo valutando lo stato di uscita dell’ultima operazione eseguita con $? e, se questo non è 0, si stampa un messaggio di errore che viene passato alla funzione e richiamato con $1 e si interrompe lo script con exit 1

main: vengono richiamate le funzioni, si esegue il controllo degli ’exit status e si passa il numero di processi e il PID del processo padre al secondo scipt


analizza_processi.sh

check_received_data() controlla che le stringhe ricevute non siano vuote e restituisce 0 o 1 in caso di successo o insuccesso, rispettivamente.

print_process_tree() stampa l’albero dei processi e con pgrep -P "$pid_parent" -f sleep si cercano solo i figli del padre e si filtra per processi sleep in modo da evitare di stampare anche il processo che corrisponde allo scipt stesso.

check_active_processes() controlla continuamente se i processi sleep sono ancora attivi, aspettando un secondo tra un controllo e l’altro per non sovraccaricare la CPU.

 check_exit_status() esegue controlli sull’exit status come nello script precedente

main: Riceve i dati, richiama la funzione di validazione, stampa le informazione, mostra l’albero dei processi e stampa un messaggio quando i processi sono temrinati. 

