#!/bin/bash
function help {
	clear
	read -n 1 -s -r -p "
	Control buttons:
	W - MOVE UP
	S - MOVE DOWN
	A - MOVE LEFT
	D - MOVE RIGHT
	X - QUIT

	Press any key to continue...
	"
}

BOARD=("." "." "." "." "." "." "." "." "." "." "." "." "." "." "." ".")
WIN=0
CAN_MOVE_TO_SELECTED_DIR=0

function print {
	clear
	echo -e "${BOARD[0]}\t${BOARD[1]}\t${BOARD[2]}\t${BOARD[3]}"
	echo -e "${BOARD[4]}\t${BOARD[5]}\t${BOARD[6]}\t${BOARD[7]}" 
	echo -e "${BOARD[8]}\t${BOARD[9]}\t${BOARD[10]}\t${BOARD[11]}" 
	echo -e "${BOARD[12]}\t${BOARD[13]}\t${BOARD[14]}\t${BOARD[15]}" 
}

function init {
	fill field with 32
	random_location=$((RANDOM % 16))
	BOARD[$random_location]="32"
	#fill 3 fields with 2
	number_2=3
	while [ $number_2 -gt 0 ]
	do
		random_location=$((RANDOM % 16))
		if [ ${BOARD[$random_location]} == "." ] 
		then
			BOARD[$random_location]="2"
			number_2=$((number_2-1))
		fi
	done	
}

function enter_new_number {
	#propability of 4 is 10%
	propability=$((RANDOM % 10))
	can_enter=0
	for (( i=0; i<=15; i++))
	do
		if [ ${BOARD[$i]} == "." ]
		then
			can_enter=1
		fi
	done
	while [ $can_enter -eq 1 ]
	do
		random_location=$((RANDOM % 16))
		if [ ${BOARD[$random_location]} == "." ]
		then
			if [ $propability -eq 0 ]
			then
				BOARD[$random_location]="4"
			else
				BOARD[$random_location]="2"
			fi
			can_enter=0
		fi
	done
}

function check_board {
	can_enter=0
	there_is_move=0
	for (( i=0; i<=15; i++))
	do
		if [ ${BOARD[$i]} == "." ]
		then
			can_enter=1
			break
		fi
		if [ ${BOARD[$i]} == "2048" ]
		then
			WIN=1
			break
		fi
	done

	#check if there is move to left or right
	for (( i=0; i<=14;))
	do
		if [ ${BOARD[$i]} == ${BOARD[$(($i+1))]} ] && [ ${BOARD[$i]} != "." ]
		then
			there_is_move=1
			break
		fi
		if [ $i -eq 12 ] || [ $i -eq 13 ]
		then
			i=$(($i-15))
		fi
		i=$(($i+4))
	done
	#check if there is move to top or bottom
	if [ $there_is_move -eq 0 ]
	then
		for (( i=0; i<=11; i++))
		do
			if [ ${BOARD[$i]} == ${BOARD[$(($i+4))]} ] && [ ${BOARD[$i]} != "." ]
			then
				there_is_move=1 
				break
			fi	
		done
	fi
	#lose condition:
	#there is no fields and no moves
	#echo "can_enter: " $can_enter " win: " $WIN " there_is_move: " $there_is_move
	if [ $can_enter -eq 0 ] && [ $WIN -eq 0 ] && [ $there_is_move -eq 0 ]
	then
		WIN=-1
	fi
}

