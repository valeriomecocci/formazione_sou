#!/bin/bash

# ORCHESTRATORE DEL SISTEMA DISTRIBUITO

# Bash agisce come:
    #coordinatore
    #supervisore
    #aggregatore
    #validatore
    #scheduler
#

#INIZIALIZZA LA GRIGLIA DELLA PARTITA

initialize_board() {

    for i in {1..9}
    do
        sudo docker exec cell_$i sh -c "echo -n '' > /game/state.txt"
        #con docker exec si esegue un dentro il container i-esimo già avviato 
        #e con sh -c si permette di eseguire una stringa di comandi shell che, 
        #in questo caso, svuota il file
    done

}

#INIZIALIZZAZIONE PARTITA, NUMERO MOSSE E TURNO

partita_attiva=true
mosse=0
turno="X"



#LETTURA STATI DISTRIBUITI

read_board() {
    
    #leggo il contenuto dei file nel container i-esimo
    #e lo slavo nella variabile ci, i=1,...,9
    c1=$(sudo docker exec cell_1 cat /game/state.txt)
    c2=$(sudo docker exec cell_2 cat /game/state.txt)
    c3=$(sudo docker exec cell_3 cat /game/state.txt)

    c4=$(sudo docker exec cell_4 cat /game/state.txt)
    c5=$(sudo docker exec cell_5 cat /game/state.txt)
    c6=$(sudo docker exec cell_6 cat /game/state.txt)

    c7=$(sudo docker exec cell_7 cat /game/state.txt)
    c8=$(sudo docker exec cell_8 cat /game/state.txt)
    c9=$(sudo docker exec cell_9 cat /game/state.txt)

    #se la variabile i-esima è vuota, assegna il carattere -
    [ -z "$c1" ] && c1="-"
    [ -z "$c2" ] && c2="-"
    [ -z "$c3" ] && c3="-"

    [ -z "$c4" ] && c4="-"
    [ -z "$c5" ] && c5="-"
    [ -z "$c6" ] && c6="-"

    [ -z "$c7" ] && c7="-"
    [ -z "$c8" ] && c8="-"
    [ -z "$c9" ] && c9="-"

}


#STAMPA GLIGLIA

print_board() {

    echo
    echo "$c1 | $c2 | $c3"
    echo "---------"
    echo "$c4 | $c5 | $c6"
    echo "---------"
    echo "$c7 | $c8 | $c9"
    echo

}


#VALIDAZIONE CASELLA

is_valid_move() {

    stato=$(sudo docker exec cell_$1 cat /game/state.txt)

    if [ -z "$stato" ]
    then
        return 0
    else
        return 1
    fi

}


#VALIDAZIONE INPUT

validate_input() {

    if ! [[ "$1" =~ ^[1-9]$ ]]
    then
        echo "Casella non valida"
        return 1
    fi

    is_valid_move "$1"

    if [ $? -ne 0 ]
    then
        echo "Casella occupata"
        return 1
    fi

    return 0

}


#OTTIENI E ANALIZZA LA MOSSA DEL GIOCATORE

get_player_move() {

    while true
    do

        echo "Turno del giocatore: $turno"
        read -p "Scegli una casella (1-9): " casella

        validate_input "$casella"

        if [ $? -eq 0 ]
        then
            return
        fi

    done

}


#SCRITTURA MOSSA

write_move() {

    sudo docker exec cell_$1 sh -c "echo $2 > /game/state.txt"

}


#VERIFICA COMBINAZIONI VINCENTI
    #se trovo tre caselle non vuote (secondo le regole) che hanno tutte lo stesso simbolo,
    #allora il vincitore è colui che ha inserito quel simbolo, altrimenti ancora non l'ho trovato 
#
check_winner() {

    #riga 1
    if [ "$c1" != "-" ] && [ "$c1" = "$c2" ] && [ "$c2" = "$c3" ]
    then
        winner="$c1"
        return
    fi

    #riga 2
    if [ "$c4" != "-" ] && [ "$c4" = "$c5" ] && [ "$c5" = "$c6" ]
    then
        winner="$c4"
        return
    fi

    #riga 3
    if [ "$c7" != "-" ] && [ "$c7" = "$c8" ] && [ "$c8" = "$c9" ]
    then
        winner="$c7"
        return
    fi

    #colonna 1
    if [ "$c1" != "-" ] && [ "$c1" = "$c4" ] && [ "$c4" = "$c7" ]
    then
        winner="$c1"
        return
    fi

    #colonna 2
    if [ "$c2" != "-" ] && [ "$c2" = "$c5" ] && [ "$c5" = "$c8" ]
    then
        winner="$c2"
        return
    fi

    #colonna 3
    if [ "$c3" != "-" ] && [ "$c3" = "$c6" ] && [ "$c6" = "$c9" ]
    then
        winner="$c3"
        return
    fi

    #diagonale principale
    if [ "$c1" != "-" ] && [ "$c1" = "$c5" ] && [ "$c5" = "$c9" ]
    then
        winner="$c1"
        return
    fi

    #diagonale secondaria
    if [ "$c3" != "-" ] && [ "$c3" = "$c5" ] && [ "$c5" = "$c7" ]
    then
        winner="$c3"
        return
    fi

    #non c'è ancora un vincitore
    winner=""

}


#ALTERNA TURNO

switch_turn() {

    if [ "$turno" = "X" ]
    then
        turno="O"
    else
        turno="X"
    fi

}

#TERMINA IL GIOCO

end_game() {

    echo "$1"
    print_board
    partita_attiva=false
}



# MAIN con CICLO PRINCIPALE DELLA PARTITA

initialize_board

while [ "$partita_attiva" = true ]
do
    read_board
    print_board
    get_player_move

    #scrittura della mossa:
    write_move "$casella" "$turno"
    mosse=$((mosse + 1))

    #ricostruzione della gliglia:
    read_board

    #verifica del vincitore:
    check_winner

    if [ "$winner" = "X" ]
    then
        #X vince e la partita si disattiva:
        end_game "X vince"

    elif [ "$winner" = "O" ]
    then
        #O vince e la partita si disattiva:
        end_game "O vince"

    elif [ "$mosse" -eq 9 ]
    then
        #pareggio, la partita si disattiva:
        end_game "Pareggio"

    else
        switch_turn
    fi
done


#TERMINAZIONE

echo
echo "Partita terminata"
echo
