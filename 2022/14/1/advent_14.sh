#!/bin/sh

# Solution to https://adventofcode.com/2022/day/14

# Run as:
# cat advent_14_sample.txt | sh advent_14.sh
# cat advent_14_input.txt  | sh advent_14.sh

set -e

setOccupied()
{
	eval "map_${1}_${2}=$3"
}


mapFromTo()
{
	posX=$1
	posY=$2
	toX=$3
	toY=$4

	dX=0
	dY=0
	dist=0
	if [ "$posX" != "$toX" ]
	then
		if [ "$posX" -lt "$toX" ]
		then
			dX=1
			dist=$(( toX - posX + 1 ))
		else
			dX=-1
			dist=$(( posX - toX + 1 ))
		fi
	else
		if [ "$posY" -lt "$toY" ]
		then
			dY=1
			dist=$(( toY - posY + 1 ))
		else
			dY=-1
			dist=$(( posY - toY + 1 ))
		fi
	fi

	while [ $dist -gt 0 ]
	do
		setOccupied "$posX" "$posY" '#'
		: $(( dist = dist - 1, posX = posX + dX, posY = posY + dY  ))
	done
}

maxDepth=0

IFS=' ->'
while read -r line
do
	for coords in $line
	do
		[ -n "$coords" ] || continue
		x=${coords%,*}
		y=${coords#"$x",}
		[ -z "$xpos" ] && { xpos=$x; ypos=$y; continue; }
		mapFromTo "$xpos" "$ypos" "$x" "$y"
		[ "$y" -gt "$maxDepth" ] && maxDepth="$y"
		xpos=$x
		ypos=$y
	done
	xpos=
	ypos=
done
maxDepth=$(( 0 + maxDepth ))


isFree()
{
	eval "field=\$map_${1}_${2}"
	[ -z "$field" ]
}


count=0
readonly true=0

produceSand()
{
	while true
	do
		grainX=500
		grainY=0
		isFree $grainX $grainY || return $true

		while true
		do
			if isFree $grainX $(( grainY + 1 ))
			then
				grainY=$(( grainY + 1 ))

			elif isFree $(( grainX - 1 )) $(( grainY + 1 ))
			then
				grainX=$(( grainX - 1 ))
				grainY=$(( grainY +  1 ))

			elif isFree $(( grainX + 1 )) $(( grainY + 1 ))
			then
				grainX=$(( grainX + 1 ))
				grainY=$(( grainY + 1 ))

			else
				count=$(( count + 1 ))
				setOccupied $grainX $grainY 'o'
				break
			fi
			[ "$grainY" -ge $maxDepth ] && return $true
		done
	done
}


produceSand

echo "Units: $count"
