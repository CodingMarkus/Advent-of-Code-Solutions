#!/bin/sh

# Solution to https://adventofcode.com/2022/day/17

# Run as:
# cat advent_17_2_sample.txt | sh advent_17_2.sh
# cat advent_17_2_input.txt  | sh advent_17_2.sh

set -e

rock1="
####
"

rock2="
.#.
###
.#.
"

rock3="
..#
..#
###
"

rock4="
#
#
#
#
"

rock5="
##
##
"

spCount=0

makeSprite()
{
	# $1=rock
	width=0
	height=$(( $( printf '%s' "$1" | wc -l ) - 1 ))

	rock=$( printf '%s' "$1" | sed 's/[^.#]//g' | sed 's/[.]*$//g' )

	y=$(( height - 1 ))
	for line in $rock
	do
		[ ${#line} -gt "$width" ] && width=${#line}

		x=0
		for char in $( printf '%s' "$line" | sed 's/\(.\)/\1 /g')
		do
			case $char in
				.) ;;
				"#") eval "sp_${spCount}_${y}_${x}=1" ;;
				*) echo "Bad char"; exit 1
			esac
			x=$(( x + 1 ))
		done

		y=$(( y  - 1 ))
	done

	eval "sp_${spCount}_width=\$width"
	eval "sp_${spCount}_height=\$height"

	spCount=$(( spCount + 1 ))
}


makeSprite "$rock1"
makeSprite "$rock2"
makeSprite "$rock3"
makeSprite "$rock4"
makeSprite "$rock5"


instCount=0
# shellcheck disable=2034,2013
for inst in $( sed 's/\(.\)/\1 /g' )
do
	eval "inst_$instCount=\$inst"
	instCount=$(( instCount + 1 ))
done


readonly true=0
readonly false=1

instIdx=0

readonly totalRocks=1000000000000
rocksLeft=$totalRocks


playfieldHeight=0
readonly playfieldWidth=7

readonly newRockStartXOffset=2
readonly newRockStartYOffset=3

spX=0
spY=0
spWidth=0
spHeight=0
spIdx=$(( spCount - 1 ))



# Write all height differences to file for pattern detection

tmp=$( mktemp -d )
currentDir=$( pwd )
cd "$tmp"

trap 'cd "$currentDir" ; rm -rf "$tmp"' EXIT


pattern=
patternPrefix=

lastHeight=0
patternFound=$false
patternFile="heights.txt"

readonly checkPatternEvery=2000
nextPatternCheckIn=$checkPatternEvery

checkForPattern( )
{
	diff=$(( playfieldHeight - lastHeight ))
	printf "%s" "$diff" >>"$patternFile"
	lastHeight=$playfieldHeight

	nextPatternCheckIn=$(( nextPatternCheckIn - 1 ))
	[ $nextPatternCheckIn -le 0 ] || return $true
	nextPatternCheckIn=$checkPatternEvery

	grep -q '\(.\{20,\}\)\(\1\)\{2\}' "$patternFile" || return $true

	patternFound=$true
	return $false
}


nextRock()
{
	checkForPattern || return $false
	[ $rocksLeft -gt 0 ] || return $false
	rocksLeft=$(( rocksLeft - 1 ))

	spIdx=$(( (spIdx + 1) % spCount ))
	spX=$newRockStartXOffset
	spY=$(( playfieldHeight + newRockStartYOffset ))
	eval "spWidth=\$sp_${spIdx}_width"
	eval "spHeight=\$sp_${spIdx}_height"

	return $true
}



checkForCollision()
{
	x=0
	while [ $x -lt $spWidth ]
	do
		y=0
		while [ $y -lt $spHeight ]
		do
			eval "s=\$sp_${spIdx}_${y}_${x}"
			if [ -n "$s" ]
			then
				xPlay=$(( spX + x ))
				yPlay=$(( spY + y ))
				eval "p=\$play_${yPlay}_${xPlay}"
				[ -z "$p" ] || return $true
			fi
			y=$(( y + 1 ))
		done

		x=$(( x + 1 ))
	done

	return $false
}



