#!/bin/sh

# Run as:
# cat advent_02_2_input.txt | sh advent_02_2.sh

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
		A) return $rock;;
		B) return $paper;;
		C) return $scissor;;
		*) echo "Error"; exit 1;;
	esac
}


getMatchScore()
{
	# $1 = outcome, $2 = other
	case $1 in
		X) case $2 in
			"$rock") return $(( scissor + loss ));;
			"$paper") return $(( rock + loss ));;
			"$scissor") return $(( paper + loss ));;
		esac;;

		Y) return $(( draw + $2 ));;

		Z) case $2 in
			"$rock") return $(( paper + win ));;
			"$paper") return $(( scissor + win ));;
			"$scissor") return $(( rock + win ));;
		esac;;
	esac
}


score=0
while read -r line
do
	other=0
	for choice in $line
	do
		case $choice in
			A|B|C) decode "$choice" ; other=$?;;
			X|Y|Z) getMatchScore "$choice" "$other"; score=$(( score + $? ));;
			*) echo "Error"; exit 1;;
		esac
	done
done

echo "Score: $score"