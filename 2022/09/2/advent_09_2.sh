#!/bin/sh

# Solution to https://adventofcode.com/2022/day/9

# Run as:
# cat advent_09_2_sample.txt | sh advent_09_2.sh
# cat advent_09_2_input.txt  | sh advent_09_2.sh

set -e

headX=500
headY=500

eval "visited_${headX}_${headY}=1"

i=1
while [ $i -le 9 ]
do
	eval "tail${i}X=500"
	eval "tail${i}Y=500"
	i=$(( i + 1 ))
done


while read -r direction steps
do
	case $direction in
		L) moveX=-1; moveY=0;;
		R) moveX=1; moveY=0;;
		U) moveX=0; moveY=-1;;
		D) moveX=0; moveY=1;;
		*) echo "Error: Unknown move ($direction)"; exit 1;;
	esac

	s=0
	while [ $s -lt "$steps" ]
	do
		s=$(( s + 1 ))
		headX=$(( headX + moveX ))
		headY=$(( headY + moveY ))

		[ $headX -ge 0 ] || { echo "Error: X is negative"; exit 1; }
		[ $headY -ge 0 ] || { echo "Error: Y is negative"; exit 1; }

		i=1
		while [ $i -le 9 ]
		do
			if [ $i -eq 1 ]
			then
				# shellcheck disable=SC2154
				deltaX=$(( headX - tail1X ))
				# shellcheck disable=SC2154
				deltaY=$(( headY - tail1Y ))
			else
				last=$(( i - 1 ))
				eval "deltaX=\$(( tail${last}X - tail${i}X ))"
				eval "deltaY=\$(( tail${last}Y - tail${i}Y ))"
			fi

			if [ $deltaX -eq 2 ] || [ $deltaX -eq -2 ] \
				|| [ $deltaY -eq 2 ] || [ $deltaY -eq -2 ]
			then
				# shellcheck disable=SC2034
				case $deltaX in
					2|1) followX=1;;
					-2|-1) followX=-1;;
					0) followX=0;;
					*) echo "Error: deltaX ($deltaX)"; exit 1;;
				esac

				# shellcheck disable=SC2034
				case $deltaY in
					2|1) followY=1;;
					-2|-1) followY=-1;;
					0) followY=0;;
					*) echo "Error: deltaY ($deltaY)"; exit 1;;
				esac

				eval "tail${i}X=\$(( tail${i}X + followX ))"
				eval "tail${i}Y=\$(( tail${i}Y + followY ))"

				# shellcheck disable=SC2154
				[ $i -eq 9 ] && eval "visited_${tail9X}_${tail9Y}=1"
			fi
			i=$(( i + 1 ))
			# echo "1 ($i)"
		done
		# echo "2 ($s)"
	done
done

echo "Positions visited: $( set | grep -c visited_ )"