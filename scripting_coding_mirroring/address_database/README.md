# Address database

In questo script, dopo aver dichiarato l'array associativo `address`, si vanno ad assegnare i valori corrispondenti ai campi dell'array chiamati `Charles` `John` `Wilma` (dette _chiavi_).

Con la sintassi `${address[key]}` si accede al contenuto dell'elemento dell'array (detto _valore_) corrispondente alla chiave `key`. Quindi con il primo `echo` alla riga `12`, si stampa `Charles's address is 414 W. 10th Ave., Baltimore, MD 21236.`

Con `${!address[*]}`, riga `21`, si accede al contenuto di `!address[*]` che indica l'insieme di tutte le chiavi dell'array. Se invece si considera `address[*]` (senza `!` davanti), si sta facendo riferimento a tutti i valori dell'array, ossia quelli assegnati da riga `7` a riga `9`.
Quindi si stampa `Charles John Wilma`