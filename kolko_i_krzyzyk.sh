#!/bin/bash

WYGRANA="0"
GRACZ="X"
PLANSZA=("." "." "." "." "." "." "." "." ".")
WYKONANE_RUCHY="0"

function print {
    clear
    echo "${PLANSZA[0]} | ${PLANSZA[1]} | ${PLANSZA[2]}"
    echo "${PLANSZA[3]} | ${PLANSZA[4]} | ${PLANSZA[5]}"
    echo "${PLANSZA[6]} | ${PLANSZA[7]} | ${PLANSZA[8]}"
}

function check {
    for POLE in {0..2}
    do
	# rows
	ROW=$POLE*3
	if [[ ${PLANSZA[$ROW]} == $GRACZ ]] && [[ ${PLANSZA[$ROW+1]} == $GRACZ ]] && [[ ${PLANSZA[$ROW+2]} == $GRACZ ]]
	then
		print
		echo "Wygral gracz ${GRACZ}"
		WYGRANA="1"
	fi
	# columns
	if [[ ${PLANSZA[$ROW]} == $GRACZ ]] && [[ ${PLANSZA[$ROW+3]} == $GRACZ ]] && [[ ${PLANSZA[$ROW+6]} == $GRACZ ]]
	then
        print
        echo "Wygral gracz ${GRACZ}"
        WYGRANA="1"
        fi
	done
	# cross
	if [[ ${PLANSZA[0]} == $GRACZ  ]] && [[ ${PLANSZA[4]} == $GRACZ ]] && [[ ${PLANSZA[8]} == $GRACZ ]]
    then
        print
        echo "Wygral gracz ${GRACZ}"
        WYGRANA="1"
    fi
	if [[ ${PLANSZA[2]} == $GRACZ  ]] && [[ ${PLANSZA[4]} == $GRACZ ]] && [[ ${PLANSZA[6]} == $GRACZ ]]
    then
        print
        echo "Wygral gracz ${GRACZ}"
        WYGRANA="1"
    fi
}

function change_player {
	if [ ${GRACZ} = "X" ]
	then 
		GRACZ="O"
	else
		GRACZ="X"
	fi

}

function new_move {
	print
	echo "Tura gracza ${GRACZ}"
	echo "Prosze wybrac numer pola."
	while true
	do
		read -p 'Podaj numer pola lub wpisz "help" aby wyswietlic pomoc:' input
		if [[ $input == "help" ]]
		then
			help
		fi
		if [[ ${PLANSZA[$input]} == "." ]] && [[ $input =~ ^[0-8]$ ]]
		then
			PLANSZA[$input]=$GRACZ
			let "WYKONANE_RUCHY+=1"
			break
		else
			echo "Pole zajete lub podano cos innego niz liczy zakresu 0-8 lub polecenie help"
		fi
	done
	check
}

function help {
	clear
	echo "Aby zajac pole wybierz jego numer i zatwierdz enterem."
	echo "0 | 1 | 2"
	echo "3 | 4 | 5"
	echo "6 | 7 | 8"
	echo "Gre rozpoczyna gracz X"
	read -n 1 -s -r -p "Nacisnij dowolny klawisz aby kontynuowac.. "
	print
}

function play {
	while [ $WYGRANA -eq "0" ]
	do
		new_move
		change_player
		if [ $WYKONANE_RUCHY -eq "9" ] && [ $WYGRANA -eq "0" ]
		then
			print
			echo "Remis!"
			WYGRANA="1"
		fi
	done
}

help

while true
do
	play
	read -p 'Czy chcesz zagrac jeszcze raz? T/N [N]: ' input
	if [[ $input != T ]]
	then
		break
	else
		WYGRANA="0"
	echo "$WYGRANA - wygrana"
	PLANSZA=("." "." "." "." "." "." "." "." ".")
	GRACZ="X"
	WYKONANE_RUCHY="0"	
	fi
done


