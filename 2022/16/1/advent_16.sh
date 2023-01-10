#!/bin/sh

# Solution to https://adventofcode.com/2022/day/16

# Run as:
# cat advent_16_sample.txt | sh advent_16.sh
# cat advent_16_input.txt  | sh advent_16.sh

set -e

# Parse input data

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
	eval "v_${valve}_exits=\$exits"

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
	exits=; eval "exits=\$v_${fromValve}_e"
	case " $exits " in *" $toValve "*)
			eval "c_${fromValve}_${toValve}=2"
			eval "c_${toValve}_${fromValve}=2"
			return 0
		;;
	esac

	# shellcheck disable=2034 # Used by eval's below
	# Cost to open the valve is 1, travel costs come on top
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


# We can discard any approach that is worse than the greedy approach

newline=$( printf '\n_' )
readonly newline="${newline%_}"

ordered=
for valve in $toOpen
do
	# shellcheck disable=2086
	eval rate='$'v_${valve}_r
	# shellcheck disable=2154
	ordered="$ordered$rate $valve$newline"
done
ordered=$( printf '%s' "$ordered" | sort -nr | cut -d ' ' -f 2 )

rate=0
atValve=AA
timeleft=30
for valve in $ordered
do
	eval c="\$c_${atValve}_${valve}"
	# shellcheck disable=2154
	newTimeleft=$(( timeleft - c ))

	while [ $timeleft -gt $newTimeleft ] && [ $timeleft -ge 0 ]
	do
		eval g_${timeleft}=\$rate
		timeleft=$(( timeleft - 1 ))
	done
	[ $timeleft -gt 0 ] || break

	# shellcheck disable=2086
	eval r='$'v_${valve}_r

	# shellcheck disable=2154
	rate=$(( rate + (timeleft * r )))
	atValve=$valve
done

while [ $timeleft -ge 0 ]
do
	eval g_${timeleft}=\$rate
	timeleft=$(( timeleft - 1 ))
done


# Find best path combination using backtracking (DFS)

best=0

# shellcheck disable=2086,2154
# $1=atValve, $2=openValves, $3=timeRemaining, $4=releaseSoFar
next()
{
	eval g='$'g_$3; [ $4 -lt $g ] && return 0
	for v in $toOpen; do case $2 in *":$v:"* ) ;; *)
		eval c="\$c_${1}_${v}"
		if [ $c -lt $3 ]; then open $v $2:$v: $(( $3 - c )) $4; fi
	esac; done
}

# shellcheck disable=2086,2154
# $1=valveToOpen, $2=openValves, $3=timeRemaining, $4=releaseSoFar
open()
{
	eval r='$'v_${1}_r
	rel=$(( $4 + ( $3 * r) ))
	[ $rel -gt $best ] && best=$rel
	if [ $3 -ge 2 ]; then next $1 $2 $3 $rel; fi
}


next 'AA' '' 30 0
echo "Most pressure release: $best"
