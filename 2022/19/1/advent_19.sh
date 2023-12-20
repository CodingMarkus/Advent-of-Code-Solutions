#!/bin/sh

# Solution to https://adventofcode.com/2022/day/19

# Run as:
# cat advent_19_sample.txt | sh advent_19.sh
# cat advent_19_input.txt  | sh advent_19.sh

set -e

# Parse input data

captNum='\([[:digit:]]\{1,\}\)'
pattern="Blueprint $captNum:"
pattern="$pattern Each ore robot costs $captNum ore."
pattern="$pattern Each clay robot costs $captNum ore."
pattern="$pattern Each obsidian robot costs $captNum ore and $captNum clay."
pattern="$pattern Each geode robot costs $captNum ore and $captNum obsidian."

allBlueprints=

while read -r line
do
	argc=1
	for n in $( printf '%s' "$line" | sed "s/$pattern/\1 \2 \3 \4 \5 \6 \7/")
	do
		case $argc in
			1) bp=$n; allBlueprints="$allBlueprints $n";;
			2) eval "bp_${bp}_costOreR=$n";;
			3) eval "bp_${bp}_costClayR=$n";;
			4) eval "bp_${bp}_costObsR_ore=$n";;
			5) eval "bp_${bp}_costObsR_clay=$n";;
			6) eval "bp_${bp}_costGeoR_ore=$n";;
			7) eval "bp_${bp}_costGeoR_obs=$n";;
			*) ;;
		esac
		argc=$(( argc + 1 ))
	done
done


# Setup global state

blueprint=0

costOreR=0
costClayR=0
costObsR_ore=0
costObsR_clay=0
costGeoR_ore=0
costGeoR_obs=0

maxOreR=0
maxClayR=0
maxObsR=0

activateBlueprint()
{
	bp=$1
	eval "costOreR=\$bp_${bp}_costOreR"
	eval "costClayR=\$bp_${bp}_costClayR"
	eval "costObsR_ore=\$bp_${bp}_costObsR_ore"
	eval "costObsR_clay=\$bp_${bp}_costObsR_clay"
	eval "costGeoR_ore=\$bp_${bp}_costGeoR_ore"
	eval "costGeoR_obs=\$bp_${bp}_costGeoR_obs"

	# It makes no sense to build more robots than what we can consume
	maxOreR=$costOreR
	[ $maxOreR -lt $costClayR ] && maxOreR=$costClayR
	[ $maxOreR -lt $costObsR_ore ] && maxOreR=$costObsR_ore
	[ $maxOreR -lt $costGeoR_ore ] && maxOreR=$costGeoR_ore
	maxClayR=$costObsR_clay
	maxObsR=$costGeoR_obs
}


bestGeo=0
buildTime=0

# Backtracking

# $1 cntGeo
# $2 cntGeoR
# $3 timeRem
# $4 newTimRem
stopEarly()
{
	[ $bestGeo = 0 ] && return 1
	# Very coarse estimation!
	maxGeo=$(( $1 + ($2 * $3) + ($4 * ($4 + 1) / 2) ))
	[ $bestGeo -ge $maxGeo ] && return 0
	return 1
}


