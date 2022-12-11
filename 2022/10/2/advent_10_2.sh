#!/bin/sh

# Solution to https://adventofcode.com/2022/day/10

# Run as:
# cat advent_10_2_sample.txt | sh advent_10_2.sh
# cat advent_10_2_input.txt  | sh advent_10_2.sh

set -e

x=2
cycles=1
while read -r instruction value
do
	case $instruction in
		noop) delay=1;;
		addx) delay=2;;
		*) echo "Error: Bad instructions"; exit 1;;
	esac

	while [ $delay -gt 0 ]
	do
		if [ $(( cycles > x ? cycles - x : x - cycles )) -lt 2 ]
		then
			printf '#'
		else
			printf '.'
		fi
		if [ $(( cycles % 40 )) -eq 0 ]
		then
			printf '\n'
			cycles=1;
		else
			cycles=$(( cycles + 1 ))
		fi
		delay=$(( delay - 1 ))
	done

	if [ "$instruction" = "addx" ]
	then
		x=$(( x + value ))
	fi
done

echo