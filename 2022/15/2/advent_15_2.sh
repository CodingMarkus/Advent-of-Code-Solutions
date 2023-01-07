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



mdistance=0

# "Manhatten Distance"
getDistance()
{
	# $1=x1, $2=y1, $3=x2, $4=y2
	xdiff=$(( $1 > $3 ? $1 - $3 : $3 - $1 ))
	ydiff=$(( $2 > $4 ? $2 - $4 : $4 - $2 ))
	mdistance=$(( xdiff + ydiff ))
	return 0
}



lastCollSensorX=0
lastCollSensorY=0
lastCollSensorR=0

checkForCollision()
{
	sensorToCheck=0
	while [ $sensorToCheck -lt $sensorCount ]
	do
		eval "testX=\$sensor_x_${sensorToCheck}"
		eval "testY=\$sensor_y_${sensorToCheck}"
		eval "testR=\$radius_${sensorToCheck}"

		# shellcheck disable=SC2154,SC2086 # Set by eval above
		getDistance $nextX $nextRow $testX $testY

		# shellcheck disable=SC2154,SC2086 # Set by eval above
		if [ $mdistance -le $testR ]
		then
			lastCollSensorX=$testX
			lastCollSensorY=$testY
			lastCollSensorR=$testR
			return 0
		fi

		sensorToCheck=$(( sensorToCheck + 1 ))
	done

	echo "Tuning frequency: $(( (nextX * 4000000) + nextRow ))"
	exit 0
}



lineIntersectionX=0
lineIntersectionY=0

calcLineIntersection()
{
	# $1=x1, $2=y1, $3=x2, $4=y2
	# $5=x3, $6=y3, $7=x4, $8=y4

	denom="(($1 - $3) * ($6 - $8)) - (($2 - $4) * ($5 - $7))"
	denom=$( printf '%s\n' "$denom" | bc )
	if [ "$denom" -eq 0 ]
	then
		lineIntersectionY=
		return 0
	fi

	numer1="(($1 * $4) - ($2 * $3)) * ($5 - $7)"
	numer2="($1 - $3) * (($5 * $8) - ($6 * $7))"
	lineIntersectionX=$( printf '%s\n' "($numer1 - $numer2) / $denom" | bc )

	numer1="(($1 * $4) - ($2 * $3)) * ($6 - $8)"
	numer2="($2 - $4) * (($5 * $8) - ($6 * $7))"
	lineIntersectionY=$( printf '%s\n' "($numer1 - $numer2) / $denom" | bc )

	return 0
}



pointIsInPlane()
{
	# $1=x, $2=y, $3=planeX, $4=planeY, $5=planeR
	getDistance "$1" "$2" "$3" "$4"
	[ $mdistance -le "$5" ]
}



intersectionAtRow=0

updateIntersectionAtRow()
{
	intsX=$lineIntersectionX
	intsY=$lineIntersectionY

	# shellcheck disable=SC2086
	if pointIsInPlane $intsX $intsY $x1 $y1 $r1 \
		&& pointIsInPlane $intsX $intsY $x2 $y2 $r2
	then
		intersectionAtRow=$intsY
		return 0
	fi

	# Compensate for rounding errors
	intsXMax=$(( intsX + 1 ))
	intsYMax=$(( intsY + 1 ))
	intsXMin=$(( intsX - 1 ))
	intsYMin=$(( intsY - 1 ))

	intsY=$intsYMax
	while [ $intsY -ge $intsYMin ]
	do
		intsX=$intsXMax
		while [ $intsX -ge $intsXMin ]
		do
			# shellcheck disable=SC2086
			if pointIsInPlane $intsX $intsY $x1 $y1 $r1 \
				&& pointIsInPlane $intsX $intsY $x2 $y2 $r2
			then
				intersectionAtRow=$intsY
				return 0
			fi
			intsX=$(( intsX - 1 ))
		done
		intsY=$(( intsY - 1 ))
	done
	return 0
}


calcIntersection_C()
{
	xa=$traverseFromX; ya=$traverseFromY
	xb=$traverseToX; yb=$traverseToY
	x1=$sensorX; y1=$sensorY; r1=$extendedRadius
	x2=$lastCollSensorX ; y2=$lastCollSensorY; r2=$lastCollSensorR

	intersectionAtRow=

	# shellcheck disable=SC2086
	calcLineIntersection \
		$xa $ya $xb $yb \
		$(( x2 + r2 )) $y2 $x2 $(( y2 + r2 )) # x - c
	updateIntersectionAtRow
	return 0
}



calcIntersection_B()
{
	xa=$traverseFromX; ya=$traverseFromY
	xb=$traverseToX; yb=$traverseToY
	x1=$sensorX; y1=$sensorY; r1=$extendedRadius
	x2=$lastCollSensorX ; y2=$lastCollSensorY; r2=$lastCollSensorR

	intersectionAtRow=

	# shellcheck disable=SC2086
	calcLineIntersection \
		$xa $ya $xb $yb \
		$(( x2 - r2 )) $y2 $x2 $(( y2 + r2 )) # x - b
	updateIntersectionAtRow
	return 0
}


readonly true=0
readonly false=1


