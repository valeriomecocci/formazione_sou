# Progetto Vagrant – Configurazione automatica di una VM Linux

## Descrizione

Questo progetto utilizza Vagrant e VirtualBox per creare automaticamente una macchina virtuale Linux Ubuntu 
configurata tramite uno shell script.

L’obiettivo dell’esercizio è realizzare un ambiente completamente portabile:
chiunque scarichi il progetto ed esegua il comando `vagrant up` otterrà automaticamente:

- una macchina virtuale Ubuntu
- Apache installato
- un server web funzionante
- una pagina HTML personalizzata accessibile dal browser


## Tecnologie utilizzate

- Vagrant
- VirtualBox
- Ubuntu 24.04
- Bash scripting
- Apache Web Server


## Struttura del progetto

```text
progetto-vagrant/
├── Vagrantfile
├── setup.sh
└── README.md
```

---

## Cos’è Vagrant

Vagrant è uno strumento che permette di creare e configurare macchine virtuali tramite configurazioni scritte in un file chiamato `Vagrantfile`.

Vagrant automatizza:

- creazione VM
- networking
- provisioning
- configurazione ambienti

Nel progetto Vagrant utilizza VirtualBox come provider di virtualizzazione.

---

## Inizializzazione del progetto

Per creare il progetto è stato eseguito:

```bash
vagrant init bento/ubuntu-24.04
```

Questo comando:

- crea il file `Vagrantfile`
- imposta Ubuntu 24.04 come sistema operativo della VM

La box:

```text
bento/ubuntu-24.04
```

è un’immagine Linux preconfigurata utilizzata da Vagrant per creare la macchina virtuale.

---

## Il file Vagrantfile

Il `Vagrantfile` descrive come deve essere creata e configurata la macchina virtuale. Nel nostro caso sarà:



```ruby
Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-24.04"

  config.vm.network "forwarded_port",
    guest: 80,
    host: 8080

  config.vm.provision "shell",
    path: "setup.sh"

end
```



1. **Apertura configurazione**

```ruby
Vagrant.configure("2") do |config|
```

Avvia la configurazione della macchina virtuale utilizzando la versione 2 della sintassi Vagrant.
La variabile `config` contiene tutte le impostazioni della VM.

---

2. **Box Linux utilizzata**

```ruby
config.vm.box = "bento/ubuntu-24.04"
```

Specifica quale immagine Linux utilizzare per creare la VM.
In questo caso, la distribuzione Ubuntu nella versione 24.04

---

3. **Port forwarding**

```ruby
config.vm.network "forwarded_port",
  guest: 80,
  host: 8080
```

Questa configurazione abilita il _port forwarding_.

La macchina virtuale è isolata dal sistema host.Il port forwarding permette di inoltrare il traffico da una porta del computer host verso una porta della VM.

Nel progetto:

`Mac host porta 8080 --> VM Ubuntu porta 80 --> Apache Web Server`

Quindi visitando `http://localhost:8080` sul computer host, il traffico viene inoltrato automaticamente al server Apache in esecuzione dentro la macchina virtuale. 

---

4. **Provisioning automatico**

```ruby
config.vm.provision "shell",
  path: "setup.sh"
```

Questa riga definisce un _provisioner_, cioè un sistema automatico che configura la macchina virtuale dopo la sua creazione.
Nel progetto viene utilizzato il provisioner `shell` che esegue automaticamente lo script Bash `setup.sh`

---

5. **Chiusura configurazione**

```ruby
end
```

Chiude il blocco di configurazione del `Vagrantfile`.

---

## Il file setup.sh

Il file `setup.sh` contiene tutti i comandi che configurano automaticamente la macchina virtuale.

```bash
#!/bin/bash

# Aggiorna pacchetti
apt-get update

# Installa Apache
apt-get install -y apache2

# Avvia Apache automaticamente
systemctl enable apache2

# Avvia subito Apache
systemctl start apache2

# Crea pagina HTML personalizzata
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Progetto Vagrant</title>
</head>
<body>
    <h1>Macchina configurata automaticamente con Vagrant</h1>
    <p>Provisioning eseguito tramite shell script.</p>
</body>
</html>
EOF
```

---



Creazione della pagina HTML:

```bash
cat > /var/www/html/index.html <<EOF
```

Questo comando sovrascrive il file `/var/www/html/index.html` con il contenuto HTML scritto successivamente.

`EOF` viene utilizzato per delimitare un blocco di testo. Tutto ciò che viene scritto tra `<<EOF` e `EOF`
viene salvato nel file specificato.

---



## Avvio del progetto

Per creare e configurare automaticamente la VM è stato eseguito:

```bash
vagrant up
```

Questo comando:

1. scarica la box Ubuntu
2. crea la macchina virtuale
3. avvia la VM
4. esegue automaticamente `setup.sh`
5. installa Apache
6. crea la pagina HTML

---

## Verifica del progetto

Dopo l’avvio è possibile visitare `http://localhost:8080` per verificare il corretto funzionamento del server web.

---

### Nota

---

* Se si modifica `setup.sh`, il provisioning può essere rieseguito tramite `vagrant provision`

*  Vagrant è utilizzato per creare ambienti Linux completamente automatizzati e portabili:

    Con `vagrant destroy` si elimina completamente la macchina virtuale e poi l’intero ambiente può 
    essere ricreato automaticamente tramite `vagrant up` senza configurazioni manuali aggiuntive.
