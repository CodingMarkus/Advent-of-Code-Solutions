#!/bin/sh

# Solution to https://adventofcode.com/2022/day/16

# Run as:
# cat advent_16_2_sample.txt | sh advent_16_2.sh
# cat advent_16_2_input.txt  | sh advent_16_2.sh

set -e

# Parse input data

allToOpen=
maxToOpen=0

while read -r line
do
	valve=$( printf '%s' "$line" | sed 's/^Valve \([A-Z][A-Z]\) .*/\1/' )
	rate=$( printf '%s' "$line" | sed 's/.*rate=\([0-9]\{1,\}\).*/\1/' )

	# shellcheck disable=2034 # Used by eval below
	exits=$( printf '%s' "$line" \
		| sed 's/.* valves\{0,1\} \(.*\)$/\1/' | tr ',' ' ' )

	eval "v_${valve}_r=\$rate"
	eval "v_${valve}_exits=\$exits"

	if  [ "$rate" -gt 0 ]
	then
		allToOpen="$allToOpen $valve"
		maxToOpen=$(( maxToOpen + 1 ))
	fi
done

readonly allToOpen
readonly maxToOpen


# Find lowest costs to move to and open valve using BFS
findLowestCosts()
{
	# shellcheck disable=2086
	eval costsExists='$'c_${fromValve}_${toValve}
	[ -n "$costsExists" ] && return 0

	# Direct connection?
	exits=; eval "exits=\$v_${fromValve}_e"
	case " $exits " in *" $toValve "*)
			eval "c_${fromValve}_${toValve}=2"
			eval "c_${toValve}_${fromValve}=2"
			return 0
		;;
	esac

	# shellcheck disable=2034 # Used by eval's below
	lowest=1

	blacklist=
	greylist=$fromValve

	# shellcheck disable=2086
	while [ -n "$greylist" ]
	do
		newGreylist=
		for valve in $greylist
		do
			eval costsExists='$'c_${fromValve}_${valve}
			if [ -z "$costsExists" ]
			then
				eval "c_${fromValve}_${valve}=\$lowest"
				eval "c_${valve}_${fromValve}=\$lowest"
			fi

			if [ "$valve" = "$toValve" ]
			then
				eval "c_${fromValve}_${toValve}=\$lowest"
				eval "c_${toValve}_${fromValve}=\$lowest"
				newGreylist=
				break
			fi

			eval exits="\$v_${valve}_exits"
			for exit in $exits
			do
				case $blacklist in *" $exit "*) continue; esac
				newGreylist="$newGreylist $exit"
			done
		done

		if [ -n "$newGreylist" ]
		then
			blacklist="${blacklist}${greylist}"
		fi

		lowest=$(( lowest + 1 ))
		greylist=$newGreylist
	done

	return 0
}


counter=0
for fromValve in $allToOpen
do
	counter=$(( counter + 1 ))
	if [ $counter -eq  $maxToOpen ]
	then
		# We already have all costs from/to the last vault to open
		# but we are still missing costs from the start
		fromValve='AA'
	fi

	for toValve in $allToOpen
	do
		if [ "$fromValve" != "$toValve" ]
		then
			findLowestCosts
		fi
	done
done


# Find best path combination using backtracking (DFS)

best=0


# shellcheck disable=2086,2154
# $1=atValve, $2=openValves, $3=timeRemaining, $4=releaseSoFar, $5=toOpen
next()
{
	for v in $5; do case $2 in *":$v:"* ) ;; *)
		eval c="\$c_${1}_${v}"
		if [ $c -lt $3 ]; then
			t=$(( $3 - c ))
			eval r='$'v_${v}_r
			rel=$(( $4 + ( t * r) ))
			if [ $t -gt 2 ]; then next $v $2:$v: $t $rel "$5"
				elif [ $rel -gt $best ]; then best=$rel; fi
		fi
	esac; done
	[ $4 -le $best ] || best=$4
}


# Represent all valves to open as a bitmask
# and split into two groups, the iterate each group separately.

bestTotal=0

toOpen=$allToOpen
toOpenE=$allToOpen

mask=6
maxMask=$(( (1 << maxToOpen) - 1 ))

while [ $mask -lt $maxMask ]
do
	echo "$mask of $maxMask"
	bit=1; toOpen=; toOpenE=
	for v in $allToOpen; do
		if [ $(( mask & bit )) -ne 0 ]
			then toOpen="$toOpen $v"
			else toOpenE="$toOpenE $v"; fi
		bit=$(( bit << 1 ))
	done

	if [ ${#toOpen} -gt 6 ]; then
		best=0; next 'AA' '' 26 0 "$toOpen"; next 'AA' '' 26 "$best" "$toOpenE"
		[ "$best" -gt "$bestTotal" ] && bestTotal=$best; fi
	mask=$(( mask + 2 )) # We only want even masks, odd ones are only inverses!
done

echo "Most pressure release: $bestTotal"