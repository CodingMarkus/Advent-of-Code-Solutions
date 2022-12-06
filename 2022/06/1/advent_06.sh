#!/bin/sh

# Run as:
# cat advent_06_input.txt | sh advent_06.sh

set -e

char1=$( dd bs=1 count=1 2>/dev/null )
char2=$( dd bs=1 count=1 2>/dev/null )
char3=$( dd bs=1 count=1 2>/dev/null )
char4=$( dd bs=1 count=1 2>/dev/null )

[ -n "$char1" ] || { echo "Error c1"; exit 1; }
[ -n "$char2" ] || { echo "Error c2"; exit 1; }
[ -n "$char3" ] || { echo "Error c3"; exit 1; }
[ -n "$char4" ] || { echo "Error c4"; exit 1; }


readonly true=0
readonly false=1

hasDupes()
{
	cnt=$( printf '%s\n%s\n%s\n%s\n' "$@" | sort | uniq | wc -l )
	[ "$cnt" -eq 4 ] && return $false
	return $true
}


count=4
while true
do
	if ! hasDupes "$char1" "$char2" "$char3" "$char4"
	then
		echo "Count: $count"
		exit 0
	fi

	count=$(( count + 1 ))
	newChar=$( dd bs=1 count=1 2>/dev/null )
	[ -n "$newChar" ] || exit

	char1=$char2
	char2=$char3
	char3=$char4
	char4=$newChar
done