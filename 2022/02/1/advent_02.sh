#!/bin/sh

# Run as:
# cat advent_02_input.txt | sh advent_02.sh

set -e

readonly rock=1
readonly paper=2
readonly scissor=3

readonly win=6
readonly draw=3
readonly loss=0

decode()
{
	case $1 in
		A|X) return $rock;;
		B|Y) return $paper;;
		C|Z) return $scissor;;
		*) echo "Error"; exit 1;;
	esac
}


getMatchScore()
{
	# $1 = me, $2 = other
	[ "$1" = "$2" ] && return $draw
	[ "$1" = "$rock" ] &&  [ "$2" = "$paper" ] && return $loss
	[ "$1" = "$paper" ] &&  [ "$2" = "$scissor" ] && return $loss
	[ "$1" = "$scissor" ] &&  [ "$2" = "$rock" ] && return $loss
	return $win
}


score=0
while read -r line
do
	me=0
	other=0
	for choice in $line
	do
		decode "$choice"
		case $choice in
			A|B|C) other=$?;;
			X|Y|Z) me=$?; score=$(( score + me ));;
			*) echo "Error"; exit 1;;
		esac
	done
	getMatchScore "$me" "$other"
	score=$(( score + $? ))
done

echo "Score: $score"