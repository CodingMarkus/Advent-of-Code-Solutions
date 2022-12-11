#!/bin/sh

# Run as:
# cat advent_06_2_sample.txt | sh advent_06_2.sh
# cat advent_06_2_input.txt  | sh advent_06_2.sh

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
read -r line || true

for char in $( printf '%s' "$line" | sed 's/\(.\)/\1 /g' )
do
	if ! hasDupes "$seq"
	then
		echo "Count: $count"
		exit 0
	fi

	count=$(( count + 1 ))
	seq=$( printf '%s' "$seq" | cut -c 2- )
	seq="$seq$char"
done

echo "Not found"
exit 1