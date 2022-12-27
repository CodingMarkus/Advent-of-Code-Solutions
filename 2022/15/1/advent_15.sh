#!/bin/sh

# Solution to https://adventofcode.com/2022/day/15

# Run as:
# cat advent_15_sample.txt | sh advent_15.sh
# cat advent_15_input.txt  | sh advent_15.sh

set -e

newline=$( printf '\n_' )
readonly newline="${newline%_}"

coordinates=
while read -r line
do
	case $line in
		"Row to inspect "*)
			rowToInspect=$( printf '%s' "$line" \
				| sed 's/.*y=\([[:digit:]]\{1,\}\).*/\1/' )
		;;

		"Sensor at "*)
			next=$( printf '%s' "$line" | \
				sed 's/'\
'^.*x=\(-\{0,1\}[[:digit:]]\{1,\}\), y=\(-\{0,1\}[[:digit:]]\{1,\}\)'\
'.*x=\(-\{0,1\}[[:digit:]]\{1,\}\), y=\(-\{0,1\}[[:digit:]]\{1,\}\)$'\
'/\1 \2 \3 \4/' )
			coordinates="$coordinates$next$newline"
		;;

		*) echo "Error: Bad input line"; exit 1;;
	esac
done

[ -n "$rowToInspect" ] || { echo "Error: rowToInspect missing!"; exit 1; }


# "Manhatten Distance"
getDistance()
{
	# $1 = x1
	# $2 = y1
	# $3 = x2
	# $4 = y2
	xdiff=$(( $1 > $3 ? $1 - $3 : $3 - $1 ))
	ydiff=$(( $2 > $4 ? $2 - $4 : $4 - $2 ))
	printf '%s' "$(( xdiff + ydiff ))"
}

counter=0


swap()
{
	eval "tmp1=\$xleft_${1}"
	eval "tmp2=\$xright_${1}"
	eval "xleft_${1}=\$xleft_${2}"
	eval "xright_${1}=\$xright_${2}"
	eval "xleft_${2}=\$tmp1"
	eval "xright_${2}=\$tmp2"

}


sortRanges()
{
	start=0
	while [ $start -lt $(( counter - 1 )) ]
	do
		lowest=$start
		i=$(( start + 1 ))
		while [ $i -lt $counter ]
		do
			eval "testLeft=\$xleft_${i}"
			eval "lowestLeft=\$xleft_${lowest}"
			# shellcheck disable=SC2154
			[ "$testLeft" -lt "$lowestLeft" ] && lowest=$i
			i=$(( i + 1 ))
		done
		[ $lowest -ne $start ] && swap $lowest $start
		start=$(( start + 1 ))
	done
}


fieldCount=0


subtractBeacons()
{
	j=0
	beaconsFound=
	while [ $j -lt $counter ]
	do
		eval "beaconX=\$beacon_x_${j}"
		eval "beaconY=\$beacon_y_${j}"
		# shellcheck disable=SC2154
		if [ "$beaconY" -eq "$rowToInspect" ] \
			&& [ "$beaconX" -ge "$1" ] && [ "$beaconY" -le "$2" ]
		then
			case $beaconsFound in
				*":$beaconX:"*) ;;
				*) beaconsFound="$beaconsFound:$beaconX:"
					fieldCount=$(( fieldCount -  1 ))
				;;
			esac

		fi
		j=$(( j + 1 ))
	done
}


countRuns()
{
	i=1
	# shellcheck disable=SC2154
	left=$xleft_0
	# shellcheck disable=SC2154
	right=$xright_0
	while [ $i -lt $counter ]
	do
		eval "testLeft=\$xleft_${i}"
		eval "testRight=\$xright_${i}"
		# shellcheck disable=SC2154
		if [ "$right" -ge "$testLeft" ]
		then
			if [ "$testRight" -gt "$right" ]
			then
				right=$testRight
			fi
		else
			fieldCount=$(( fieldCount + (right - left ) + 1 ))
			subtractBeacons "$left" "$right"
			left=$testLeft
			right=$testRight
		fi
		i=$(( i + 1 ))
	done
	fieldCount=$(( fieldCount + (right - left ) + 1 ))
	subtractBeacons "$left" "$right"
}


printf '%s' "$coordinates" | {
	while read -r sensorX sensorY beaconX beaconY
	do
		[ -n "$sensorX" ] || { echo "Error: sensorX missing!"; exit 1; }
		[ -n "$sensorY" ] || { echo "Error: sensorY missing!"; exit 1; }
		[ -n "$beaconX" ] || { echo "Error: beaconX missing!"; exit 1; }
		[ -n "$beaconY" ] || { echo "Error: beaconY missing!"; exit 1; }

		bdist=$( getDistance "$sensorX" "$sensorY" "$beaconX" "$beaconY" )
		rdist=$( getDistance "$sensorX" "$sensorY" "$sensorX" "$rowToInspect" )
		[ "$bdist" -lt "$rdist" ] && continue

		eval "beacon_x_${counter}=\$beaconX"
		eval "beacon_y_${counter}=\$beaconY"
		eval "xleft_${counter}=\$(( sensorX - (bdist - rdist) ))"
		eval "xright_${counter}=\$(( sensorX + (bdist - rdist) ))"
		counter=$(( counter + 1 ))
	done

	sortRanges

	countRuns

	echo "Position count: $fieldCount"
}
