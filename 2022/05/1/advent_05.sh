#!/bin/sh

# Run as:
# cat advent_05_sample.txt | sh advent_05.sh
# cat advent_05_input.txt  | sh advent_05.sh

set -e

stacks=
moves=

newline=$( printf '\n_' )
readonly newline="${newline%_}"

IFS=''
while read -r line
do
	if printf '%s' "$line" | grep -q '\['
	then
		line=$( printf '%s' "$line" \
			| sed "s/^   /[_]/g" | sed "s/    / [_]/g" | tr -d '[]' )
		stacks="$stacks$line$newline"
	elif printf '%s' "$line" | grep -q '^move'
	then
		line=$( printf '%s' "$line" | tr -C -d '[:digit:][:space:]' )
		moves="$moves$line$newline"
	fi
done


printf '%s' "$stacks" | {
	IFS=' '
	while read -r s1 s2 s3 s4 s5 s6 s7 s8 s9
	do
		[ "$s1" = '_' ] || stack1="$stack1$s1"
		[ "$s2" = '_' ] || stack2="$stack2$s2"
		[ "$s3" = '_' ] || stack3="$stack3$s3"
		[ "$s4" = '_' ] || stack4="$stack4$s4"
		[ "$s5" = '_' ] || stack5="$stack5$s5"
		[ "$s6" = '_' ] || stack6="$stack6$s6"
		[ "$s7" = '_' ] || stack7="$stack7$s7"
		[ "$s8" = '_' ] || stack8="$stack8$s8"
		[ "$s9" = '_' ] || stack9="$stack9$s9"
	done

	printf '%s' "$moves" | {
		while read -r cnt from to
		do
			while [ "$cnt" -gt 0 ]
			do
				fromStack=
				eval "fromStack=\$stack$from"
				swap=$( printf '%s' "$fromStack" | cut -c 1-1 )
				rest=$( printf '%s' "$fromStack" | cut -c 2- )
				[ -n "$swap" ] || { echo "Error: empty swap"; exit 1; }
				eval "stack$to=\"\$swap\$stack$to\""
				eval "stack$from=\$rest"
				cnt=$(( cnt - 1 ))
			done
		done

		result=$( printf '%s' "$stack1" | cut -c 1-1 )
		result="$result$( printf '%s' "$stack2" | cut -c 1-1 )"
		result="$result$( printf '%s' "$stack3" | cut -c 1-1 )"
		result="$result$( printf '%s' "$stack4" | cut -c 1-1 )"
		result="$result$( printf '%s' "$stack5" | cut -c 1-1 )"
		result="$result$( printf '%s' "$stack6" | cut -c 1-1 )"
		result="$result$( printf '%s' "$stack7" | cut -c 1-1 )"
		result="$result$( printf '%s' "$stack8" | cut -c 1-1 )"
		result="$result$( printf '%s' "$stack9" | cut -c 1-1 )"

		echo "Answer: $result"
	}
}