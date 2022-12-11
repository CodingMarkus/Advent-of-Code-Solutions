#!/bin/sh

# Run as:
# cat advent_03_sample.txt | sh advent_03.sh
# cat advent_03_input.txt  | sh advent_03.sh

set -e

getItems()
{
	while read -r line
	do
		lineLen=${#line}
		halfLineLen=$(( lineLen / 2 ))
		comp1=$( printf '%s' "$line" | head -c $halfLineLen )
		comp2=${line#"$comp1"}
		printf "%s" "$comp2" | tr -C -d "$comp1"
		printf "\n"
	done
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