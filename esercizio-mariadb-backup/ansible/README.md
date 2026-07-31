# Esercizio: Backup e Ripristino di MariaDB con Ansible

## Obiettivo

L'obiettivo dell'esercizio è automatizzare, tramite **Ansible**, il provisioning di due macchine virtuali Rocky Linux:

- **db-source**: contiene il database originale.
- **db-destination**: riceve il backup e ripristina il database.

Al termine dell'esecuzione del playbook il database presente sulla macchina sorgente viene:

1. creato automaticamente;
2. popolato con dati di test;
3. esportato tramite `mysqldump`;
4. copiato sul nodo controller Ansible;
5. trasferito sulla macchina di destinazione;
6. ripristinato;
7. verificato eseguendo una query SQL.

---

## Architettura

```
                Control Node (Mac)

                        |
                  Connessione SSH
                        |
        -------------------------------------
        |                                   |
        |                                   |
  db-source                          db-destination
192.168.56.10                         192.168.56.11
```

Il Control Node è la macchina dal quale viene eseguito il comando:

```bash
ansible-playbook playbook.yml
```

I Managed Node sono invece le macchine che Ansible gestisce.

In questo esercizio:

- il Control Node è il Mac;
- i Managed Node sono le due VM Rocky Linux create con Vagrant.

---

## Comunicazione tramite SSH

Ansible comunica esclusivamente tramite SSH.

Per evitare l'inserimento continuo della password è stata configurata l'autenticazione mediante chiavi pubbliche.

Il bootstrap delle VM crea automaticamente:

- l'utente `ansible`;
- l'accesso SSH tramite chiave pubblica;
- i permessi corretti della directory `.ssh`;
- i privilegi sudo senza password.

In questo modo il controller può collegarsi automaticamente ai managed node ed eseguire tutte le operazioni richieste dal playbook.

---

## Inventory (hosts.ini)

```ini
[db_source]
192.168.56.10

[db_destination]
192.168.56.11

[all:vars]
ansible_user=ansible
```

L'inventory rappresenta l'elenco degli host che Ansible dovrà gestire.

---

### Gruppo db_source

```ini
[db_source]
192.168.56.10
```

Contiene il server sorgente.

Tutti i play che utilizzano

```yaml
hosts: db_source
```

verranno eseguiti esclusivamente su questa macchina.

---

### Gruppo db_destination

```ini
[db_destination]
192.168.56.11
```

Contiene il server sul quale verrà ripristinato il backup.

Tutti i play che utilizzano

```yaml
hosts: db_destination
```

agiranno solamente su questa VM.

---

### Variabili comuni

```ini
[all:vars]
ansible_user=ansible
```

Questa sezione definisce variabili valide per tutti gli host.

In questo caso viene specificato che Ansible dovrà collegarsi utilizzando l'utente

```text
ansible
```

equivalente ad eseguire ogni volta

```bash
ssh ansible@192.168.56.x
```

---
## Cartella `vars`


### Variabili comuni `vars/all.yml`

```yaml
---
mariadb_package: mariadb-server
python_mysql_package: python3-PyMySQL

db_name: company
db_table: employees

db_socket: /var/lib/mysql/mysql.sock

backup_file: /home/ansible/backup.sql
```

Questo file contiene tutte le variabili riutilizzabili dal playbook.
Separare i valori dal codice è una delle principali best practice di Ansible.

### Pacchetti

```yaml
mariadb_package: mariadb-server
python_mysql_package: python3-PyMySQL
```

Consentono di modificare facilmente il nome dei pacchetti senza intervenire sul playbook.

---

### Database

```yaml
db_name: company
db_table: employees
```

Definiscono:

- nome del database
- nome della tabella


---

### Socket MariaDB

```yaml
db_socket: /var/lib/mysql/mysql.sock
```

MariaDB può essere raggiunto dai moduli Ansible tramite:

- connessione TCP (porta 3306)
- socket Unix

In questo esercizio viene utilizzata il socket locale perché Ansible e MariaDB 
girano sulla stessa macchina; inoltre non richiede username e password per via 
di `become: true` e MariaDB permette all'utente root di autenticarsi direttamente 
tramite il socket.

**NOTA**: Le variabili nel vault servirebbero se si decidesse di collegarsi a MariaDB 
tramite TCP

---

### File di backup

```yaml
backup_file: /home/ansible/backup.sql
```

Definisce il percorso in cui verrà salvato il dump SQL.

---

## Struttura generale del playbook

Il playbook è composto da due Play.


**PLAY 1**

- Configura db-source

- crea database

- crea tabella

- inserisce dati

- esegue backup

- scarica backup

----------------------------------

**PLAY 2**

- Configura db-destination

- installa MariaDB

- copia backup

- ripristina database

- verifica dati


Ogni Play lavora su un gruppo differente di host.

---

## PLAY 1 - Configurazione della macchina sorgente



### Configurazione  della VM db-source

Le operazioni vengono eseguite come root tramite sudo perché è necessario:

- installare pacchetti
- avviare servizi
- creare database


---

### Installazione del driver Python

