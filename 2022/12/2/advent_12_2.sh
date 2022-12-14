#!/bin/sh

# Solution to https://adventofcode.com/2022/day/12

# Run as:
# cat advent_12_2_sample.txt | sh advent_12_2.sh
# cat advent_12_2_input.txt  | sh advent_12_2.sh

set -e

ord()
{
  LC_CTYPE=C printf '%d' "'$1"
}


ordA=$( ord a )
convertToHeight()
{
	case $1 in
		[a-z]) o=$( ord "$1" ); return $(( o + 1 - ordA));;
		S) return 1;;
		E) return 26;;
		*) echo "Erorr: bad height ($1)"; exit 1;;
	esac
}


maxX=0
maxY=0
destX=0
destY=0

xpos=0
ypos=0
while read -r line
do
	for value in $( printf '%s' "$line" |  sed 's/\(.\)/\1 /g' )
	do
		if [ "$value" = "E" ]
		then
			destX=$xpos
			destY=$ypos
		fi

		convertToHeight "$value" || height=$?
		eval "map_${xpos}_${ypos}=$height"
		xpos=$(( xpos + 1 ))
	done
	maxX=$(( xpos - 1 ))
	xpos=0
	ypos=$(( ypos + 1 ))
done
maxY=$(( ypos - 1 ))


getHeight()
{
	eval "return \$map_${1}_${2}"
}


readonly true=0
readonly false=1


setVisited()
{
	eval "visited_${1}_${2}=$true"
}


haveVisited()
{
	eval "visited=\$visited_${1}_${2}"
	[ -z "$visited" ] && visited=$false
	return "$visited"
}


canGoLeft()
{
	[ "$1" -eq 0 ] && return $false
	haveVisited $(( $1 - 1 )) "$2" && return $false
	getHeight "$1" "$2" || h1=$?
	getHeight $(( $1 - 1 )) "$2" || h2=$?
	[ $(( h2 < h1 ? h1 - h2 : 0 )) -le 1 ] && return $true
	return $false
}


canGoRight()
{
	[ "$1" -eq $maxX ] && return $false
	haveVisited $(( $1 + 1 )) "$2" && return $false
	getHeight "$1" "$2" || h1=$?
	getHeight $(( $1 + 1 )) "$2" || h2=$?
	[ $(( h2 < h1 ? h1 - h2 : 0 )) -le 1 ] && return $true
	return $false
}


canGoUp()
{
	[ "$2" -eq 0 ] && return $false
	haveVisited "$1" $(( $2 - 1 )) && return $false
	getHeight "$1" "$2" || h1=$?
	getHeight "$1" $(( $2 - 1 )) || h2=$?
	[ $(( h2 < h1 ? h1 - h2 : 0 )) -le 1 ] && return $true
	return $false
}


canGoDown()
{
	[ "$2" -eq $maxY ] && return $false
	haveVisited "$1" $(( $2 + 1 )) && return $false
	getHeight "$1" "$2" || h1=$?
	getHeight "$1" $(( $2 + 1 )) || h2=$?
	[ $(( h2 < h1 ? h1 - h2 : 0 )) -le 1 ] && return $true
	return $false
}


steps=0
inspectMe="$destX,$destY"
setVisited "$destX" "$destY"

while [ -n "$inspectMe" ]
do
	newInspectMe=

	for coord in $inspectMe
	do
		xpos=${coord%,*}
		ypos=${coord#*,}

		eval "height=\$map_${xpos}_${ypos}"
		if [ "$height" -eq 1 ]
		then
			echo "Steps: $steps"
			exit 0
		fi

		if canGoLeft "$xpos" "$ypos"
		then
			newInspectMe="$newInspectMe $(( xpos - 1 )),$ypos"
			setVisited $(( xpos - 1 )) "$ypos"
		fi

		if canGoRight "$xpos" "$ypos"
		then
			newInspectMe="$newInspectMe $(( xpos + 1 )),$ypos"
			setVisited $(( xpos + 1 )) "$ypos"
		fi

		if canGoUp "$xpos" "$ypos"
		then
			newInspectMe="$newInspectMe $xpos,$(( ypos - 1 ))"
			setVisited "$xpos" $(( ypos - 1 ))
		fi

		if canGoDown "$xpos" "$ypos"
		then
			newInspectMe="$newInspectMe $xpos,$(( ypos + 1 ))"
			setVisited "$xpos" $(( ypos + 1 ))
		fi
	done

	steps=$(( steps + 1 ))
	inspectMe=$newInspectMe

done

echo "No path found"
exit 1
