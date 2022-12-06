#!/bin/sh

# Run as:
# cat advent_01_2_input.txt | sh advent_01_2.sh

set -e

sumUp()
(
	current=0
	while read -r line
	do
		if [ -z "$line" ]
		then
			echo $current
			current=0
		else
			current=$(( current + line ))
		fi
	done
	printf '%s\n' "$current"
)

total=0

for top3 in $( sumUp | sort -n | tail -n 3 )
do
	total=$(( total + top3 ))
done

echo $total