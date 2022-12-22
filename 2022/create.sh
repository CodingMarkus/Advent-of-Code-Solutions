#!/bin/sh

syntaxError()
{
	echo "
Syntax:

	create.sh <day>

E.g.:

	create.sh 12

Day must be 1 to 25.
" >&2
	exit 1
}

if [ $# -ne 1 ]
then
	syntaxError
fi

day=$1

if [ "$day" -lt 1 ] || [ "$day" -gt 25 ]
then
	syntaxError
fi

if [ "$day" -lt 10 ] && [ ${#day} -eq 1 ]
then
	day="0$day"
fi

dir="$(dirname "$0" )/$day"
if [ -e "$dir" ]
then
	echo "Day $day already exists." >&2
	exit 1
fi


mkdir -p "$dir"
cd "$dir" || { echo "cd error" >&2; exit 1; }

mkdir "1" "2"

touch "1/advent_${day}_expected.txt"
touch "1/advent_${day}_input.txt"
touch "1/advent_${day}_sample.txt"

touch "2/advent_${day}_2_expected.txt"
touch "2/advent_${day}_2_input.txt"
touch "2/advent_${day}_2_sample.txt"


script="#!/bin/sh

# Solution to https://adventofcode.com/2022/day/${day}

# Run as:
# cat advent_${day}_sample.txt | sh advent_${day}.sh
# cat advent_${day}_input.txt  | sh advent_${day}.sh

set -e
"
printf "%s" "$script" >"1/advent_${day}.sh"


script="#!/bin/sh

# Solution to https://adventofcode.com/2022/day/${day}

# Run as:
# cat advent_${day}_2_sample.txt | sh advent_${day}_2.sh
# cat advent_${day}_2_input.txt  | sh advent_${day}_2.sh

set -e
"
printf "%s" "$script" >"2/advent_${day}_2.sh"
