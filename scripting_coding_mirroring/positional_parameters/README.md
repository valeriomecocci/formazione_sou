# Positional Parameters


Dopo aver assegnato 10 a `MINPARAM`, si stampa `The name of this script is "/path/scriptname.sh".`, se il percorso del file è il nome dello `/path/scriptname.sh`. Con `$0` ci si riferisce proprio al nome dello script, mentre `/` è un  _carattere di escape_ che, inserito davanti a `"`, indica di non interpretare i doppi apici, ma stamparli così come sono. 

Poi si stampa la stessa stringa, ma questa volta il comando `basename $0` fa in modo di rimuovere tutto il path fino al nome del file.


Nella serie di confronti che seguono, si controlla che l'ennesimo parametro passato allo script sia non vuoto e, in caso affermativo, si stampa `"Parameter #n is $n"`. Se `n`è maggiore di 9, bisogna usare la notazione `${n}` (riga `34`).

Alla riga `42`, se il numero di argomenti passati (`$#`) è minore del minimo `MINPARAMS`, si stampa `This script needs at least 10 command-line arguments!` 