#!/bin/bash


echo "=== Bootstrap utente ansible ==="


#creazione  utente ansible
useradd ansible || true


#aggiungo ansible al gruppo wheel
usermod -aG wheel ansible


echo "=== Configurazione sudo ==="


#commenta sudo con password
sed -i 's/^%wheel.*ALL=(ALL).*ALL/#%wheel ALL=(ALL) ALL/' /etc/sudoers


#abilita sudo senza password
sed -i 's/^# %wheel.*NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers



echo "=== Configurazione SSH ==="


mkdir -p /home/ansible/.ssh


#inserisci la chiave pubblica del controller Ansible
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHnEekajn6Tm5rZG1fDWmu2C9qlTt1r2Lt6RIJwByz2 valeriomecocci@MBP-di-Valerio.localdomain" \
> /home/ansible/.ssh/authorized_keys



#permessi corretti
chown -R ansible:ansible /home/ansible/.ssh

chmod 700 /home/ansible/.ssh

chmod 600 /home/ansible/.ssh/authorized_keys



echo "=== SELinux restore context ==="

restorecon -Rv /home/ansible/.ssh



echo "=== Bootstrap completato ==="