# $1 cntOre
# $2 cntClay
# $3 cntObs
# $4 cntGeo
# $5 cntOreR
# $6 cntClayR
# $7 cntObsR
# $8 cntGeoR
# $9 timeRem
buildSomething()
{
	if [ "$7" -gt 0 ]
	then
		if [ "$1" -ge $costGeoR_ore ]; then bt1=1
		else
			bt1=$(( 1 + (
				($5 - 1 + costGeoR_ore - $1) / $5) ))
		fi

		if [ "$3" -ge $costGeoR_obs ]; then bt2=1
		else
			bt2=$(( 1 + (
				($7 - 1 + costGeoR_obs - $3) / $7 ) ))
		fi

		if [ $bt1 -gt $bt2 ]; then buildTime=$bt1
			else buildTime=$bt2; fi

		if [ $buildTime -ge "$9" ]
		then
			finalGeo=$(( $4 + ($8 * $9) ))
			[ $bestGeo -lt $finalGeo ] && bestGeo=$finalGeo
		else
			newTimeRem=$(( $9 - buildTime ))

			if [ $buildTime -eq 1 ]
			then
				stopEarly "$4" "$8" "$9" $newTimeRem && return 0
				buildSomething \
					$(( $1 + $5 - costGeoR_ore )) \
					$(( $2 + $6  )) \
					$(( $3 + $7 - costGeoR_obs )) \
					$(( $4 + $8 )) \
					"$5" "$6" "$7" $(( $8 + 1 )) $newTimeRem
				# If we can build geo robot in one turn,
				# there is no better option!
				return 0

			else
				stopEarly "$4" "$8" "$9" $newTimeRem || \
					buildSomething \
						$(( $1 + ($5 * buildTime) - costGeoR_ore )) \
						$(( $2 + ($6 * buildTime) )) \
						$(( $3 + ($7 * buildTime) - costGeoR_obs )) \
						$(( $4 + ($8 * buildTime) )) \
						"$5" "$6" "$7" $(( $8 + 1 )) $newTimeRem
			fi
		fi
	fi

	if  [ "$9" -ge 4 ]
	then

		if  [ "$7" -lt $maxObsR ] && [ "$6" -gt 0 ]
		then
			if [  "$1" -ge $costObsR_ore ]; then bt1=1
			else
				bt1=$(( 1 + (
					($5 - 1 + costObsR_ore - $1) / $5) ))
			fi

			if [ "$2" -ge $costObsR_clay ]; then bt2=1
			else
				bt2=$(( 1 + (
					($6 - 1 + costObsR_clay - $2) / $6)
				))
			fi

			if [ $bt1 -gt $bt2 ]; then buildTime=$bt1
				else buildTime=$bt2; fi

			if [ $buildTime -ge "$9" ]
			then
				finalGeo=$(( $4 + ($8 * $9) ))
				[ $bestGeo -lt $finalGeo ] && bestGeo=$finalGeo
			else
				newTimeRem=$(( $9 - buildTime ))
				stopEarly "$4" "$8" "$9" $newTimeRem || \
					buildSomething \
						$(( $1 + ($5 * buildTime) - costObsR_ore )) \
						$(( $2 + ($6 * buildTime) - costObsR_clay)) \
						$(( $3 + ($7 * buildTime) )) \
						$(( $4 + ($8 * buildTime) )) \
						"$5" "$6" $(( $7 + 1 )) "$8" $newTimeRem
			fi
		fi


		if [ "$9" -ge 6 ] && [ "$6" -lt $maxClayR ] && [ "$7" -lt $maxObsR ]
		then
			if [ "$1" -ge $costClayR ]; then buildTime=1
			else
				buildTime=$(( 1 + (
					($5 - 1 + costClayR - $1) / $5) ))
			fi

			if [ $buildTime -ge "$9" ]
			then
				finalGeo=$(( $4 + ($8 * $9) ))
				[ $bestGeo -lt $finalGeo ] && bestGeo=$finalGeo
			else
				newTimeRem=$(( $9 - buildTime ))
				stopEarly "$4" "$8" "$9" $newTimeRem || \
					buildSomething \
						$(( $1 + ($5 * buildTime) - costClayR )) \
						$(( $2 + ($6 * buildTime) )) \
						$(( $3 + ($7 * buildTime) )) \
						$(( $4 + ($8 * buildTime) )) \
						"$5" $(( $6 + 1 )) "$7" "$8" $newTimeRem
			fi
		fi


		if [ "$5" -lt $maxOreR ]
		then
			if [ "$1" -ge $costOreR ]; then buildTime=1
			else
				buildTime=$(( 1 + (
					($5 - 1 + costOreR - $1) / $5) ))
			fi

			if [ $buildTime -ge "$9" ]
			then
				finalGeo=$(( $4 + ($8 * $9) ))
				[ $bestGeo -lt $finalGeo ] && bestGeo=$finalGeo
			else
				newTimeRem=$(( $9 - buildTime ))
				stopEarly "$4" "$8" "$9" $newTimeRem || \
					buildSomething \
						$(( $1 + ($5 * buildTime) - costOreR )) \
						$(( $2 + ($6 * buildTime) )) \
						$(( $3 + ($7 * buildTime) )) \
						$(( $4 + ($8 * buildTime) )) \
						$(( $5 + 1 )) "$6" "$7" "$8" $newTimeRem
			fi
		fi

	fi

	return 0
}


qualitySum=0

for blueprint in $allBlueprints
do
	bestGeo=0
	activateBlueprint "$blueprint"
	buildSomething 0 0 0 0 1 0 0 0 24

	qualitySum=$(( qualitySum + (bestGeo * blueprint) ))
done

echo "Sum of quality levels: $qualitySum"
