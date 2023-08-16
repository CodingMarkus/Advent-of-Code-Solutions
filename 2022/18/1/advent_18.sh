#!/bin/sh

# Solution to https://adventofcode.com/2022/day/18

# Run as:
# cat advent_18_sample.txt | sh advent_18.sh
# cat advent_18_input.txt  | sh advent_18.sh

set -e

count=0

IFS=','
while read -r x y z
do
	eval "dx_$count=$x"
	eval "dy_$count=$y"
	eval "dz_$count=$z"
	eval "d_${x}_${y}_${z}=1"
	count=$(( count + 1 ))
done
unset IFS

area=0

check( )
{
	[ "$1" -lt 0 ] && { area=$(( area + 1 )); return; }
	[ "$2" -lt 0 ] && { area=$(( area + 1 )); return; }
	[ "$3" -lt 0 ] && { area=$(( area + 1 )); return; }

	eval "drop=\$d_${1}_${2}_${3}"
	[ -n "$drop" ] && return
	area=$(( area + 1 ))
}

idx=0
while [ $idx -lt $count ]
do
	eval "x=\$dx_$idx"
	eval "y=\$dy_$idx"
	eval "z=\$dz_$idx"

	check $(( x - 1 )) $y $z
	check $(( x + 1 )) $y $z

	check $x $(( y - 1 )) $z
	check $x $(( y + 1 )) $z

	check $x $y $(( z - 1 ))
	check $x $y $(( z + 1 ))

	idx=$(( idx + 1 ))
done

echo "Surface area: $area"