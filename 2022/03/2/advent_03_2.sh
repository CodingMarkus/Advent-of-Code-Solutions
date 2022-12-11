#!/bin/sh

# Run as:
# cat advent_03_2_sample.txt | sh advent_03_2.sh
# cat advent_03_2_input.txt  | sh advent_03_2.sh

set -e

filterForDupes()
{
	printf "%s" "$1" | tr -C -d "$2" | tr -s "$1"
}


getItems()
{
	while read -r line
	do
		if [ -z "$m1" ]
		then
			m1=$line
		elif  [ -z "$m2" ]
		then
			m2=$line
		elif [ -z "$m3" ]
		then
			m3=$line
			m12=$(filterForDupes "$m1" "$m2")
			filterForDupes "$m3" "$m12"
			printf "\n"
			m1=
			m2=
			m3=
		fi
	done
	[ -z "$m1" ] || { echo "Error m1"; exit 1; }
	[ -z "$m2" ] || { echo "Error m2"; exit 1; }
	[ -z "$m3" ] || { echo "Error m3"; exit 1; }
}


ord()
{
  LC_CTYPE=C printf '%d' "'$1"
}


sum=0
for item in $( getItems )
do
	ordVal=$( ord "$item" )
	if [ "$ordVal" -ge 97 ] && [ "$ordVal" -le 122 ]
	then
		sum=$(( sum + ordVal - 96 ))
	elif [ "$ordVal" -ge 65 ] && [ "$ordVal" -le 90 ]
	then
		sum=$(( sum + ordVal - 64 + 26 ))
	else
		echo "Error"
		exit 1
	fi
done
echo "Sum: $sum"