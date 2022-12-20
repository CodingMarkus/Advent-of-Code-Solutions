#!/bin/sh

# Solution to https://adventofcode.com/2022/day/14

# Run as:
# cat advent_14_2_sample.txt | sh advent_14_2.sh
# cat advent_14_2_input.txt  | sh advent_14_2.sh

set -e

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
		eval "map_${posX}_${posY}='#'"
		: $(( dist = dist - 1, posX = posX + dX, posY = posY + dY  ))
	done
}

floor=0

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
		[ "$y" -gt "$floor" ] && floor="$y"
		xpos=$x
		ypos=$y
	done
	xpos=
	ypos=
done
floor=$(( 2 + floor ))
lastRow=$(( floor - 1 ))


count=0
readonly true=0

produceSand()
{
	[ -z "$map_500_0" ] || return $true
	grainX=500
	grainY=0

	while true
	do
		if [ $grainY -eq $lastRow ]
		then
			count=$(( count + 1 ))
			eval "map_${grainX}_${grainY}=o"

			if [ $grainX -eq 500 ] && [ $grainY -eq 0 ]
			then
				return $true
			fi

			grainX=500
			grainY=0
			continue
		fi

		newY=$(( grainY + 1 ))
		eval "field=\$map_${grainX}_${newY}"
		if [ -z "$field" ]
		then
			grainY=$newY
			continue
		fi

		newX=$(( grainX - 1 ))
		eval "field=\$map_${newX}_${newY}"
		if [ -z "$field" ]
		then
			grainX=$newX
			grainY=$newY
			continue
		fi

		newX=$(( grainX + 1 ))
		eval "field=\$map_${newX}_${newY}"
		if [ -z "$field" ]
		then
			grainX=$newX
			grainY=$newY
			continue
		fi

		count=$(( count + 1 ))
		eval "map_${grainX}_${grainY}=o"

		if [ $grainX -eq 500 ] && [ $grainY -eq 0 ]
		then
			return $true
		fi

		grainX=500
		grainY=0
	done
}


produceSand

echo "Units: $count"
