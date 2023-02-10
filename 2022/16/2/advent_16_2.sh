#!/bin/sh

# Solution to https://adventofcode.com/2022/day/16

# Run as:
# cat advent_16_2_sample.txt | sh advent_16_2.sh
# cat advent_16_2_input.txt  | sh advent_16_2.sh

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


# Write all combinations possible within 26 minutes to a temp file

tmp=$( mktemp -d )
currentDir=$( pwd )
cd "$tmp"

trap 'cd "$currentDir" ; rm -rf "$tmp"' EXIT


# shellcheck disable=2086,2154
# $1=atValve, $2=openValves, $3=timeRemaining, $4=releaseSoFar
next()
{
	for v in $toOpen; do case $2 in *"$v|"* ) ;; *)
		eval c="\$c_${1}_${v}"
		if [ $c -lt $3 ]; then
			t=$(( $3 - c ))
			eval r='$'v_${v}_r
			rel=$(( $4 + ( t * r) ))
			if [ $t -gt 2 ]; then next $v "$2$v|" $t $rel
				else printf '%s %s\n' "$4" "$2"; fi
		fi
	esac; done
	if [ -n "$2" ]; then printf '%s %s\n' "$4" "$2"; fi
}

# Ensure combinations are sorted by best score
tmpfile="tmp.txt"
( next 'AA' '' 26 0 | sort -n -r ) >"$tmpfile"


# Find the best combination

best=0

lineIdx=1
maxLine=$(( $( cat "$tmpfile" | wc -l ) ))

while [ $lineIdx -le $maxLine ]
do
	lineScore=
	line=$( tail -n +$lineIdx "$tmpfile" | head -n 1 )
	for val in $line
	do
		if [ -z "$lineScore" ]
		then
			lineScore=$val
		else
			grepPattern=$val
		fi
	done
	grepPattern=${grepPattern%%|}

	lineIdx=$(( lineIdx + 1 ))
	line2=$( tail -n +$lineIdx "$tmpfile" \
		| grep -E -v "$grepPattern" \
		| head -n 1 )

	[ -n "$line2" ] || continue

	lineScore2=
	for val in $line2
	do
		lineScore2=$val
		break
	done

	sum=$(( lineScore + lineScore2 ))
	if [ $sum -gt $best ]
	then
		best=$sum
	elif [ $(( lineScore * 2 )) -lt $best ]
	then
		break
	fi
done

echo "Most pressure release: $best"