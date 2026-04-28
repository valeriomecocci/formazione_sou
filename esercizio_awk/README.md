Utilizzo di AWK.

Con AWK è possibile manipolare dati di tipo testuale in forma di file o come flusso dati proveniente dallo standard input. 
Se allo script AWK si passano uno o più file, questi verranno letti riga per riga.

In un file .csv, si utilizza un testo per rappresentare una tabella: una linea di testo è una riga della tabella divisa in campi separati da un apposito carattere separatore (la virgola, nel nostro caso).

Dopo aver creato il file file_esempio.csv con Vim, si esegue il comando:

awk -F "," '/banana/ { print $3 }' < file_esempio.csv
-F indica il separatore di campi;
"," sto indicando che utilizzo la virgola come separatore;
/banana/ pattern inserito tra / /: va eseguita l'azione sulle righe del file che contengono la stringa banana;
 { print $3 } azione da eseguire tra { }: indica che bisogna stampare il terzo campo della riga.

Utilizzo di grep + sed.

Se si vuole stampare il terzo campo di una riga, si possono distinguere 2 casi. 

1. Caso in cui il file .csv contiene almeno una riga con esattamente 3 campi:

grep "banana" file_esempio.csv | sed 's/.*,//'

Con grep "banana" si considerano le righe del file che contengono solo la stringa banana. 
Attraverso la pipe | l'output del comando di sinistra viene passato come input del comando a destra  
Con  sed 's/.*,//' si intende quanto segue:
sed utilizza un editor di flusso che modifica ogni riga dell'input per apportare modifiche;
s sostituisce il pattern contenuto tra il primo e il secondo / con ciò che viene indicato tra il secondo e il terzo / ;
.*, espressione regolare che indica qualsiasi carattere (.) ripetuto zero o più volte (*) con virgola alla fine (,) quindi sto considerando qualsiasi carattere della riga fino all'ultima virgola;
// è la sostituzione vuota.
In conclusione, stiamo eliminando tutta la riga fino all'ultima virgola compresa e lasciamo inalterato quello che c'è dopo, ossia proprio il terzo campo.


2.   Caso in cui il file .csv contiene almeno una riga con almeno tre campi.

In questo caso il comando visto nel caso 1. stamperà l'ultimo campo della riga che potrebbe non essere il terzo. Si può dare il comando
 
grep "banana" file_esempio.csv | sed 's/^[^,]*,[^,]*,\([^,]*\).*/\1/'
^ con il primo caret indico di partire dall'inizio della riga;
[^,] indico qualsiasi carattere che non sia una virgola (^ dentro [ ] indica una negazione);
[^,]* indica qualsiasi carattere che non sia una virgola che appare zero o più volte, quindi indica il primo campo;
, fuori da [ ] indica il separatore di colonne;
[^,]* la seconda volta indica, analogamente, il secondo campo;
\([^,]*\) questo, dopo la seconda virgola fuori dalle parentesi quadre, indica che sto salvando ciò che è contenuto in /(  /), in questo caso sto salvando la terza colonna;
.* indica tutto il resto della riga (dal terzo campo in poi, in questo caso);
\1 richiama il primo valore salvato.

