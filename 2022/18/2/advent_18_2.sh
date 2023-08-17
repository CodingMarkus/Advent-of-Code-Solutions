#!/bin/sh

# Solution to https://adventofcode.com/2022/day/18

# Run as:
# cat advent_18_2_sample.txt | sh advent_18_2.sh
# cat advent_18_2_input.txt  | sh advent_18_2.sh

set -e

# Avoid negative numbers
readonly offset=10

xMin=$offset
xMax=0
yMin=$offset
yMax=0
zMin=$offset
zMax=0

count=0

IFS=','
while read -r x y z
do
	x=$(( x + offset ))
	y=$(( y + offset ))
	z=$(( z + offset ))

	eval "d_${x}_${y}_${z}=1"

	[ "$x" -lt "$xMin" ] && xMin=$x
	[ "$x" -gt "$xMax" ] && xMax=$x

	[ "$y" -lt "$yMin" ] && yMin=$y
	[ "$y" -gt "$yMax" ] && yMax=$y

	[ "$z" -lt "$zMin" ] && zMin=$z
	[ "$z" -gt "$zMax" ] && zMax=$z

	count=$(( count + 1 ))
done
unset IFS


xMin=$(( xMin - 1 ))
xMax=$(( xMax + 1 ))
yMin=$(( yMin - 1 ))
yMax=$(( yMax + 1 ))
zMin=$(( zMin - 1 ))
zMax=$(( zMax + 1 ))


readonly true=0
readonly false=1

hasDrop( )
{
	eval "d=\$d_${1}_${2}_${3}"
	[ -z "$d" ] && return $false
	return $true
}

setVisited( )
{
	eval "v_${1}_${2}_${3}=1"
}


haveVisited( )
{
	eval "v=\$v_${1}_${2}_${3}"
	[ -z "$v" ] && return $false
	return $true
}


area=0

checkLeft( )
{
	newX=$(( $1 - 1 ))
	[ $newX -lt $xMin ] && return $false
	haveVisited $newX "$2" "$3" && return $false
	hasDrop $newX "$2" "$3" && { area=$(( area + 1 )); return $false; }
	return $true
}


checkRight()
{
	newX=$(( $1 + 1 ))
	[ $newX -gt $xMax ] && return $false
	haveVisited $newX "$2" "$3" && return $false
	hasDrop $newX "$2" "$3" && { area=$(( area + 1 )); return $false; }
	return $true
}


checkUp( )
{
	newY=$(( $2 + 1 ))
	[ $newY -gt $yMax ] && return $false
	haveVisited $1 $newY "$3" && return $false
	hasDrop  $1 $newY "$3" && { area=$(( area + 1 )); return $false; }
	return $true
}


checkDown( )
{
	newY=$(( $2 - 1 ))
	[ $newY -lt $yMin ] && return $false
	haveVisited $1 $newY "$3" && return $false
	hasDrop  $1 $newY "$3" && { area=$(( area + 1 )); return $false; }
	return $true
}


checkForward( )
{
	newZ=$(( $3 + 1 ))
	[ $newZ -gt $zMax ] && return $false
	haveVisited $1 $2 $newZ && return $false
	hasDrop  $1 $2 $newZ && { area=$(( area + 1 )); return $false; }
	return $true
}


checkBackward( )
{
	newZ=$(( $3 - 1 ))
	[ $newZ -lt $zMin ] && return $false
	haveVisited $1 $2 $newZ && return $false
	hasDrop  $1 $2 $newZ && { area=$(( area + 1 )); return $false; }
	return $true
}


inspectMe="$xMin,$yMin,$zMin"

while [ -n "$inspectMe" ]
do
	newInspectMe=

	for block in $inspectMe
	do
		x=${block%%,*}
		yz=${block#*,}
		y=${yz%,*}
		z=${yz#*,}

		if checkLeft "$x" "$y" "$z"
		then
			newInspectMe="$newInspectMe $(( x - 1 )),$y,$z"
			setVisited $((  x - 1 )) "$y" "$z"
		fi

		if checkRight "$x" "$y" "$z"
		then
			newInspectMe="$newInspectMe $(( x + 1 )),$y,$z"
			setVisited $(( x + 1 )) "$y" "$z"
		fi

		if checkUp "$x" "$y" "$z"
		then
			newInspectMe="$newInspectMe $x,$(( y + 1 )),$z"
			setVisited "$x" $(( y + 1 )) "$z"
		fi

		if checkDown "$x" "$y" "$z"
		then
			newInspectMe="$newInspectMe $x,$(( y - 1 )),$z"
			setVisited "$x" $(( y - 1 )) "$z"
		fi

		if checkForward "$x" "$y" "$z"
		then
			newInspectMe="$newInspectMe $x,$y,$(( z + 1 ))"
			setVisited "$x" "$y" $(( z + 1 ))
		fi

		if checkBackward "$x" "$y" "$z"
		then
			newInspectMe="$newInspectMe $x,$y,$(( z - 1 ))"
			setVisited "$x" "$y" $(( z - 1 ))
		fi

	done

	inspectMe=$newInspectMe

done


echo "Surface area: $area"
