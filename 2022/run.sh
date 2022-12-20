#!/bin/sh

syntaxError()
{
	echo "
Syntax:

	run.sh <day> <part> [sample]

E.g.:

	run.sh 12 1 [sample]

Day must be 1 to 25, part must be either 1 or 2.

If part is followed by the optional parameter \"sample\",
then only the sample calculation is peformed.
" >&2
	exit 1
}

if [ $# -ne 2 ] && [ $# -ne 3 ]
then
	syntaxError
fi

if [ $# -eq 3 ] && [ "$3" != "sample" ]
then
	syntaxError
fi

day=$1
part=$2
sample=$3

if [ "$day" -lt 1 ] || [ "$day" -gt 25 ]
then
	syntaxError
fi

if [ "$part" -lt 1 ] || [ "$part" -gt 2 ]
then
	syntaxError
fi

if [ "$part" -lt 10 ] && [ ${#day} -eq 1 ]
then
	day="0$day"
fi

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