#!/bin/sh

# Solution to https://adventofcode.com/2022/day/16

# Run as:
# cat advent_16_sample.txt | sh advent_16.sh
# cat advent_16_input.txt  | sh advent_16.sh

set -e

allValvesToOpen=
maxValvesToOpen=0

while read -r line
do
	valve=$( printf '%s' "$line" | sed 's/^Valve \([A-Z][A-Z]\) .*/\1/' )
	rate=$( printf '%s' "$line" | sed 's/.*rate=\([0-9]\{1,\}\).*/\1/' )

	# shellcheck disable=SC2034 # Used by eval below
	exits=$( printf '%s' "$line" \
		| sed 's/.* valves\{0,1\} \(.*\)$/\1/' | tr ',' ' ' )

	eval "valve_${valve}_rate=\$rate"
	eval "valve_${valve}_exits=\$exits"

	if  [ "$rate" -gt 0 ]
	then
		allValvesToOpen="$allValvesToOpen $valve"
		maxValvesToOpen=$(( maxValvesToOpen + 1 ))
	fi
done

readonly allValvesToOpen
readonly maxValvesToOpen


# Find all pathes using BFS
findBestPathes()
{
	# Path already exists?
	pathExists=; eval "pathExists=\$path_${fromValve}_${toValve}"
	[ -n "$pathExists" ] && return 0

	# Direct connection?
	exits=; eval "exits=\$valve_${fromValve}_exits"
	case " $exits " in *" $toValve "*)
			eval "path_${fromValve}_${toValve}=1"
			eval "path_${toValve}_${fromValve}=1"
			return 0
		;;
	esac

	lowestSteps=0

	blacklist=
	greylist=$fromValve

	while [ -n "$greylist" ]
	do
		newGreylist=
		for valve in $greylist
		do
			pathExists=; eval "pathExists=\$path_${fromValve}_${valve}"
			if [ -z "$pathExists" ]
			then
				eval "path_${fromValve}_${valve}=$lowestSteps"
				eval "path_${valve}_${fromValve}=$lowestSteps"
			fi

			if [ "$valve" = "$toValve" ]
			then
				eval "path_${fromValve}_${toValve}=$lowestSteps"
				eval "path_${toValve}_${fromValve}=$lowestSteps"
				newGreylist=
				break
			fi

			exits=; eval "exits=\$valve_${valve}_exits"
			for ex in $exits
			do
				case " $blacklist " in *" $ex "*) continue; esac
				newGreylist="$newGreylist $ex"
			done
		done

		if [ -n "$newGreylist" ]
		# if [ ${#newGreylist} -ne 0 ]
		then
			blacklist="$blacklist $greylist"
		fi

		lowestSteps=$(( lowestSteps + 1 ))
		greylist=$newGreylist
	done

	return 0
}


counter=0
for fromValve in $allValvesToOpen
do
	counter=$(( counter + 1 ))
	if [ $counter -eq  $maxValvesToOpen ]
	then
		# We already have all paths from/to the last vault to open
		# but we are still missing paths from/to the start
		fromValve='AA'
	fi

	for toValve in $allValvesToOpen
	do
		if [ "$fromValve" != "$toValve" ]
		then
			findBestPathes
		fi
	done
done



# Find best path combination using backtracking

bestResultSoFar=0

atValve='AA'
openValves=
currentResult=0
timeRemaining=30


btIdx=0

openValve()
{
	rate=0; eval "rate=\$valve_${atValve}_rate"
	currentResult=$(( currentResult + ( timeRemaining * rate) ))

	[ $currentResult -gt $bestResultSoFar ] && bestResultSoFar=$currentResult
	[ $timeRemaining -eq 1 ] && return 0

	openValves="$openValves $atValve"

	for valve in $allValvesToOpen
	do
		travelTime=; eval "travelTime=\$path_${atValve}_${valve}"
		if [ $(( travelTime + 1 )) -lt $timeRemaining ]
		then
			case " $openValves " in *" $valve "*) ;;
			*)
				eval "stack_${btIdx}_at=\$atValve"
				eval "stack_${btIdx}_open=\$openValves"
				eval "stack_${btIdx}_result=\$currentResult"
				eval "stack_${btIdx}_time=\$timeRemaining"
				btIdx=$(( btIdx + 1 ))

				timeRemaining=$(( timeRemaining - travelTime - 1))
				atValve=$valve
				openValve

				btIdx=$(( btIdx - 1 ))
				eval "atValve=\$stack_${btIdx}_at"
				eval "openValves=\$stack_${btIdx}_open"
				eval "currentResult=\$stack_${btIdx}_result"
				eval "timeRemaining=\$stack_${btIdx}_time"
			esac
		fi
	done
}

openValve

echo "Most pressure release: $bestResultSoFar"