function move_w {
	merged=("." "." "." "." "." "." "." "." "." "." "." "." "." "." "." ".")
	
	# składanie 2 i 1 wiersza
	for (( i=7; i >= 4; i--)) 
	do
		if [ ${BOARD[$(($i-4))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			#echo "wykonuje przeniesienie"
			#echo ${BOARD[$(($i-4))]} "zastepuje liczba" ${BOARD[$i]}
			BOARD[$(($i-4))]=${BOARD[$i]}
			BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i-4))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i-4))]} != "x" ]
		then
			#echo "wykonuje laczenie"
			#echo "lacze: " ${BOARD[$(($i-4))]} " z " ${BOARD[$i]}
			BOARD[$(($i-4))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i-4))]="x"
		fi
	done

	#skladanie 3, 2 i 1 wiersza
	for (( i=11; i >= 4; i--))
	do
		if [ ${BOARD[$(($i-4))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			 #echo "wykonuje przeniesienie z 2 petli"
			 #echo ${BOARD[$(($i-4))]} "zastepuje liczba" ${BOARD[$i]}
			 BOARD[$(($i-4))]=${BOARD[$i]}
			 BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i-4))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i-4))]} != "x" ]
		then
			#echo "wykonuje laczenie z 2 petli"
			#echo "lacze: " ${BOARD[$(($i-4))]} " z " ${BOARD[$i]}
			BOARD[$(($i-4))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i-4))]="x"
		fi
	done

	#skladanie 4, 3, 2 i 1 wiersza
	for (( i=15; i >= 4; i--))
	do
		if [ ${BOARD[$(($i-4))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			#echo "wykonuje przeniesienie z 3 petli"
			#echo ${BOARD[$(($i-4))]} "zastepuje liczba" ${BOARD[$i]}
			BOARD[$(($i-4))]=${BOARD[$i]}
			BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i-4))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i-4))]} != "x" ]
		then
			#echo "wykonuje laczenie z 3 petli"
			#echo "lacze: " ${BOARD[$(($i-4))]} " z " ${BOARD[$i]}
			BOARD[$(($i-4))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i-4))]="x"
		fi
	done
}

function move_s {
	merged=("." "." "." "." "." "." "." "." "." "." "." "." "." "." "." ".")
	
	# składanie 4 i 3 wiersza
	for (( i=8; i <= 11; i++)) 
	do
		if [ ${BOARD[$(($i+4))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			#echo "wykonuje przeniesienie"
			#echo ${BOARD[$(($i+4))]} "zastepuje liczba" ${BOARD[$i]}
			BOARD[$(($i+4))]=${BOARD[$i]}
			BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i+4))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i+4))]} != "x" ]
		then
			#echo "wykonuje laczenie"
			#echo "lacze: " ${BOARD[$(($i+4))]} " z " ${BOARD[$i]}
			BOARD[$(($i+4))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i+4))]="x"
		fi
	done

	#skladanie 4, 3 i 2 wiersza
	for (( i=4; i <= 11; i++))
	do
		if [ ${BOARD[$(($i+4))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			 #echo "wykonuje przeniesienie z 2 petli"
			 #echo ${BOARD[$(($i+4))]} "zastepuje liczba" ${BOARD[$i]}
			 BOARD[$(($i+4))]=${BOARD[$i]}
			 BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i+4))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i+4))]} != "x" ]
		then
			#echo "wykonuje laczenie z 2 petli"
			#echo "lacze: " ${BOARD[$(($i+4))]} " z " ${BOARD[$i]}
			BOARD[$(($i+4))]=$((${BOARD[$i]}*2))
			MOARD[$i]="."
			merged[$(($i+4))]="x"
		fi
	done

	#skladanie 4, 3, 2 i 1 wiersza
	for (( i=0; i <= 11; i++))
	do
		if [ ${BOARD[$(($i+4))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			#echo "wykonuje przeniesienie z 3 petli"
			#echo ${BOARD[$(($i+4))]} "zastepuje liczba" ${BOARD[$i]}
			BOARD[$(($i+4))]=${BOARD[$i]}
			BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i+4))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i+4))]} != "x" ]
		then
			#echo "wykonuje laczenie z 3 petli"
			#echo "lacze: " ${BOARD[$(($i+4))]} " z " ${BOARD[$i]}
			BOARD[$(($i+4))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i+4))]="x"
		fi
	done
}

