#!/bin/sh

# Run as:
# cat advent_09_input.txt | sh advent_09.sh

set -e

headX=500
headY=500

tailX=500
tailY=500

eval "visited_${tailX}_${tailY}=1"

while read -r direction steps
do
	case $direction in
		L) moveX=-1; moveY=0;;
		R) moveX=1; moveY=0;;
		U) moveX=0; moveY=-1;;
		D) moveX=0; moveY=1;;
		*) echo "Error: Unknown move ($direction)"; exit 1;;
	esac

	i=0
	while [ $i -lt "$steps" ]
	do
		i=$(( i + 1 ))
		headX=$(( headX + moveX ))
		headY=$(( headY + moveY ))

		[ $headX -ge 0 ] || { echo "Error: X is negative"; exit 1; }
		[ $headY -ge 0 ] || { echo "Error: Y is negative"; exit 1; }

		deltaX=$(( headX - tailX ))
		deltaY=$(( headY - tailY ))

		if [ $deltaX -eq 2 ] || [ $deltaX -eq -2 ] \
			|| [ $deltaY -eq 2 ] || [ $deltaY -eq -2 ]
		then
			case $deltaX in
				2|1) followX=1;;
				-2|-1) followX=-1;;
				0) followX=0;;
				*) echo "Error: deltaX ($deltaX)"; exit 1;;
			esac

			case $deltaY in
				2|1) followY=1;;
				-2|-1) followY=-1;;
				0) followY=0;;
				*) echo "Error: deltaY ($deltaY)"; exit 1;;
			esac

			tailX=$(( tailX + followX ))
			tailY=$(( tailY + followY ))
			eval "visited_${tailX}_${tailY}=1"
		fi
	done
done

echo "Positions visited: $( set | grep -c visited_ )"