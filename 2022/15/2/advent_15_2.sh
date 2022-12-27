#!/bin/sh

# Solution to https://adventofcode.com/2022/day/15

# Run as:
# cat advent_15_2_sample.txt | sh advent_15_2.sh
# cat advent_15_2_input.txt  | sh advent_15_2.sh

set -e

newline=$( printf '\n_' )
readonly newline="${newline%_}"

coordinates=
while read -r line
do
	case $line in
		"Search field size: "*)
			searchFieldSize=$( printf '%s' "$line" \
				| sed 's/.*: \([[:digit:]]\{1,\}\).*/\1/' )
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

searchFieldSize=$(( searchFieldSize + 0 ))
[ -n "$searchFieldSize" ] \
	|| { echo "Error: searchFieldSize missing!"; exit 1; }




distance=0

# "Manhatten Distance"
getDistance()
{
	# $1 = x1
	# $2 = y1
	# $3 = x2
	# $4 = y2
	xdiff=$(( $1 > $3 ? $1 - $3 : $3 - $1 ))
	ydiff=$(( $2 > $4 ? $2 - $4 : $4 - $2 ))
	distance=$(( xdiff + ydiff ))
}


sensorCount=0

checkCollision()
{
	sensorToCheck=0
	while [ $sensorToCheck -lt $sensorCount ]
	do
		eval "testX=\$sensor_x_${sensorToCheck}"
		eval "testY=\$sensor_y_${sensorToCheck}"
		eval "testR=\$radius_${sensorToCheck}"

		# shellcheck disable=SC2154,SC2086 # Set by eval above
		getDistance $testX $testY $1 $2

		# shellcheck disable=SC2154,SC2086 # Set by eval above
		[ $distance -le $testR ] && return

		sensorToCheck=$(( sensorToCheck + 1 ))
	done

	echo "Tuning frequency: $(( ($1 * 4000000) + $2 ))"
	exit 0
}


printf '%s' "$coordinates" | {
	while read -r sensorX sensorY beaconX beaconY
	do
		[ -n "$sensorX" ] || { echo "Error: sensorX missing!"; exit 1; }
		[ -n "$sensorY" ] || { echo "Error: sensorY missing!"; exit 1; }
		[ -n "$beaconX" ] || { echo "Error: beaconX missing!"; exit 1; }
		[ -n "$beaconY" ] || { echo "Error: beaconY missing!"; exit 1; }

		getDistance "$sensorX" "$sensorY" "$beaconX" "$beaconY"

		eval "sensor_x_${sensorCount}=\$sensorX"
		eval "sensor_y_${sensorCount}=\$sensorY"
		eval "radius_${sensorCount}=\$distance"
		sensorCount=$(( sensorCount + 1 ))
	done

	sensorToInspect=0
	while [ $sensorToInspect -lt $sensorCount ]
	do
		eval "sensorX=sensor_x_${sensorToInspect}"
		eval "sensorY=sensor_y_${sensorToInspect}"
		eval "radius=radius_${sensorToInspect}"

		# shellcheck disable=SC2154 # Set by eval above
		r=$(( radius + 1 ))

		row=$(( sensorY - r ))
		[ $row -lt 0 ] && row=0
		[ $row -gt  $searchFieldSize ] && row=$searchFieldSize

		maxRow=$(( sensorY + r ))
		[ $maxRow -lt 0 ] && maxRow=0
		[ $maxRow -gt $searchFieldSize ] && maxRow=$searchFieldSize

		while [ $row -le $maxRow ]
		do
			# shellcheck disable=SC2086
			getDistance $sensorX $sensorY $sensorX $row
			minX=$(( sensorX - (r - distance) ))
			maxX=$(( sensorX + (r - distance) ))
			if [ $minX -ge 0 ] && [ $minX -le $searchFieldSize ]
			then
				checkCollision $minX $row
			fi
			if [ $maxX -ge 0 ] && [ $maxX -le $searchFieldSize ]
			then
				checkCollision $maxX $row
			fi
			row=$(( row + 1 ))
		done

		sensorToInspect=$(( sensorToInspect + 1 ))
	done

	echo "Tuning frequency not found"
	exit 1
}
