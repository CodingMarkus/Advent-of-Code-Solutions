#!/bin/sh

# Run as:
# cat advent_08_sample.txt | sh advent_08.sh
# cat advent_08_input.txt  | sh advent_08.sh

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


y=0
tree=0
while [ $y -lt $rows ]
do
	x=0
	maxInRow=-1
	while [ $x -lt $cols ]
	do
		eval "tree=\$trees_${y}_${x}"
		if [ $tree -gt $maxInRow ]
		then
			maxInRow=$tree
			eval "visibleTrees_${y}_${x}=1"
		fi
		x=$(( x + 1 ))
	done

	x=$cols
	maxInRow=-1
	while [ $x -gt 0 ]
	do
		x=$(( x - 1 ))
		eval "tree=\$trees_${y}_${x}"
		if [ $tree -gt $maxInRow ]
		then
			maxInRow=$tree
			eval "visibleTrees_${y}_${x}=1"
		fi
	done

	y=$(( y + 1 ))
done


x=0
tree=0
while [ $x -lt $cols ]
do
	y=0
	maxInCol=-1
	while [ $y -lt $rows ]
	do
		eval "tree=\$trees_${y}_${x}"
		if [ $tree -gt $maxInCol ]
		then
			maxInCol=$tree
			eval "visibleTrees_${y}_${x}=1"
		fi
		y=$(( y + 1 ))
	done

	y=$rows
	maxInCol=-1
	while [ $y -gt 0 ]
	do
		y=$(( y - 1 ))
		eval "tree=\$trees_${y}_${x}"
		if [ $tree -gt $maxInCol ]
		then
			maxInCol=$tree
			eval "visibleTrees_${y}_${x}=1"
		fi
	done

	x=$(( x + 1 ))
done


echo "Visible trees: $(set | grep -c visibleTrees_ )"