# Progress Bar

## Descrizione breve

Lo script crea una barra di carimento di punti in background mentre esegue un processo.

##
Dlla riga `11` fino alla `18` , con `{}`, si utilizza un raggruppamento di comandi che verranno mandati n background con `&`.

Il comando `trap` a riga `12` si utilizza con la sintassi 

```bash
trap <comandi> <segnali>
```

in cui `<comandi>` indica la serie di comandi o funzione da eseguire e `<segnali>` indica i segnali da catturare (espressi tramite nome, che può essere preceduto da SIG, o da un codice numerico). 
    Ad esempio quando il segnale è `0` o `EXIT`, i comandi vengono eseguiti quando la shell esce. 

Nel caso della riga `12`, il segnale `SIGUSR1` non è predefinito, mentre `exit` termina lo script in esecuzione.

Il comando `sleep` sospende l'esecuzione dello script un numero di secondi pari a `interval`, quindi 2 secondi in totale.

Il ciclo da riga `14` a riga `18` è un ciclo infinito che stampa dei punti di seguito aspettando un secondo tra l'uno e l'altro.
    Una volta terminato il blocco di codice, l'operatore `&` indica che tale gruppo di comandi deve esser eseguito in backgroud.

Si salva in `pid` l'id dell'ultimo processo eseguito, cioè il processo della barra di caricamento.
##

 Alla riga `21` si ha

 ```bash
 trap "echo !; kill -USR1 $pid; wait $pid"  EXIT
 ```
  Con questa riga, se il processo termina (o viene terminato dall'utente), si eseguono i comandi tra i doppi apici: 
  si stampa `!`, si invia il signale di chiusura al processo barra di avanzamento (`kill -USR1 $pid`) e si attende finché non questo non si chiuda (`wait $pid`)

##

Da riga `23` a riga `25` si avvia un processo "lungo": si stampa prima `Long-running process `e  poi si aspettano `10` secondi.
Durante questo tempo, il processo in backgroud avviato sopra, continua a stampare i punti.
    Una volta trascorsi `10` secondi, si stampa ` Finished!`

##

Terminato il processo "lungo", si invia il segnale `SIGUSR1` al processo della barra di avanzamento, attivando il comando `exit` della `trap` alla riga `12`, in questo modo il processo si chiude.

Lo scrip aspetta la chiusura del processo della barra di caricamento e con `trap EXIT` si rimuove la `trap` impostata alla riga `21` perché non c'è più bisogno di eseguire comandi in caso di uscita dallo script.

Con `exit $?` si esce dallo script restituendo lo stato dell'ultimo comando eseguito. 
Se non ci sono stati errori, sarà `0`.


