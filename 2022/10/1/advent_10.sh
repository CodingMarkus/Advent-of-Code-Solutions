#!/bin/sh

# Run as:
# cat advent_10_input.txt | sh advent_10.sh

set -e

x=1
pc=1
signal=0
while read -r instruction value
do
	case $instruction in
		noop) cycles=1;;
		addx) cycles=2;;
		*) echo "Error: Bad instructions"; exit 1;;
	esac

	while [ $cycles -gt 0 ]
	do
		if [ $(( (pc - 20) % 40 )) -eq 0 ]
		then
			signal=$(( signal + ( pc * x ) ))
		fi
		pc=$(( pc + 1 ))
		cycles=$(( cycles - 1 ))
	done

	if [ "$instruction" = "addx" ]
	then
		x=$(( x + value ))
	fi
done

echo "Signal strength: $signal"