checkNextRowIsValid()
{
	if [ "$nextRow" -gt $searchFieldSize ]
	then
		nextRow=$(( traverseToY + 1 ))
		return $false
	fi
	if [ "$nextRow" -lt 0 ]
	then
		rowsToSkip=$(( -nextRow ))
		nextX=$(( nextX + (rowsToSkip * deltaX) ))
		nextRow=$(( nextRow + rowsToSkip ))
		return $false
	fi
	return $true
}


advanceNextRow()
{
	if [ "$lastCollSensorR" -eq 0 ]
	then
		checkForCollision
		if [ $deltaX -lt 0 ]
		then

			calcIntersection_B
		else
			calcIntersection_C
		fi

		if [ -z "$intersectionAtRow" ]
		then
			nextRow=$(( traverseToY + 1 ))
		elif [ "$intersectionAtRow" -gt "$nextRow" ]
		then
			rowsToSkip=$(( intersectionAtRow - nextRow ))
			nextX=$(( nextX + (rowsToSkip * deltaX) ))
			nextRow=$intersectionAtRow
		else
			nextX=$(( nextX + deltaX ))
			nextRow=$(( nextRow + 1 ))
		fi
	else
		getDistance "$nextX" "$nextRow" "$lastCollSensorX" "$lastCollSensorY"
		if [ $mdistance -ge "$lastCollSensorR" ]
		then
			lastCollSensorR=0
		else
			# Compensate for rounding errors
			nextRow=$(( nextRow + 1 ))
			nextX=$(( nextX + deltaX ))
		fi
	fi
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
		eval "radius_${sensorCount}=\$mdistance"

		sensorCount=$(( sensorCount + 1 ))
	done

	sensorToInspect=0
	while [ $sensorToInspect -lt $sensorCount ]
	do
		eval "sensorX=\$sensor_x_${sensorToInspect}"
		eval "sensorY=\$sensor_y_${sensorToInspect}"
		eval "radius=\$radius_${sensorToInspect}"

		# shellcheck disable=SC2154 # Set by eval above
		extendedRadius=$(( radius + 1 ))

		# a /\ d
		# b \/ c

		# a
		lastCollSensorR=0
		traverseFromX=$sensorX
		traverseFromY=$(( sensorY - extendedRadius ))
		traverseToX=$(( sensorX - extendedRadius ))
		traverseToY=$sensorY
		deltaX=-1
		nextX=$traverseFromX
		nextRow=$traverseFromY
		while [ "$nextRow" -le "$traverseToY" ]
		do
			checkNextRowIsValid || continue

			[ "$nextX" -lt 0 ] && break
			if [ "$nextX" -gt $searchFieldSize ]
			then
				rowsToSkip=$(( nextX - searchFieldSize  ))
				nextX=$(( nextX + (rowsToSkip * deltaX) ))
				nextRow=$(( nextRow + rowsToSkip ))
				continue
			fi

			advanceNextRow
		done


		# b
		lastCollSensorR=0
		traverseFromX=$(( sensorX - extendedRadius ))
		traverseFromY=$sensorY
		traverseToX=$sensorX
		traverseToY=$(( sensorY + extendedRadius ))
		deltaX=1
		nextX=$traverseFromX
		nextRow=$traverseFromY

		while [ "$nextRow" -le $traverseToY ]
		do
			checkNextRowIsValid || continue

			[ "$nextX" -gt $searchFieldSize ] && break
			if [ "$nextX" -lt 0 ]
			then
				rowsToSkip=$(( -nextX  ))
				nextX=$(( nextX + (rowsToSkip * deltaX) ))
				nextRow=$(( nextRow + rowsToSkip ))
				continue
			fi

			advanceNextRow
		done

		# c
		lastCollSensorR=0
		traverseFromX=$(( sensorX + extendedRadius ))
		traverseFromY=$sensorY
		traverseToX=$sensorX
		traverseToY=$(( sensorY + extendedRadius ))
		deltaX=-1
		nextX=$traverseFromX
		nextRow=$traverseFromY
		while [ "$nextRow" -le $traverseToY ]
		do
			checkNextRowIsValid || continue

			[ $nextX -lt 0 ] && break
			if [ "$nextX" -gt $searchFieldSize ]
			then
				rowsToSkip=$(( nextX - searchFieldSize  ))
				nextX=$(( nextX + (rowsToSkip * deltaX) ))
				nextRow=$(( nextRow + rowsToSkip ))
				continue
			fi

			advanceNextRow
		done

		# d
		lastCollSensorR=0
		traverseFromX=$sensorX
		traverseFromY=$(( sensorY - extendedRadius ))
		traverseToX=$(( sensorX + extendedRadius ))
		traverseToY=$sensorY
		deltaX=1
		nextX=$traverseFromX
		nextRow=$traverseFromY
		while [ "$nextRow" -le "$traverseToY" ]
		do
			checkNextRowIsValid || continue

			[ "$nextX" -gt $searchFieldSize ] && break
			if [ "$nextX" -lt 0 ]
			then
				rowsToSkip=$(( -nextX  ))
				nextX=$(( nextX + (rowsToSkip * deltaX) ))
				nextRow=$(( nextRow + rowsToSkip ))
				continue
			fi

			advanceNextRow
		done

		sensorToInspect=$(( sensorToInspect + 1 ))
	done

	echo "Tuning frequency not found"
	exit 1
}
