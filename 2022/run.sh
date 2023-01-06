#!/bin/sh

syntaxError()
{
	echo "
Syntax:

	run.sh <day> <part> [sample]

E.g.:

	run.sh 12 1 [sample|input]

Day must be 1 to 25, part must be either 1 or 2.

If part is followed by the optional parameter \"sample\", then only the sample
calculation is peformed. If it is followed by \"input\", then only the puzzle
input calculation is performed.
" >&2
	exit 1
}

if [ $# -ne 2 ] && [ $# -ne 3 ]
then
	syntaxError
fi

then
	syntaxError
fi

day=$1
part=$2

data=
[ $# -eq 3 ] && data=$3

if [ "$day" -lt 1 ] || [ "$day" -gt 25 ]
then
	syntaxError
fi

if [ "$part" -lt 1 ] || [ "$part" -gt 2 ]
then
	syntaxError
fi

if [ "$day" -lt 10 ] && [ ${#day} -eq 1 ]
then
	day="0$day"
fi

case $data in
	''|'sample'|'input') ;;
	*) syntaxError
esac

cd "$(dirname "$0" )/$day/$part" || { echo "cd error" >&2; exit 1; }

if [ "$part" -eq 2 ]
then
	part="_2"
else
	part=
fi

echo
echo "Calculated:"
echo
sh "advent_$day${part}.sh" < "advent_$day${part}_sample.txt"
if [ -z "$sample" ]
then
	sh "advent_$day${part}.sh" < "advent_$day${part}_input.txt"
fi
echo
echo "Expected:"
echo
cat "advent_$day${part}_expected.txt"
echo