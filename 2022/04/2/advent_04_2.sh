#!/bin/sh

# Run as:
# cat advent_04_2_input.txt | sh advent_04_2.sh

set -e

sum=0

IFS=','
while read -r p1 p2
do
	p1Start=$( printf '%s' "$p1" | cut -d '-' -f 1 )
	p1End=$( printf '%s' "$p1" | cut -d '-' -f 2 )

	p2Start=$( printf '%s' "$p2" | cut -d '-' -f 1 )
	p2End=$( printf '%s' "$p2" | cut -d '-' -f 2 )

	if [ "$p2Start" -ge "$p1Start" ] && [ "$p2Start" -le "$p1End" ]
	then
		sum=$(( sum + 1 ))
	elif [ "$p1Start" -ge "$p2Start" ] && [ "$p1Start" -le "$p2End" ]
	then
		sum=$(( sum + 1 ))
	fi
done

echo "Sum: $sum"