```yaml
python3-PyMySQL
```

È necessario ai moduli Ansible della collection `community.mysql`.

Senza questo pacchetto Ansible non riuscirebbe a comunicare con MariaDB.


---

### Creazione della tabella

```yaml
community.mysql.mysql_query
```

Permette di eseguire una qualsiasi query SQL; in questo caso viene eseguito

```sql
CREATE TABLE IF NOT EXISTS
```

La clausola

```sql
IF NOT EXISTS
```

rende il playbook idempotente: se la tabella esiste già, il task non produce errori.

---

### Inserimento dei dati

Sempre tramite

```yaml
mysql_query
```

viene eseguita una query SQL.

```sql
INSERT IGNORE
```

è stato scelto invece di

```sql
INSERT
```

per evitare errori nelle esecuzioni successive: se il record esiste già, MariaDB lo ignora.

Questo mantiene il playbook idempotente.

---

### Backup del database

```yaml
ansible.builtin.command
```

esegue

```bash
mysqldump
```
che è l' utility ufficiale di MySQL/MariaDB per creare un backup logico di uno o più database.
Quindi non copia i file fisici del database, ma genera invece uno script SQL che permette 
di ricreare tutto il database.

`--socket={{ db_socket }}`: specifica il collegamento a MariaDB tramite il socket

`--databases {{ db_name }}`: specifica il DB di cui fare `mysqldump`.

L'output del comando viene salvato nella variabile `backup_output` grazie a
`register: `  che permette di memorizzare l'output di un task e riutilizzarlo nei task successivi.

---

### Salvataggio del dump



Il contenuto della variabile `backup_output.stdout` viene scritto nel file `backup.sql`
tramite il modulo `copy`. Infatti, `copy` può sia copiare un file esistente da una sorgente
ad una destinazione, ma anche scrivere del contenuto in un nuovo file.

` content: "{{ backup_output.stdout }}"`: prende il contenuto di `backup_output.stdout`
e crea un file in nel percorso `{{ backup_file }}` (salvato in `all.yml`) con `dest: "{{ backup_file }}"` 


`backup_output` è infatti un dizionario Python che contiene, tra le varie chiavi, la chiave `stdout`
il cui valore è una stringa contenente lo standard output del comando, cioè il dump del database.

Infine imposta proprietario del file, gruppo proprietario del file e permessi del file `0644`, in cui
il primo zero indica che ansible dovrà interpretare il numero in base 8.


---

### Download del backup

Qui usiamo il modulo

```yaml
ansible.builtin.fetch
```

È il l'opposto del modulo `copy` e serve quindi a prelevare un file.

```
copy

Control Node
    │
    ▼
Managed Node
```

```
fetch

Control Node
    ▲
    │
Managed Node
```

`src: "{{ backup_file }}"`: indica dove prelevare il file;

`dest: /tmp/`: indica dove salvare il file sul Control Node (Mac), in questo caso in `/tmp/`

`flat: true`: indica ad ansible di non creare altre cartella dentro  `/tmp/` ma di salvare 
il file direttamente lì.


---

## PLAY 2 - Configurazione della macchina di destinazione

Il secondo Play è molto simile al primo però non crea il database da zero, ma ripristina il backup.



### Copia del backup

```yaml
copy
```

questa volta si `copy` viene utilizzato proprio per eseguire la copia del file 
dalla sorgente alla destinazione.

Il file viene copiato

```
Control Node
    │
    ▼
db-destination
```

---

### Ripristino del database

Con il modulo `shell` si eseguono dei comandi sulla shell del nodo remoto 
(`shell` supporta quindi tutti gli operatori della shell, come `<`, a differenza di `command`).

Con

```yaml
mariadb --socket={{ db_socket }} < backup.sql
```

Si apre il file `backup.sql` si e invia tutto il suo contenuto al client MariaDB.

MariaDB legge il file riga per riga ed esegue ogni istruzione SQL e quindi tutte le istruzioni presenti 
nel file vengono ricreate automaticamente:

- database
- tabelle
- record

---

### Verifica finale

Per verificare il corretto ripristino viene eseguita la query

```sql
SELECT COUNT(*)
FROM employees;
```

Il risultato viene salvato in

```yaml
register: verifica
```

---

### Visualizzazione del risultato

Infine `debug` mostra il contenuto della variabile `verifica.query_result`

L'output ottenuto sarà 

```text
totale: 5
```

Questo conferma che:

- il database è stato ripristinato;
- la tabella è stata ricreata;
- tutti i record sono stati importati correttamente.

---

## Flusso completo del playbook

```
Controller Ansible
        │
        │ SSH
        ▼
db-source
        │
        ├── Installa MariaDB
        ├── Crea database
        ├── Crea tabella
        ├── Inserisce dati
        ├── Esegue mysqldump
        └── fetch backup.sql
                │
                ▼
        Controller
                │
                └── copy backup.sql
                        │
                        ▼
                db-destination
                        │
                        ├── Installa MariaDB
                        ├── Ripristina backup
                        ├── Esegue SELECT COUNT(*)
                        └── Mostra il risultato finale
```
