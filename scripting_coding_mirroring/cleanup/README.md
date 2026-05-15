# Cleanup

In questo script, si apre prima la cartella dei log `/var/log` e si sovrascrive il contenuto del fie `message `
con quello di `/dev/null` che è il file _bit buket_, ossia quello che non conserva alcun dato. 

Allo stesso modo, viene svuotato il contenuto di `wtmp`.

Infine, riga `7`, si stampa `Log files cleaned up.`
