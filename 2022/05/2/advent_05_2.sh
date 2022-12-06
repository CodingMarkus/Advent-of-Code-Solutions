#!/bin/sh

# Run as:
# cat advent_05_2_input.txt | sh advent_05_2.sh

set -e

stacks=
moves=

newline=$( printf '\n_' )
newline=${newline%_}

IFS=''
while read -r line
do
	if printf '%s' "$line" | grep -q '\['
	then
		line=$( printf '%s' "$line" | tr -d '[]' | sed 's/    / _/g' )
		stacks="$stacks$line$newline"
	elif printf '%s' "$line" | grep -q '^move'
	then
		line=$( printf '%s' "$line" | tr -C -d '[:digit:][:space:]' )
		moves="$moves$line$newline"
	fi
done


step2()
(
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

	step3()
	(
		while read -r cnt from to
		do
			eval "fromStack=\$stack$from"
			swap=$( printf '%s' "$fromStack" | cut -c "1-$cnt" )
			rest=$( printf '%s' "$fromStack" | cut -c "$(( cnt + 1))-" )
			[ -n "$swap" ] || echo Error
			eval "stack$to=\"\$swap\$stack$to\""
			eval "stack$from=\$rest"
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
		echo "$result"
	)
	printf '%s' "$moves" | step3
)
printf '%s' "$stacks" | step2