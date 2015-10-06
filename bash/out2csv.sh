#!/bin/bash

usage="
Usage: out2csv.sh [-a|-e|-o] [-d] runname prefix outfiles.in
For full help: out2csv.sh -h"

help="
      Convert Daycent output files from space-delimited ASCII to CSV.

$usage

Required arguments:
 	runname: String to be added to a \"run\" column at the beginning of each
 		line of the output csv.

	prefix: String to be added to the beginning of each CSV's filename.

	outfiles.in: A list of files to convert, in the same format as DayCent's
		\"outfiles.in\".

	N.B. You probably only want to run this script from a directory that
		contains input and output files from exactly one Daycent run, feeding
		it the same runname you used in the run script and the same
		outfiles.in you had DayCent use for the run you're converting. Any
		other arrangement will likely produce... surprises.

Options:
	Flags -aeo are mutually exclusive and all control behavior when <file>.csv
	exists already. If it does not exist, it is always created.

	-a	Append. Skips header line, then adds the rest of <file>.out to the end
		of an existing <file>.csv. Overrides -o if both are present.

	-e	Error. Exit with an error if file already exists. This is the default
		behavior, and it overrides -a and -o if both are present.
	-o	Overwrite. Replace existing <file>.csv with contents of <file>.out.

	-d Delete original files after converting. Default is to not delete.

	-h Show this help."


## 1. Process arguments:

(( $# )) || { printf '%s\n' "$usage" && exit 1; }

while getopts "aoedh" OPT; do
	case $OPT in
		e) error=true;;
		a) append=true;;
		o) overwrite=true;;
		d) postdelete=true;;
		h) printf '%s\n' "$help"
			exit 0;;
		*) echo "$usage"
			exit 1;;
	esac
done
shift $(( $OPTIND - 1 ))

runname=$1;
prefix=$2
infile=$3

if [ $error ]; then
	unset append
	unset overwrite
fi

if [ $append ]; then
	unset overwrite
fi

if [ ! $append ] && [ ! $overwrite ]; then
	error=true
fi


## 2. Predefine some sed operations:

# Remove headers, probably to append output to an existing CSV. This is
# trickier than it sounds.
# Files differ in header length (0-2 lines)
#	=> can't remove a fixed number of lines.
# Data lines are 'numeric' but may contain some letters, e.g "1.03E-05".
# 	=> Can't assume letters = header.
# Current approach: assume any line that BEGINS with letters (possibly after
#	a space) is a header.
killhead='/^ *[a-zA-Z]/d;'

# watrbal.out has a weird extra first-line header:
# "0=(swc1-swc2)...", which doesn't start with a letter
# and which we never want even when keeping other headers.
# ==> Drop this if it exists.
killwbalhead='/^0=\(swc1-swc2\)/d;'

# To each header (or at least "begins with a letter") line,
# Add a column to be filled with the name of the current run.
addrunhead='/^ *[a-zA-Z]/ s/^ */run,/;'

# Add the name of the current run to the beginning of
# each non-header (or at least "begins with a non-letter") line.
addrunname='/^ *[a-zA-Z]/! s/^ */'"$runname"',/;'

# Wrap double quotes around fields with pre-existing commas,
# so they aren't treated as field separators
# when reading the CSV later.
protectcomma='s/([^ ]+,[^ ]+)/"\1"/g;'

# Remove trailing whitespace or commas,
# to prevent empty CSV columns.
killtrailing='s/[ ,]+$//;'

# Remove lines that are empty or all whitespace.
killempty='/^ *$/d;'

# Convert all runs of spaces to a single comma delimiter.
# Fun fact: This one conversion usually cuts the filesize in half!
spacetocomma='s/ +/,/g;'


## 3. Time to convert some files!

while read -a f; do # reading from input file
	if ((${f[0]}!=1)); then continue; fi # skip files disabled in DayCent run
	outfile="$prefix${f[1]%%.*}".csv
	if [ $error ] && [ -e "$outfile" ]; then
		echo "Error: $outfile already exists!"
		exit 1
	else
		echo "converting ${f[1]}"
	fi
	if [ $overwrite ] && [ -e "$outfile" ]; then
		> "$outfile" # truncates existing file to length zero.
	fi
	if [ $append ] && [ -e "$outfile" ]; then
		headerop='1,2 {'"$killwbalhead $killhead"'}'
	else
		headerop='1,2 {'"$killwbalhead $addrunhead"'};'
	fi
	if test ${f[1]:(-3)} = "csv"; then # dc_sip.csv, harvest.csv
		sed -E \
			-e "$headerop" \
			-e "$killempty" \
			-e "$addrunname" \
			-e "$killtrailing" \
			${f[1]} >> "$outfile"
	else
	    sed -E \
	    	-e '1,2 {'"$protectcomma"'};' \
	    	-e "$headerop" \
			-e "$killempty" \
			-e "$addrunname" \
			-e "$killtrailing" \
			-e "$spacetocomma" \
			${f[1]} >> "$outfile"
	fi
	if [ $postdelete ]; then
		rm ${f[1]}
	fi
done < $infile