function move_a {
	merged=("." "." "." "." "." "." "." "." "." "." "." "." "." "." "." ".")
	
	# składanie 1 i 2 kolumny
	for (( i=13; i >= 1; )) 
	do
		if [ ${BOARD[$(($i-1))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			#echo "wykonuje przeniesienie"
			#echo ${BOARD[$(($i-1))]} "zastepuje liczba" ${BOARD[$i]}
			BOARD[$(($i-1))]=${BOARD[$i]}
			BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i-1))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i-1))]} != "x" ]
		then
			#echo "wykonuje laczenie"
			#echo "lacze: " ${BOARD[$(($i-1))]} " z " ${BOARD[$i]}
			BOARD[$(($i-1))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i-1))]="x"
		fi
		i=$(($i-4))
	done

	# składanie 1 i 2 i 3 kolumny
	for (( i=14; i >= 1; )) 
	do
		if [ ${BOARD[$(($i-1))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			#echo "wykonuje przeniesienie z 2 petli"
			#echo ${BOARD[$(($i-1))]} "zastepuje liczba" ${BOARD[$i]}
			BOARD[$(($i-1))]=${BOARD[$i]}
			BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i-1))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i-1))]} != "x" ]
		then
			#echo "wykonuje laczenie z 2 petli"
			#echo "lacze: " ${BOARD[$(($i-1))]} " z " ${BOARD[$i]}
			BOARD[$(($i-1))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i-1))]="x"
		fi
		if [ $i -eq 2 ]
		then
			i=$(($i+15))
		fi
		i=$(($i-4))
	done
	# składanie 1 i 2 i 3 kolumny
	for (( i=15; i >= 1; )) 
	do
		if [ ${BOARD[$(($i-1))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			#echo "wykonuje przeniesienie z 3 petli"
			#echo ${BOARD[$(($i-1))]} "zastepuje liczba" ${BOARD[$i]}
			BOARD[$(($i-1))]=${BOARD[$i]}
			BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i-1))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i-1))]} != "x" ]
		then
			#echo "wykonuje laczenie z 3 petli"
			#echo "lacze: " ${BOARD[$(($i-1))]} " z " ${BOARD[$i]}
			BOARD[$(($i-1))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i-1))]="x"
		fi
		if [ $i -eq 2 ] || [ $i -eq 3 ]
		then
			i=$(($i+15))
		fi
		i=$(($i-4))
	done

}

function move_d {
	merged=("." "." "." "." "." "." "." "." "." "." "." "." "." "." "." ".")
	
	# składanie 4 i 3 kolumny
	for (( i=2; i <= 14; )) 
	do
		if [ ${BOARD[$(($i+1))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			#echo "wykonuje przeniesienie"
			#echo ${BOARD[$(($i+1))]} "zastepuje liczba" ${BOARD[$i]}
			BOARD[$(($i+1))]=${BOARD[$i]}
			BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i+1))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i+1))]} != "x" ]
		then
			#echo "wykonuje laczenie"
			#echo "lacze: " ${BOARD[$(($i+1))]} " z " ${BOARD[$i]}
			BOARD[$(($i+1))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i+1))]="x"
		fi
		i=$(($i+4))
	done
	print
	# składanie 4, 3 i 2 kolumny
	for (( i=1; i <= 14; )) 
	do
		if [ ${BOARD[$(($i+1))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			#echo "wykonuje przeniesienie z 2 petli"
			#echo ${BOARD[$(($i+1))]} "zastepuje liczba" ${BOARD[$i]}
			BOARD[$(($i+1))]=${BOARD[$i]}
			BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i+1))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i+1))]} != "x" ]
		then
			#echo "wykonuje laczenie z 2 petli"
			#echo "lacze: " ${BOARD[$(($i+1))]} " z " ${BOARD[$i]}
			BOARD[$(($i+1))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i+1))]="x"
		fi
		if [ $i -eq 13 ]
		then
			i=$(($i-15))
		fi
		i=$(($i+4))
		#print
	done
	# składanie 1 i 2 i 3 kolumny
	for (( i=0; i <= 14; )) 
	do
		if [ ${BOARD[$(($i+1))]} == "." ] && [ ${BOARD[$i]} != "." ]
		then
			#echo "wykonuje przeniesienie z 3 petli"
			#echo ${BOARD[$(($i+1))]} "zastepuje liczba" ${BOARD[$i]}
			BOARD[$(($i+1))]=${BOARD[$i]}
			BOARD[$i]="."
		fi
		if [ ${BOARD[$i]} == ${BOARD[$(($i+1))]} ] && [ ${BOARD[$i]} != "." ] && [ ${merged[$(($i+1))]} != "x" ]
		then
			#echo "wykonuje laczenie z 3 petli"
			#echo "lacze: " ${BOARD[$(($i+1))]} " z " ${BOARD[$i]}
			BOARD[$(($i+1))]=$((${BOARD[$i]}*2))
			BOARD[$i]="."
			merged[$(($i+1))]="x"
		fi
		if [ $i -eq 12 ] || [ $i -eq 13 ]
		then
			i=$(($i-15))
		fi
		i=$(($i+4))
	done

}

