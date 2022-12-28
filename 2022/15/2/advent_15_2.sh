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


lastCollSensorX=0
lastCollSensorY=0
lastCollSensorR=0

checkCollision()
{
	sensorToCheck=0
	while [ $sensorToCheck -lt $sensorCount ]
	do
		eval "testX=\$sensor2_x_${sensorToCheck}"
		eval "testY=\$sensor2_y_${sensorToCheck}"
		eval "testR=\$radius2_${sensorToCheck}"

		# shellcheck disable=SC2154,SC2086 # Set by eval above
		getDistance $1 $2 $testX $testY

		# shellcheck disable=SC2154,SC2086 # Set by eval above
		if [ $distance -le $testR ]
		then
			lastCollSensorX=$testX
			lastCollSensorY=$testY
			lastCollSensorR=$testR
			return
		fi

		sensorToCheck=$(( sensorToCheck + 1 ))
	done

	echo "Tuning frequency: $(( ($1 * 4000000) + $2 ))"
	exit 0
}


sensorCount=0

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

		eval "sensor2_x_${sensorCount}=\$sensorX"
		eval "sensor2_y_${sensorCount}=\$sensorY"
		eval "radius2_${sensorCount}=\$distance"

		sensorCount=$(( sensorCount + 1 ))
	done

	sensorToInspect=0
	while [ $sensorToInspect -lt $sensorCount ]
	do
		eval "sensorX=sensor_x_${sensorToInspect}"
		eval "sensorY=sensor_y_${sensorToInspect}"
		eval "radius=radius_${sensorToInspect}"

		# shellcheck disable=SC2154 # Set by eval above
		extendedRadius=$(( radius + 1 ))

		minRow=$(( sensorY - extendedRadius ))
		[ $minRow -lt 0 ] && minRow=0
		[ $minRow -gt  $searchFieldSize ] && minRow=$searchFieldSize

		maxRow=$(( sensorY + extendedRadius ))
		[ $maxRow -lt 0 ] && maxRow=0
		[ $maxRow -gt $searchFieldSize ] && maxRow=$searchFieldSize

		row=$minRow
		sensorXR=$(( sensorX - extendedRadius ))
		while [ $row -le $maxRow ]
		do
			deltaY=$(( row > sensorY ? row - sensorY : sensorY - row  ))
			minX=$(( sensorXR + deltaY ))
			if [ $minX -ge 0 ] && [ $minX -le $searchFieldSize ]
			then
				# shellcheck disable=SC2086 # Set by eval above
				getDistance $minX $row $lastCollSensorX $lastCollSensorY
				# shellcheck disable=SC2086 # Set by eval above
				if [ $distance -gt $lastCollSensorR ]
				then
					checkCollision $minX $row
				fi
			fi
			row=$(( row + 1 ))
		done

		row=$minRow
		sensorXR=$(( sensorX + extendedRadius ))
		while [ $row -le $maxRow ]
		do
			deltaY=$(( row > sensorY ? row - sensorY : sensorY - row  ))
			maxX=$(( sensorXR - deltaY ))
			if [ $maxX -ge 0 ] && [ $maxX -le $searchFieldSize ]
			then
				# shellcheck disable=SC2086 # Set by eval above
				getDistance $maxX $row $lastCollSensorX $lastCollSensorY
				# shellcheck disable=SC2086 # Set by eval above
				if [ $distance -gt $lastCollSensorR ]
				then
					checkCollision $maxX $row
				fi
			fi
			row=$(( row + 1 ))
		done

		sensorToInspect=$(( sensorToInspect + 1 ))
	done

	echo "Tuning frequency not found"
	exit 1
}