goLeft()
{
	[ $spX -le 0 ] && return
	spX=$(( spX - 1 ))
	if checkForCollision
	then
		spX=$(( spX + 1 ))
	fi
}



goRight()
{
	[ $(( spX + spWidth )) -ge $playfieldWidth ] && return
	spX=$(( spX + 1 ))
	if checkForCollision
	then
		spX=$(( spX - 1 ))
	fi
}


lastCleanedLine=0

stampSprite()
{
	x=0
	while [ $x -lt $spWidth ]
	do
		y=0
		while [ $y -lt $spHeight ]
		do
			eval "s=\$sp_${spIdx}_${y}_${x}"
			if [ -n "$s" ]
			then
				xPlay=$(( spX + x ))
				yPlay=$(( spY + y ))
				eval "play_${yPlay}_${xPlay}=1"
			fi
			y=$(( y + 1 ))
		done

		x=$(( x + 1 ))
	done

	spMaxHeight=$(( spY + spHeight ))
	[ $spMaxHeight -gt $playfieldHeight ] && playfieldHeight=$spMaxHeight

	nextRock || return $false

	if [ $(( playfieldHeight - lastCleanedLine )) -gt 150 ]
	then
		while [ $(( playfieldHeight - lastCleanedLine )) -gt 50 ]
		do
			x=0
			while [ $x -lt $playfieldWidth ]
			do
				eval "unset play_${lastCleanedLine}_${x}"
				x=$(( x + 1 ))
			done
			lastCleanedLine=$(( lastCleanedLine + 1 ))
		done
	fi

	return $true
}


goDown()
{
	if [ $spY -le 0 ]
	then
		stampSprite || return $false
		return $true
	fi

	spY=$(( spY - 1 ))
	if checkForCollision
	then
		spY=$(( spY + 1 ))
		stampSprite || return $false
		return $true
	fi

	return $true
}


nextRock
while true
do
	eval "inst=\$inst_$instIdx"
	case $inst in
		"<") goLeft ;;
		">") goRight ;;
		*) echo "Bad pattern instruction $inst"; exit 1
	esac

	goDown || break

	instIdx=$(( (instIdx + 1) % instCount ))

done

if [ $patternFound -eq $false ]
then
	echo "Size of tower in units: $playfieldHeight"
	exit 0
fi

pattern=$( sed -n 's/.*\(.\{20,\}\)\(\1\)\{2\}/\1/p' "$patternFile" )
prefix=$( awk '{ sub("'"$pattern"'.*", ""); print }' "$patternFile" )


calcHeight( )
(
	sum=0
	for x in $( printf '%s' "$1" | sed 's/\(.\)/\1 /g' )
	do
		sum=$(( sum + x ))
	done
	printf "%s" "$sum"
)


prefixHeight=$( calcHeight "$prefix" )
patternHeight=$( calcHeight "$pattern" )

prefixCount=$(( $( printf '%s' "$prefix" | wc -c ) + 0 ))
patternCount=$(( $( printf '%s' "$pattern" | wc -c ) + 0 ))


playfieldHeight=$prefixHeight
# + 1 as the first prefix value is the value before the first rock!
rocksLeft=$(( totalRocks - prefixCount + 1 ))

fullPatterns=$(( rocksLeft / patternCount ))
rocksLeft=$(( rocksLeft - (patternCount * fullPatterns) ))
playfieldHeight=$(( playfieldHeight + (patternHeight * fullPatterns) ))

suffix=$( printf '%s' "$pattern" | head -c "$rocksLeft" )
suffixHeight=$( calcHeight "$suffix" )
playfieldHeight=$(( playfieldHeight + suffixHeight ))

echo "Size of tower in units: $playfieldHeight"
