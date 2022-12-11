#!/bin/sh

# Solution to https://adventofcode.com/2022/day/10

# Run as:
# cat advent_10_sample.txt | sh advent_10.sh
# cat advent_10_input.txt  | sh advent_10.sh

set -e

x=1
cycles=1
signal=0
while read -r instruction value
do
	case $instruction in
		noop) delay=1;;
		addx) delay=2;;
		*) echo "Error: Bad instructions"; exit 1;;
	esac

	while [ $delay -gt 0 ]
	do
		if [ $(( (cycles - 20) % 40 )) -eq 0 ]
		then
			signal=$(( signal + ( cycles * x ) ))
		fi
		cycles=$(( cycles + 1 ))
		delay=$(( delay - 1 ))
	done

	if [ "$instruction" = "addx" ]
	then
		x=$(( x + value ))
	fi
done

echo "Signal strength: $signal"