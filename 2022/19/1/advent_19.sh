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

readonly totalTime=24

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

readonly oreR=1
readonly clayR=2
readonly obsR=3
readonly geoR=4

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


cntOre=0
cntClay=0
cntObs=0
cntGeo=0

cntOreR=0
cntClayR=0
cntObsR=0
cntGeoR=0

bestGeo=0
timeRem=$totalTime

reset()
{
	cntOre=0
	cntClay=0
	cntObs=0
	cntGeo=0

	cntOreR=1
	cntClayR=0
	cntObsR=0
	cntGeoR=0

	bestGeo=0
	timeRem=$totalTime
}


# Brute Force

sp=0
buildSomething()
{
	if [ $bestGeo -gt 0 ]
	then
		maxGeoPos=$((
			cntGeo + (timeRem * cntGeoR) + (timeRem * (timeRem + 1) / 2) ))
		[ $bestGeo -ge $maxGeoPos ] && return 0
	fi

	buildNext=

	if [ $cntObsR -gt 0 ]
	then
		buildNext=$geoR
	fi

	if  [ $timeRem -ge 4 ] && [ $cntObsR -lt $maxObsR ] && [ $cntClayR -gt 0 ]
	then
		buildNext="$buildNext $obsR"
	fi

	if [ $timeRem -ge 6 ] && [ $cntClayR -lt $maxClayR ]
	then
		buildNext="$buildNext $clayR"
	fi

	if [ $timeRem -ge 4 ] && [ $cntOreR -lt $maxOreR ]
	then
		buildNext="$buildNext $oreR"
	fi

	if [ -z "$buildNext" ]
	then
		finalGeo=$(( cntGeo + (cntGeoR * timeRem) ))
		[ $bestGeo -lt $finalGeo ] && bestGeo=$finalGeo
		return 0
	fi

	for build in $buildNext
	do
		buildTime=0
		case $build in
			"$oreR")
				if [ $cntOre -ge $costOreR ]; then buildTime=1
				else
					buildTime=$((
						1 + (
							(cntOreR - 1 + costOreR - cntOre) / cntOreR
						)
					))
				fi
			;;

			"$clayR")
				if [ $cntOre -ge $costClayR ]; then buildTime=1
				else
					buildTime=$(( 1 + (
						(cntOreR - 1 + costClayR - cntOre) / cntOreR) ))
				fi
			;;

			"$obsR")
				if [ $cntOre -ge $costObsR_ore ]; then bt1=1
				else
					bt1=$(( 1 + (
						(cntOreR - 1 + costObsR_ore - cntOre) / cntOreR) ))
				fi

				if [ $cntClay -ge $costObsR_clay ]; then bt2=1
				else
					bt2=$(( 1 + (
						(cntClayR - 1 + costObsR_clay - cntClay) / cntClayR)
					))
				fi

				if [ $bt1 -gt $bt2 ]; then buildTime=$bt1
					else buildTime=$bt2; fi
			;;

			"$geoR")
				if [ $cntOre -ge $costGeoR_ore ]; then bt1=1
				else
					bt1=$(( 1 + (
						(cntOreR - 1 + costGeoR_ore - cntOre) / cntOreR) ))
				fi

				if [ $cntObs -ge $costGeoR_obs ]
				then
					bt2=1
				else
					bt2=$(( 1 + (
						(cntObsR - 1 + costGeoR_obs - cntObs) / cntObsR ) ))
				fi

				if [ $bt1 -gt $bt2 ]; then buildTime=$bt1
					else buildTime=$bt2; fi
			;;
		esac

		if [ $buildTime -ge $timeRem ]
		then
			finalGeo=$(( cntGeo + (cntGeoR * timeRem) ))
			[ $bestGeo -lt $finalGeo ] && bestGeo=$finalGeo

		else
			eval "stack${sp}_cntOre=$cntOre"
			eval "stack${sp}_cntClay=$cntClay"
			eval "stack${sp}_cntObs=$cntObs"
			eval "stack${sp}_cntGeo=$cntGeo"
			eval "stack${sp}_cntOreR=$cntOreR"
			eval "stack${sp}_cntClayR=$cntClayR"
			eval "stack${sp}_cntObsR=$cntObsR"
			eval "stack${sp}_cntGeoR=$cntGeoR"
			eval "stack${sp}_timeRem=$timeRem"
			sp=$(( sp + 1 ))

			timeRem=$(( timeRem - buildTime ))
			cntOre=$(( cntOre + (cntOreR * buildTime) ))
			cntClay=$(( cntClay + (cntClayR * buildTime) ))
			cntObs=$(( cntObs + (cntObsR * buildTime) ))
			cntGeo=$(( cntGeo + (cntGeoR * buildTime) ))

			case $build in
				"$oreR")
					cntOreR=$(( cntOreR + 1 ))
					cntOre=$(( cntOre - costOreR ))
				;;

				"$clayR")
					cntClayR=$(( cntClayR + 1 ))
					cntOre=$(( cntOre - costClayR ))
				;;

				"$obsR")
					cntObsR=$(( cntObsR + 1 ))
					cntOre=$(( cntOre - costObsR_ore ))
					cntClay=$(( cntClay - costObsR_clay ))
				;;

				"$geoR")
					cntGeoR=$(( cntGeoR + 1 ))
					cntOre=$(( cntOre - costGeoR_ore ))
					cntObs=$(( cntObs - costGeoR_obs ))
				;;
			esac

			if [ $timeRem -lt 2 ]
			then
				finalGeo=$(( cntGeo + (cntGeoR * timeRem) ))
				[ $bestGeo -lt $finalGeo ] && bestGeo=$finalGeo
			else
				buildSomething
			fi

			sp=$(( sp - 1 ))
			eval "cntOre=\$stack${sp}_cntOre"
			eval "cntClay=\$stack${sp}_cntClay"
			eval "cntObs=\$stack${sp}_cntObs"
			eval "cntGeo=\$stack${sp}_cntGeo"
			eval "cntOreR=\$stack${sp}_cntOreR"
			eval "cntClayR=\$stack${sp}_cntClayR"
			eval "cntObsR=\$stack${sp}_cntObsR"
			eval "cntGeoR=\$stack${sp}_cntGeoR"
			eval "timeRem=\$stack${sp}_timeRem"
		fi
	done
	return 0
}


qualitySum=0


for blueprint in $allBlueprints
do
	activateBlueprint "$blueprint"
	reset
	buildSomething

	qualitySum=$(( qualitySum + (bestGeo * blueprint) ))
done

echo "Sum of quality levels: $qualitySum"