#!/bin/sh

# Solution to https://adventofcode.com/2022/day/1

# Run as:
# cat advent_01_sample.txt | sh advent_01.sh
# cat advent_01_input.txt  | sh advent_01.sh

set -e

highest=0
current=0

while read -r line
do
	if [ -z "$line" ]
	then
		[ $current -gt $highest ] && highest=$current
		current=0
	else
		current=$(( current + line ))
	fi
done

[ $current -gt $highest ] && highest=current
echo "Answer: $highest"