#!/bin/sh

# Run as:
# cat advent_08_2_input.txt | sh advent_08_2.sh

set -e

while read -r line
do
	allLines="$allLines${line}_"
done

x=0
y=0
cols=0
tree=0

for tree in $( printf '%s' "$allLines" | sed 's/\(.\)/\1 /g' )
do
	if [ "$tree" = _ ]
	then
		cols=$x
		x=0
		y=$(( y + 1 ))
	else
		eval "trees_${y}_${x}=$tree"
		x=$(( x + 1 ))
	fi
done

rows=$y


getHeight()
{
	res=0
	eval "res=\$trees_${2}_${1}"
	printf '%s' "$res"
}

lastCol=$(( cols - 1 ))
lastRow=$(( rows - 1 ))

getScore()
{
	xtree=$1
	ytree=$2
	finalScore=0
	height=$( getHeight "$xtree" "$ytree" )

	# Left
	cnt=1
	xtest=$(( xtree - 1 ))
	ytest=$ytree
	while [ $xtest -gt 0 ]
	do
		[ "$( getHeight "$xtest" "$ytest" )" -lt "$height" ] || break
		cnt=$(( cnt + 1 ))
		xtest=$(( xtest - 1 ))
	done
	finalScore=$cnt

	# Right
	cnt=1
	xtest=$(( xtree + 1 ))
	ytest=$ytree
	while [ $xtest -lt $lastCol ]
	do
		[ "$( getHeight "$xtest" "$ytest" )" -lt "$height" ] || break
		cnt=$(( cnt + 1 ))
		xtest=$(( xtest + 1 ))
	done
	finalScore=$(( finalScore * cnt ))

	# Top
	cnt=1
	xtest=$xtree
	ytest=$(( ytree - 1 ))
	while [ $ytest -gt 0 ]
	do
		[ "$( getHeight "$xtest" "$ytest" )" -lt "$height" ] || break
		cnt=$(( cnt + 1 ))
		ytest=$(( ytest - 1 ))
	done
	finalScore=$(( finalScore * cnt ))

	# Bottom
	cnt=1
	xtest=$xtree
	ytest=$(( ytree + 1 ))
	while [ $ytest -lt $lastRow ]
	do
		[ "$( getHeight "$xtest" "$ytest" )" -lt "$height" ] || break
		cnt=$(( cnt + 1 ))
		ytest=$(( ytest + 1 ))
	done
	finalScore=$(( finalScore * cnt ))

	printf '%s' $finalScore
}


score=0

y=1
while [ $y -lt $lastCol ]
do
	x=1
	while [ $x -lt $lastRow ]
	do
		s=$( getScore $x $y )
		[ "$s" -gt $score ] && score=$s
		x=$(( x + 1 ))
	done
	y=$(( y + 1 ))
done

echo "Highest score: $score"