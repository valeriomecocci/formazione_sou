# Am I root?

## Metodo 1
Lo script salva 0 in `ROOT_UID` e poi esegue un confronto tra stringhe (usando `[]`) tra il contenuto della variabile d'ambiente `UID`, in cui si trova l'ID dell'utente, con il contenuto di `ROOT_UID`. Se queste sono uguali, stampa `You are root.`, altrimenti stampa `You are just an ordinary user (but mom loves you just the same).`

`exit 0` è l'_exit code_ che indica che lo script è terminato con successo.

## Metodo 2

Si salva il nome dell'utente root, che è `root`, nella variabile  `ROOTUSER_NAME` e il nome utente in `username`.

con 
```bash
username=`id -nu` 
```

si va ad eseguire il comando `id -nu`, grazie alla presenza dei backtick, mostrando le informazione sull'utente (`id`) e, in particolare, solo il nome dell'utente corrente (`-n -u`). L'output viene poi assegnato alla variabile `username`


Alla riga `23`, si confronta il contenuto di `username` con quello di `ROOTUSER_NAME`. Se sono uguali si stampa `Rooty, toot, toot. You are root.`, altrimenti si stampa `You are just a regular fella.`. 