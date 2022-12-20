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

lowest=0

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
		[ "$y" -gt "$lowest" ] && lowest="$y"
		xpos=$x
		ypos=$y
	done
	xpos=
	ypos=
done
lastRow=$(( lowest + 1 ))


readonly true=0
count=0

produceSand()
{
	backtraceStackCount=2
	# shellcheck disable=SC2034 # Used by eval below
	backtraceStack_1=500
	# shellcheck disable=SC2034 # Used by eval below
	backtraceStack_2=0

	while true
	do
		[ $backtraceStackCount -eq 0 ] && return $true

		eval "grainY=\$backtraceStack_${backtraceStackCount}"
		backtraceStackCount=$(( backtraceStackCount - 1 ))
		eval "grainX=\$backtraceStack_${backtraceStackCount}"
		backtraceStackCount=$(( backtraceStackCount - 1 ))

		while true
		do
			if [ "$grainY" -lt $lastRow ]
			then
				newY=$(( grainY + 1 ))
				eval "loc=\$map_${grainX}_${newY}"
				# shellcheck disable=SC2154 # Assigned in eval above
				if [ ${#loc} -eq 0 ]
				then
					backtraceStackCount=$(( backtraceStackCount + 1 ))
					eval "backtraceStack_${backtraceStackCount}=\$grainX"
					backtraceStackCount=$(( backtraceStackCount + 1 ))
					eval "backtraceStack_${backtraceStackCount}=\$grainY"
					grainY=$newY
					continue
				fi

				newX=$(( grainX - 1 ))
				eval "loc=\$map_${newX}_${newY}"
				if [ ${#loc} -eq 0 ]f
				then
					backtraceStackCount=$(( backtraceStackCount + 1 ))
					eval "backtraceStack_${backtraceStackCount}=\$grainX"
					backtraceStackCount=$(( backtraceStackCount + 1 ))
					eval "backtraceStack_${backtraceStackCount}=\$grainY"
					grainX=$newX
					grainY=$newY
					continue
				fi

				newX=$(( grainX + 1 ))
				eval "loc=\$map_${newX}_${newY}"
				if [ ${#loc} -eq 0 ]
				then
					backtraceStackCount=$(( backtraceStackCount + 1 ))
					eval "backtraceStack_${backtraceStackCount}=\$grainX"
					backtraceStackCount=$(( backtraceStackCount + 1 ))
					eval "backtraceStack_${backtraceStackCount}=\$grainY"
					grainX=$newX
					grainY=$newY
					continue
				fi
			fi
			count=$(( count + 1 ))
			eval "map_${grainX}_${grainY}='o'"
			break
		done
	done
}


produceSand

echo "Units: $count"
