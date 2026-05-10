# Monitoraggio processi con generatore.sh e analizza_processi.sh

Con i seguenti due script Bash, `generatore.sh` e `analizza_processi.sh`, generano processi figli in backgroud, si visualizza l'albero dei processi e si monitora la loro terminazione.

## Descrizione dei due script

### `generatore.sh`

Questo script:

- richiede all'utente il numero di processi figli da generare;
- valida l'input come intero positivo;
- avvia i processi in background;
- passa il numero di processi e il PID del processo padre a `analizza_processi.sh`.

### `analizza_processi.sh`

Questo script:

- riceve i dati da `generatore.sh` tramite pipe;
- valida i dati in ingresso;
- stampa l'albero dei processi radicato nel processo padre;
- monitora la terminazione dei processi figli.

## Struttura degli script

### Funzioni in `generatore.sh`

- `is_numeric_value()`
  - verifica che l'input sia un numero intero positivo;
  - non accetta stringhe vuote;
  - non accetta numeri che iniziano con `0`.
  - restituisce `0` se l'input è valido, `1` in caso contrario.

- `input_processes()`
  - richiede all'utente il numero di processi da generare;
  - consente un massimo di 3 tentativi;
  - richiama `is_numeric_value()` per la validazione.

- `process_generator()`
  - avvia il numero specificato di processi figli in background;
  - ogni processo esegue `sleep 10` per restare attivo abbastanza a lungo da permettere la creazione degli altri processi.

- `check_exit_status()`
  - controlla lo stato di uscita dell'ultima operazione eseguita usando `$?`;
  - se lo stato non è `0`, stampa un messaggio di errore passato come parametro (`$1`) e termina lo script con `exit 1`.

- `main`
  - esegue le funzioni nell'ordine corretto;
  - controlla gli exit status;
  - invoca `analizza_processi.sh` passando il numero di processi e il PID del processo padre.

### Funzioni in `analizza_processi.sh`

- `check_received_data()`
  - verifica che le stringhe ricevute non siano vuote;
  - restituisce `0` se i dati sono validi, `1` in caso contrario.

- `print_process_tree()`
  - stampa l'albero dei processi radicato nel processo padre;
  - utilizza `pgrep -P "$pid_parent" -f sleep` per recuperare solo i processi figli che eseguono `sleep`.
  - in questo modo si evita di includere lo stesso script `analizza_processi.sh` nella lista.

- `check_active_processes()`
  - controlla ripetutamente se i processi `sleep` sono ancora attivi;
  - attende `1` secondo tra un controllo e l'altro per non sovraccaricare la CPU.

- `check_exit_status()`
  - esegue il controllo dello stato di uscita come in `generatore.sh`.

- `main`
  - riceve i dati dalla pipe;
  - valida i parametri;
  - stampa le informazioni iniziali;
  - mostra l'albero dei processi;
  - attende la terminazione dei processi figli e stampa un messaggio di fine.

