# Exit / Exit Status

In questo script, dove aver stampato `hello`, si stampa anche `0`. La variabile `$?` è una speciale variabile che può essere solo referenziata e si riferisce all'esito dell'ultimo comando eseguito. Dato che `echo hello` è riconosciuto dalla shell, `$?` assume il valore `0`, ossia "successo".

il comando `lskdf` non viene riconosciuto dalla shell e quindi restituisce un valore diverso da `0`.

Lo script termina con un codice di uscita pari a `113` che può essere visualizzato nella shell con `echo $?`.

