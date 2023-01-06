#!/bin/sh

# Solution to https://adventofcode.com/2022/day/7

# Run as:
# cat advent_07_sample.txt | sh advent_07.sh
# cat advent_07_input.txt  | sh advent_07.sh

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

sum=0

cd "$tmp"
for d in $( find . -type d )
do
	add=$(
		cd "$d"
		dirSize=$( sumFileSizes )
		[ "$dirSize" -gt  100000 ] && dirSize=0
		printf '%s' "$dirSize"
	)
	sum=$(( sum + add ))
done

echo "Sum: $sum"