#!/bin/sh

# Solution to https://adventofcode.com/2022/day/7

# Run as:
# cat advent_07_2_sample.txt | sh advent_07_2.sh
# cat advent_07_2_input.txt  | sh advent_07_2.sh

set -e

tmp=$( mktemp -d )
currentDir=$( pwd )
cd "$tmp"

trap 'cd "$currentDir" ; rm -rf "$tmp"' EXIT


sumFileSizes()
{
	sum=0
	for f in *
	do
		if [ -d "$f" ]
		then
			sum=$(( sum + $( cd "$f" ; sumFileSizes ) ))
		else
			sum=$(( sum + $( cat "$f" ) ))
		fi
	done
	printf '%s' "$sum"
}


while read -r line
do
	case $line in
		"$ cd /") cd "$tmp";;

		"$ cd "*)
			dirname="${line#"$ cd "}"
			[ -d "$dirname" ] || mkdir "$dirname"
			cd "$dirname"
			;;

		[0-9][0-9]*)
			filename=${line##[0-9][0-9]* }
			filesize=${line%"$filename"}
			printf "%s" "$filesize" >"$filename"
			;;

		"$ ls"|"dir "*) ;;

		*) echo "Error ($line)"; exit 1;;
	esac
done

readonly totalSize=70000000
readonly sizeRequired=30000000

cd "$tmp"
sizeInUse=$( sumFileSizes )
sizeMissing=$(( sizeRequired - ( totalSize - sizeInUse ) ))


smallestSum=$totalSize
for d in $( find . -type d )
do
	sum=$( cd "$d"; sumFileSizes )
	if [ "$sum" -ge "$sizeMissing" ] && [ "$sum" -lt "$smallestSum" ]
	then
		smallestSum=$sum
	fi
done

echo "Best dir size: $smallestSum"
