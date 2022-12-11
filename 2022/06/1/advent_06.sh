#!/bin/sh

# Run as:
# cat advent_06_sample.txt | sh advent_06.sh
# cat advent_06_input.txt  | sh advent_06.sh

set -e

readonly true=0
readonly false=1

hasDupes()
{
	cnt=$( printf '%s\n%s\n%s\n%s\n' "$@" | sort | uniq | wc -l )
	[ "$cnt" -eq 4 ] && return $false
	return $true
}

read -r line || true

count=0
for char in $( printf '%s' "$line" | sed 's/\(.\)/\1 /g' )
do
	if [ -z "$char1" ]
	then
		char1=$char
	elif [ -z "$char2" ]
	then
		char2=$char
	elif [ -z "$char3" ]
	then
		char3=$char
	elif [ -z "$char4" ]
	then
		count=4
		char4=$char
	else
		char1=$char2
		char2=$char3
		char3=$char4
		char4=$char
		count=$(( count + 1 ))
	fi

	if [ $count -ge 4 ]
	then
		if ! hasDupes "$char1" "$char2" "$char3" "$char4"
		then
			echo "Count: $count"
			exit 0
		fi
	fi
done
