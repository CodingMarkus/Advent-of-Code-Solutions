#!/bin/sh

# Solution to https://adventofcode.com/2022/day/11

# Run as:
# cat advent_11_sample.txt | sh advent_11.sh
# cat advent_11_input.txt  | sh advent_11.sh

set -e

monkeyCount=0
setupMonkey()
{
	m=$1
	no=$( printf '%s' "$m" \
		| sed 's/.*Monkey \([0-9]\{1,\}\):.*/\1/')
	starting=$( printf '%s' "$m" \
		| sed 's/.*Starting items: \([0-9, ]\{1,\}\).*/\1/')
	# shellcheck disable=SC2034  # Used in eval
	op=$( printf '%s' "$m" \
		| sed 's/.*Operation: \(.*\) Test:.*/\1/')
	# shellcheck disable=SC2034  # Used in eval
	div=$( printf '%s' "$m" \
		| sed 's/.*Test: divisible by \([0-9]\{1,\}\).*/\1/')
	# shellcheck disable=SC2034  # Used in eval
	onTrue=$( printf '%s' "$m" \
		| sed 's/.*If true: throw to monkey \([0-9]\{1,\}\).*/\1/')
	# shellcheck disable=SC2034  # Used in eval
	onFalse=$( printf '%s' "$m" \
		| sed 's/.*If false: throw to monkey \([0-9]\{1,\}\).*/\1/')

	# shellcheck disable=SC2034  # Used in eval
	items=$( printf '%s' "$starting" | tr -d ',' )

	[ -n "$items" ] || { echo "Error: no items"; exit 1; }
	[ -n "$op" ] || { echo "Error: no inspect operation"; exit 1; }
	[ -n "$div" ] || { echo "Error: no division factor"; exit 1; }
	[ -n "$onTrue" ] || { echo "Error: no onTrue monkey"; exit 1; }
	[ -n "$onFalse" ] || { echo "Error: no onFalse monkey"; exit 1; }

	eval "monkey_${no}_items=\$items"
	eval "monkey_${no}_op=\$op"
	eval "monkey_${no}_div=\$div"
	eval "monkey_${no}_onTrue=\$onTrue"
	eval "monkey_${no}_onFalse=\$onFalse"
	eval "monkey_${no}_counter=0"

	[ $monkeyCount -lt "$no" ] || monkeyCount=$(( no + 1 ))
}


monkey=
while read -r line
do
	if [ ${#line} -eq 0 ]
	then
		setupMonkey "$monkey"
		monkey=
	else
		monkey="$monkey $line"
	fi
done
setupMonkey "$monkey"



addItemToMonkey()
{
	eval "monkey_${2}_items=\"\$monkey_${2}_items $1\""
}


round=0
while [ $round -lt 20 ]
do
	round=$(( round + 1 ))

	no=0
	while [ $no -lt $monkeyCount ]
	do
		op=
		div=
		items=
		onTrue=0
		onFalse=0
		counter=0

		eval "op=\$monkey_${no}_op"
		eval "div=\$monkey_${no}_div"
		eval "items=\$monkey_${no}_items"
		eval "onTrue=\$monkey_${no}_onTrue"
		eval "onFalse=\$monkey_${no}_onFalse"
		eval "counter=\$monkey_${no}_counter"

		for item in $items
		do
			counter=$(( counter + 1 ))

			new=
			# shellcheck disable=SC2034  # Referenced by op
			old=$item
			eval ": \$(( $op ))"
			item=$(( new / 3 ))

			if [ $(( item % div )) -eq 0 ]
			then
				addItemToMonkey $item $onTrue
			else
				addItemToMonkey $item $onFalse
			fi

		done

		eval "monkey_${no}_items="
		eval "monkey_${no}_counter=\$counter"

		no=$(( no + 1 ))
	done

done


first=0
second=0

no=0
while [ $no -lt $monkeyCount ]
do
	counter=0
	eval "counter=\$monkey_${no}_counter"

	if [ $counter -ge $first ]
	then
		second=$first
		first=$counter
	elif [ $counter -gt $second ]
	then
		second=$counter
	fi

	no=$(( no + 1 ))
done

echo "Monkey business: $(( first * second ))"