function check_w {
	CAN_MOVE_TO_SELECTED_DIR=0
	for (( i=0; i<=11; i++))
	do
		if [ ${BOARD[$i]} == ${BOARD[$(($i+4))]} ] && [ ${BOARD[$i]} != "." ]
		then
			CAN_MOVE_TO_SELECTED_DIR=1
			break
		fi
		if [ ${BOARD[$i]} != ${BOARD[$(($i+4))]} ] && [ ${BOARD[$i]} == "." ]
		then
			CAN_MOVE_TO_SELECTED_DIR=1
			break
		fi
	done
}

function check_s {
	CAN_MOVE_TO_SELECTED_DIR=0
	for (( i=0; i<=11; i++))
	do
		if [ ${BOARD[$i]} == ${BOARD[$(($i+4))]} ] && [ ${BOARD[$i]} != "." ]
		then
			CAN_MOVE_TO_SELECTED_DIR=1
			break
		fi
		if [ ${BOARD[$i]} != ${BOARD[$(($i+4))]} ] && [ ${BOARD[$(($i+4))]} == "." ]
		then
			CAN_MOVE_TO_SELECTED_DIR=1
			break
		fi
	done
}

function check_a {
	CAN_MOVE_TO_SELECTED_DIR=0
	for (( i=1; i<=15;))
	do
		if [ ${BOARD[$i]} == ${BOARD[$(($i-1))]} ] && [ ${BOARD[$i]} != "." ]
		then
			CAN_MOVE_TO_SELECTED_DIR=1
			break
		fi
		if [ ${BOARD[$i]} != ${BOARD[$(($i-1))]} ] && [ ${BOARD[$(($i-1))]} == "." ]
		then
			CAN_MOVE_TO_SELECTED_DIR=1
			break
		fi
		if [ $i -eq 13 ] || [ $i -eq 14 ]
		then
			i=$(($i-15))
		fi
		i=$(($i+4))
	done
}

function check_d {
	CAN_MOVE_TO_SELECTED_DIR=0
	for (( i=14; i>=0;))
	do
		if [ ${BOARD[$i]} == ${BOARD[$(($i+1))]} ] && [ ${BOARD[$i]} != "." ]
		then
			CAN_MOVE_TO_SELECTED_DIR=1
			break
		fi
		if [ ${BOARD[$i]} != ${BOARD[$(($i+1))]} ] && [ ${BOARD[$(($i+1))]} == "." ]
		then
			CAN_MOVE_TO_SELECTED_DIR=1
			break
		fi
		if [ $i -eq 2 ] || [ $i -eq 1 ]
		then
			i=$(($i+11))
		fi
		i=$(($i-4))
	done
}


function new_move {
	entered_correct_char=0
	while [ $entered_correct_char -eq 0 ]
	do
		print
		check_board
		if [ $WIN -eq -1 ] || [ $WIN -eq 1 ]
		then
			break
		fi
		read -n 1 char
		case $char in
			w)
				check_w
				if [ $CAN_MOVE_TO_SELECTED_DIR -eq 1 ]
				then
					entered_correct_char=1
					move_w
				fi
				;;
			s)
				check_s
				if [ $CAN_MOVE_TO_SELECTED_DIR -eq 1 ]
				then
					entered_correct_char=1
					move_s
				fi
				;;
			a)
				check_a
				if [ $CAN_MOVE_TO_SELECTED_DIR -eq 1 ]
				then
					entered_correct_char=1
					move_a
				fi
				;;
			d)
				check_d
				if [ $CAN_MOVE_TO_SELECTED_DIR -eq 1 ]
				then
					entered_correct_char=1
					move_d
				fi
				;;
			x)
				exit 1
				;;
		esac
	done
}

function play {
	init
	while [ $WIN -eq 0 ]
	do
		if [ $WIN -eq 0 ]
		then
			new_move
			enter_new_number
		fi
		if [ $WIN -eq -1 ]
		then
			print
			echo "Przegrałeś!"
		fi
		if [ $WIN -eq 1 ]
		then
			print
			echo "Wygrałeś!"
		fi
	done
}

help
play
