#!/bin/bash

while true
do

    #avvia container su nodo1:

    vagrant ssh nodo1 -c \
    "sudo docker run -d \
    --name echo-server \
    -p 3000:80 \
    -e NODE_NAME=nodo1 \
    ealen/echo-server"
    #docker run -d avvia il container in background
    #--name è il nome del container
    #-p 3000:80 significa porta vm 3000 --> porta container 80
    #-e NODE_NAME=nodo1 passa la variabile ambientale nodo1 per capire su quale nodo gira il container


    echo "Container attivo su nodo1"

    sleep 60


    #ferma container su nodo1:

    vagrant ssh nodo1 -c \
    "sudo docker stop echo-server && sudo docker rm echo-server "



    #avvia container su nodo2:

    vagrant ssh nodo2 -c \
    "sudo docker run -d \
    --name echo-server \
    -p 3000:80 \
    -e NODE_NAME=nodo2 \
    ealen/echo-server"

    echo "Container attivo su nodo2"

    sleep 60

    #ferma container su nodo2:

    vagrant ssh nodo2 -c \
    "sudo docker stop echo-server && sudo docker rm echo-server "
    #entra nella vm del nodo1 ed esegui il comando tra stop e rm


done