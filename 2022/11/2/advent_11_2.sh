#!/bin/sh

# Solution to https://adventofcode.com/2022/day/11

# Run as:
# cat advent_11_2_sample.txt | sh advent_11_2.sh
# cat advent_11_2_input.txt  | sh advent_11_2.sh

set -e

mod=1

mCount=0
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

	eval "m_${no}_it=\$items"
	eval "m_${no}_op=\$op"
	eval "m_${no}_div=\$div"
	eval "m_${no}_onT=\$onTrue"
	eval "m_${no}_onF=\$onFalse"
	eval "m_${no}_cnt=0"

	mod=$(( mod * div ))

	[ $mCount -lt "$no" ] || mCount=$(( no + 1 ))
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

r=0
# shellcheck disable=SC2154,SC2086,SC2034
while [ $r -lt 10000 ]
do
	r=$(( r + 1 ))
	no=0
	while [ $no -lt $mCount ]
	do
		eval op='$'m_${no}_op
		eval div='$'m_${no}_div
		eval onT='$'m_${no}_onT
		eval onF='$'m_${no}_onF
		eval it='$'m_${no}_it
		eval cnt='$'m_${no}_cnt

		for old in $it
		do
			cnt=$(( cnt + 1 ))
			eval ": \$(( $op ))"
			it=$(( new % mod ))

			if [ $(( it % div )) -eq 0 ]
			then
				eval m_${onT}_it=\"\$m_${onT}_it $it\"
			else
				eval m_${onF}_it=\"\$m_${onF}_it $it\"
			fi
		done

		eval m_${no}_it=
		eval m_${no}_cnt="\$cnt"
		no=$(( no + 1 ))
	done

done


first=0
second=0

no=0
while [ $no -lt $mCount ]
do
	cnt=0
	eval "cnt=\$m_${no}_cnt"

	if [ $cnt -ge $first ]
	then
		second=$first
		first=$cnt
	elif [ $cnt -gt $second ]
	then
		second=$cnt
	fi

	no=$(( no + 1 ))
done

echo "Monkey business: $(( first * second ))"