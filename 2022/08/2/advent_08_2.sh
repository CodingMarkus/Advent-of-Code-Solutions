#!/bin/sh

# Run as:
# cat advent_08_2_sample.txt | sh advent_08_2.sh
# cat advent_08_2_input.txt  | sh advent_08_2.sh

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


res=0
highestScore=0
lastCol=$(( cols - 1 ))
lastRow=$(( rows - 1 ))

y=1
while [ $y -lt $lastRow ]
do
	x=1
	while [ $x -lt $lastCol ]
	do
		score=0

		xtree=$x
		ytree=$y
		height=0

		eval "height=\$trees_${ytree}_${xtree}"

		# Left
		cnt=1
		xtest=$(( xtree - 1 ))
		ytest=$ytree
		while [ $xtest -gt 0 ]
		do
			eval "res=\$trees_${ytest}_${xtest}"
			[ $res -lt "$height" ] || break
			cnt=$(( cnt + 1 ))
			xtest=$(( xtest - 1 ))
		done
		score=$cnt

		# Right
		cnt=1
		xtest=$(( xtree + 1 ))
		ytest=$ytree
		while [ $xtest -lt $lastCol ]
		do
			eval "res=\$trees_${ytest}_${xtest}"
			[ $res -lt "$height" ] || break
			cnt=$(( cnt + 1 ))
			xtest=$(( xtest + 1 ))
		done
		score=$(( score * cnt ))

		# Top
		cnt=1
		xtest=$xtree
		ytest=$(( ytree - 1 ))
		while [ $ytest -gt 0 ]
		do
			eval "res=\$trees_${ytest}_${xtest}"
			[ $res -lt "$height" ] || break
			cnt=$(( cnt + 1 ))
			ytest=$(( ytest - 1 ))
		done
		score=$(( score * cnt ))

		# Bottom
		cnt=1
		xtest=$xtree
		ytest=$(( ytree + 1 ))
		while [ $ytest -lt $lastRow ]
		do
			eval "res=\$trees_${ytest}_${xtest}"
			[ $res -lt "$height" ] || break
			cnt=$(( cnt + 1 ))
			ytest=$(( ytest + 1 ))
		done
		score=$(( score * cnt ))

		# s=$( getScore $x $y )
		[ $score -gt $highestScore ] && highestScore=$score
		x=$(( x + 1 ))
	done
	y=$(( y + 1 ))
done

echo "Highest score: $highestScore"