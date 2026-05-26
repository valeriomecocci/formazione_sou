#!/bin/bash

#aggiorna pacchetti:
apt-get update


#installa apache:
apt-get install -y apache2


#avvia apache:
systemctl enable apache2
systemctl start apache2


#crea pagina HTML personalizzata:

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
