#!/bin/sh

# Solution to https://adventofcode.com/2022/day/16

# Run as:
# cat advent_16_sample.txt | sh advent_16.sh
# cat advent_16_input.txt  | sh advent_16.sh

set -e

toOpen=
maxToOpen=0
while read -r line
do
	valve=$( printf '%s' "$line" | sed 's/^Valve \([A-Z][A-Z]\) .*/\1/' )
	rate=$( printf '%s' "$line" | sed 's/.*rate=\([0-9]\{1,\}\).*/\1/' )

	# shellcheck disable=2034 # Used by eval below
	exits=$( printf '%s' "$line" \
		| sed 's/.* valves\{0,1\} \(.*\)$/\1/' | tr ',' ' ' )

	eval "v_${valve}_r=\$rate"
	eval "v_${valve}_ex=\$exits"

	if  [ "$rate" -gt 0 ]
	then
		toOpen="$toOpen $valve"
		maxToOpen=$(( maxToOpen + 1 ))
	fi
done

readonly toOpen
readonly maxToOpen


# Find lowest costs to move to and open valve using BFS
findLowestCosts()
{
	# shellcheck disable=2086
	eval costsExists='$'c_${fromValve}_${toValve}
	[ -n "$costsExists" ] && return 0

	# Direct connection?
	exits=; eval "exits=\$v_${fromValve}_ex"
	case " $exits " in *" $toValve "*)
			eval "c_${fromValve}_${toValve}=2"
			eval "c_${toValve}_${fromValve}=2"
			return 0
		;;
	esac

	# shellcheck disable=2034 # Used by eval's below
	lowestCosts=1

	blacklist=
	greylist=$fromValve

	while [ -n "$greylist" ]
	do
		newGreylist=
		for valve in $greylist
		do
			# shellcheck disable=2086
			eval costsExists='$'c_${fromValve}_${valve}
			if [ -z "$costsExists" ]
			then
				eval "c_${fromValve}_${valve}=\$lowestCosts"
				eval "c_${valve}_${fromValve}=\$lowestCosts"
			fi

			if [ "$valve" = "$toValve" ]
			then
				eval "c_${fromValve}_${toValve}=\$lowestCosts"
				eval "c_${toValve}_${fromValve}=\$lowestCosts"
				newGreylist=
				break
			fi

			eval ex="\$v_${valve}_ex"
			for ex in $ex
			do
				case " $blacklist " in *" $ex "*) continue; esac
				newGreylist="$newGreylist $ex"
			done
		done

		if [ -n "$newGreylist" ]
		then
			blacklist="$blacklist $greylist"
		fi

		lowestCosts=$(( lowestCosts + 1 ))
		greylist=$newGreylist
	done

	return 0
}


counter=0
for fromValve in $toOpen
do
	counter=$(( counter + 1 ))
	if [ $counter -eq  $maxToOpen ]
	then
		# We already have all costs from/to the last vault to open
		# but we are still missing costs from the start
		fromValve='AA'
	fi

	for toValve in $toOpen
	do
		if [ "$fromValve" != "$toValve" ]
		then
			findLowestCosts
		fi
	done
done


# Find best path combination using backtracking (DFS)

best=0

next()
{
	# $1=atValve, $2=openValves, $3=timeRemaining, $4=releaseSoFar

	for v in $toOpen
	do
		case $2 in *" $v "* ) continue; esac

		# shellcheck disable=2086
		if [ $v != $1 ]
		then
			eval c="\$c_${1}_${v}"
			# shellcheck disable=2154
			if [ $c -lt $3 ]
			then
				open $v "$2" $(( $3 - c )) $4
			fi
		fi
	done
}


open()
{
	# $1=valveToOpen, $2=openValves, $3=timeRemaining, $4=releaseSoFar

	# shellcheck disable=2086
	eval r='$'v_${1}_r
	# shellcheck disable=2154
	rel=$(( $4 + ( $3 * r) ))

	[ $rel -gt $best ] && best=$rel

	# shellcheck disable=2086
	if [ $3 -ge 2 ]
	then
		next $1 "$2 $1" $3 $rel
	fi
}

open 'AA' '' 30 0
echo "Most pressure release: $best"
