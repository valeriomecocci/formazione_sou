
#!/bin/bash

#aggiorna pacchetti
apt-get update

#installa docker
apt-get install -y docker.io

#avvia docker
systemctl start docker

#abilita docker all'avvio
systemctl enable docker

