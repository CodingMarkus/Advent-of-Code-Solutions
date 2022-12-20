#!/bin/sh

# Solution to https://adventofcode.com/2022/day/13

# Run as:
# cat advent_13_sample.txt | sh advent_13.sh
# cat advent_13_input.txt  | sh advent_13.sh

set -e

index=0
indexSum=0

readonly true=0
readonly false=1

convertList()
{
	# $1 - List
	printf '%s' "$1" | tr ',' ' ' \
	    | sed 's/\([][]\)/ \1 /g' \
	    | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//'
}


pop()
{
	# $1 - Name of list to pop from
	# $2 - Name of the var to pop to
	eval "oldList=\$$1"
	# shellcheck disable=SC2034,SC2154  # Used/set in eval
	newList=${oldList#* }
	# shellcheck disable=SC2034 # Used in eval
	outItem=${oldList%"$newList"}
	eval "$2="'${outItem% }'
	eval "$1"'=$newList'
}


push()
{
	# $1 - Name of list to fush to
	# $2 - Item to push
	eval "$1=\"$2\$$1\""
}


isInt()
{
	case $1 in
		*[!0-9]*) return $false;;
		'') return $false;;
		*) return $true;;
	esac
}


listsAreInOrder()
{
	while true
	do
		pop "listA" "left"
		pop "listB" "right"

		if [ -z "$left" ]
		then
			[ -n "$right" ] && return $true
			return $false
		fi
		[ -z "$right" ] && return $false

		[ "$left" = "$right" ] && continue;

		{ [ "$left" = '[' ] &&  [ "$right" = ']' ]; } && return $false
		{ [ "$left" = ']' ] &&  [ "$right" = '[' ] ; } && return $true

		leftIsInt=$true
		isInt "$left" || leftIsInt=$false

		rightIsInt=$true
		isInt "$right" || rightIsInt=$false

		if [ $leftIsInt -eq $true ]
		then
			if [ $rightIsInt -eq $true ]
			then
				[ "$left" -lt "$right" ] && return $true
				return $false
			fi

			[ "$right" = ']' ] && return $false

			push "listA" "[ $left ] "
			push "listB" '[ '
			continue
		fi

		[ "$left" = ']' ] && return $true

		push "listA" '[ '
		push "listB" "[ $right ] "
	done
}


process()
{
	index=$(( index + 1 ))
	# shellcheck disable=SC2034
	listA=$( convertList "$1" )
	# shellcheck disable=SC2034
	listB=$( convertList "$2" )
	! listsAreInOrder || indexSum=$(( indexSum + index ))
}


list1=
list2=
while read -r line
do
	if [ -z "$line" ]
	then
		if [ -n "$list1" ]
		then
			echo "Eror: Blank line not separating two lists"
			exit 1
		fi
	elif [ -z "$list1" ]
	then
		list1=$line
	elif [ -z "$list2" ]
	then
		list2=$line
		process "$list1" "$list2"
		list1=
		list2=
	else
		echo "Error: Missing blank line between two lists"
		exit 1
	fi
done

if [ -n "$list1" ] && [ -z "$list2" ]
then
	echo "Error: Uneven number of lists"
	exit 1
fi

echo "Sum is: $indexSum"