#!/bin/sh

set -e

syntaxError()
{
	echo "
Syntax:

	run.sh <day> <part> [sample]

	run.sh all

E.g.:

	run.sh 12 1 [sample|input]

Day must be 1 to 25, part must be either 1 or 2.

If part is followed by the optional parameter \"sample\", then only the sample
calculation is peformed. If it is followed by \"input\", then only the puzzle
input calculation is performed.

If calculations match expectations, the exit code is 0, otherwise it is 1.

If day is \"all\" then all days and all parts available are executed.
" >&2
	exit 1
}


if [ $# -eq 1 ] && [ "$1" = all ]
then
	runCMD=$0
	for day in *
	do
		case $day in *[!0-9]*) continue ; esac
		[ -d "$day" ] || continue

		echo "Running day $day, part 1"
		"$runCMD" "$day" 1 || true

		echo

		echo "Running day $day, part 2"
		"$runCMD" "$day" 2 || true

		echo
		echo
	done
	exit 0
fi


if [ $# -ne 2 ] && [ $# -ne 3 ]
then
	syntaxError
fi

day=$1
part=$2

data=
[ $# -eq 3 ] && data=$3


isInteger()
{
	case $1 in ''|*[!0-9]*) return 1; esac
	return 0
}


if ! isInteger "$day" || [ "$day" -lt 1 ] || [ "$day" -gt 25 ]
then
	syntaxError
fi

if  ! isInteger "$part" || [ "$part" -lt 1 ] || [ "$part" -gt 2 ]
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

newline=$( printf '\n_' )
readonly newline="${newline%_}"

tmp=$( mktemp -d )
readonly tmp
trap 'rm -rf "$tmp"' EXIT

readonly timeFile="$tmp/runtime"

resultOK=1
expected=$( cat "advent_$day${part}_expected.txt" )

# The build-in time command of zsh doesn't even know the -p option.
# The build-in time command of bash only changes the output format but
# doesn't print the results to stderr.
# The POSIX standard mandates -p to be known and it also explicitely requires
# times to be printed in a given format to stderr if that option is used!
timeCMD="/usr/bin/time"

if [ -z "$data" ] || [ "$data" = "sample" ]
then
	scriptFile="advent_$day${part}.sh"
	inputFile="advent_$day${part}_sample.txt"
	sampleRes=$( "$timeCMD" -p sh "$scriptFile" <"$inputFile" 2>"$timeFile" )

	sampleTime=$( grep '^real' "$timeFile" | cut -d ' ' -f 2 )
	echo "Processing sample data took $sampleTime seconds."

	case $expected in
		"${sampleRes}${newline}"*) ;;
		*) resultOK=0
	esac
else
	sampleRes="--- n/a ---"
fi

if [ -z "$data" ] || [ "$data" = "input" ]
then
	scriptFile="advent_$day${part}.sh"
	inputFile="advent_$day${part}_input.txt"
	inputRes=$( "$timeCMD" -p sh "$scriptFile" <"$inputFile" 2>"$timeFile" )

	inputTime=$( grep '^real' "$timeFile" | cut -d ' ' -f 2 )
	echo "Processing input data took $inputTime seconds."

	case $expected in
		*"${newline}${inputRes}"*) ;;
		*) resultOK=0
	esac
else
	inputRes="--- n/a ---"
fi


if [ $resultOK -eq 0 ]
then
	echo "Bad result!"

	echo
	echo "Calculated:"
	echo
	printf '%s\n' "$sampleRes"
	printf '%s\n' "$inputRes"

	echo
	echo "Expected:"
	echo
	printf '%s\n' "$expected"
	echo
	exit 1
fi
