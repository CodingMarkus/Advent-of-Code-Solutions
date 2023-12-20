#!/bin/sh

# Solution to https://adventofcode.com/2022/day/20

# Run as:
# cat advent_20_sample.txt | sh advent_20.sh
# cat advent_20_input.txt  | sh advent_20.sh

set -e -h

tmp=$( mktemp -d )
currentDir=$( pwd )
cd "$tmp"

trap 'cd "$currentDir" ; rm -rf "$tmp"' EXIT


count=0
lineZero=
while read -r value
do
	printf '%s\n' "$value/$count" >>list
	eval "no_${count}=$value"
	[ "$value" -eq 0 ] && lineZero="$value/$count"
	count=$(( count + 1 ))
done
count2=$(( count - 1 ))


lineNoOfRes=0

lineNoOf()
{
	res=$( grep -F -x -n -- "$1" list )
	lineNoOfRes=${res%:*}
}


remove()
{
	sed "${1}d" list >list.new
	mv list.new list
}


insert()
{
	if [ "$2" -gt 0 ]
	then
		sed "$(( $2 + 1 ))i\\
$1
" list >list.new
		mv list.new list
	else
		printf '%s\n' "$1" >>list
	fi
}


valueAtIndex()
{
	lineNo=$(( ($1 % count) + 1 ))
	res=$( sed "${lineNo}q;d" list )
	printf '%s\n' "${res%/*}"
}


index=0
value=0
while [ $index -lt $count ]
do
	eval "value=\$no_${index}"
	line="$value/$index"
	index=$(( index + 1 ))

	lineNoOf "$line"
	remove "$lineNoOfRes"

	newPos=$(( (lineNoOfRes - 1 + value) % count2 ))
	[ $newPos -lt 0 ] && newPos=$(( newPos + count2 ))
	insert "$line" $newPos
done

lineNoOf "$lineZero"
posOfZero=$(( lineNoOfRes - 1 ))

coords=0
coords=$(( coords + $( valueAtIndex $(( posOfZero + 1000 )) ) ))
coords=$(( coords + $( valueAtIndex $(( posOfZero + 2000 )) ) ))
coords=$(( coords + $( valueAtIndex $(( posOfZero + 3000 )) ) ))

echo "Grove coordinates: $coords"