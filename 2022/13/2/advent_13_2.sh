#!/bin/sh

# Solution to https://adventofcode.com/2022/day/13

# Run as:
# cat advent_13_2_sample.txt | sh advent_13_2.sh
# cat advent_13_2_input.txt  | sh advent_13_2.sh

set -e

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


divider1="[ [ 2 ] ]"
divider2="[ [ 6 ] ]"

# shellcheck disable=SC2034 # Used when sorting
lists_0=$divider1
# shellcheck disable=SC2034 # Used when sorting
lists_1=$divider2

index=2
while read -r line
do
	[ -z "$line" ] && continue
	# shellcheck disable=SC2034 # Used in eval
	list=$( convertList "$line" )
	eval "lists_$index"'=$list'
	index=$(( index + 1 ))
done
count=$index



sortStack=

popStack()
{
	if [ -z "$sortStack" ]
	then
		eval "$1="
		return
	fi

	newSortStack=${sortStack% *}
	# shellcheck disable=SC2034 # Used in eval
	lastElement=${sortStack#"$newSortStack"}
	sortStack=$newSortStack
	eval "$1"'=$(( lastElement + 0 ))'
}


pushStack()
{
	sortStack="$sortStack $1"
}


swap()
{
	eval "swapTmp=\$lists_$1"
	eval "lists_$1=\$lists_$2"
	eval "lists_$2=\$swapTmp"
}


listAndPivotAreInOrder()
{
	eval "listA=\$lists_$1"
	listB=$2
	# shellcheck disable=SC2154
	[ "$listA" = "$listB" ] && return $false
	listsAreInOrder || return $false
}


pivotAndListAreInOrder()
{
	listA=$1
	eval "listB=\$lists_$2"
	# shellcheck disable=SC2154
	[ "$listA" = "$listB" ] && return $false
	listsAreInOrder || return $false
}



quicksort()
{
	l=0
	r=$(( count - 1 ))
	outer=$true

	while [ $outer -eq $true ]
	do
		while [ $l -lt $r ]
		do
			p=$(( (l + r) / 2 ))
			eval "pivot=\$lists_$p"
			pushStack $r
			m=$l

			inner=$true
			while [ $inner -eq $true ]
			do
				# shellcheck disable=SC2154
				while listAndPivotAreInOrder $m "$pivot"
				do
					m=$(( m + 1 ))
				done

				while pivotAndListAreInOrder "$pivot" $r
				do
					r=$(( r - 1 ))
				done

				[ $m -ge $r ] && { inner=$false; break; }

				swap $m $r
			done
		done
		l=$(( r + 1 ))
		popStack "r"
		[ -z "$r" ] && { outer=$false; break; }
	done
}

quicksort

key=1
index=0
while [ $index -lt $count ]
do
	eval "item=\$lists_$index"
	index=$(( index + 1 ))
	# shellcheck disable=SC2154 # Item is assinged in eval
	if [ "$item" = "$divider1" ] || [ "$item" = "$divider2" ]
	then
		key=$(( key * index  ))
	fi

done

echo "Decoder key: $key"