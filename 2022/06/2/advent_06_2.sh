#!/bin/sh

# Run as:
# cat advent_06_2_input.txt | sh advent_06_2.sh

set -e

seq=$( dd bs=1 count=14 2>/dev/null )
[ -n "$seq" ] || { echo "Error 1"; exit 1; }
[ ${#seq} -eq 14 ] || { echo "Error 2"; exit 1; }

readonly true=0
readonly false=1

hasDupes()
{
	cnt=$( printf '%s' "$1" | sed 's/\(.\)/\1\n/g' | sort | uniq | wc -l )
	[ "$cnt" -eq 14 ] && return $false
	return $true
}


count=14
while true
do
	if ! hasDupes "$seq"
	then
		echo "Count: $count"
		exit 0
	fi

	count=$(( count + 1 ))
	newChar=$( dd bs=1 count=1 2>/dev/null )
	[ -n "$newChar" ] || exit

	seq=$( printf '%s' "$seq" | cut -c 2- )
	seq="$seq$newChar"
done