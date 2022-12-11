#!/bin/sh

# Solution to https://adventofcode.com/2022/day/4

# Run as:
# cat advent_04_sample.txt | sh advent_04.sh
# cat advent_04_input.txt  | sh advent_04.sh

set -e

sum=0

IFS=','
while read -r p1 p2
do
	p1Start=$( printf '%s' "$p1" | cut -d '-' -f 1 )
	p1End=$( printf '%s' "$p1" | cut -d '-' -f 2 )

	p2Start=$( printf '%s' "$p2" | cut -d '-' -f 1 )
	p2End=$( printf '%s' "$p2" | cut -d '-' -f 2 )

	if [ "$p1Start" -lt "$p2Start" ]
	then
		[ "$p2End" -le "$p1End" ] && sum=$(( sum + 1 ))
	elif [ "$p2Start" -lt "$p1Start" ]
	then
		[ "$p1End" -le "$p2End" ] && sum=$(( sum + 1 ))
	else
		sum=$(( sum + 1 ))
	fi
done

echo "Sum: $sum"