#!/bin/bash

# Run spinup stage of SoyFACE climate change simulations.
# Usage example: $(./bash/run_spinup.sh spin_test spin)
# This sets the output to land in a directory named "spin",
# creates it if it doesn't exist,
# link in all required parameter files,
# runs the simulation with all outputs named "spin_test",
# and plots diagnostics.

runname=$1
if [ $2 ]; then
	dirname=$2
else
	dirname=$runname
fi
mkdir -p $dirname
cd $dirname
if [ -e "$runname".bin ]; then
	echo 'Error: '"$runname"'.bin already exists!'
	exit 1
fi

# Link in Daycent parameters
# Beware: overwrites any existing .100 files in $dirname/!
ln -sf ../common_100s/* .
ln -sf ../differing_100s/spin_fix.100 fix.100
ln -sf ../differing_100s/spin_soyface.100 soyface.100
ln -sf ../differing_100s/spin_outfiles.in outfiles.in
ln -sf ../differing_100s/spin_outvars.txt outvars.txt
ln -sf ../differing_100s/spin_sitepar.in sitepar.in
ln -sf ../differing_100s/spin_soils.in soils.in

# Randomize order of years in weather file,
# but keep days of each year together
Rscript ../R/weather-shuffler.r ../weather/cu.wth cushuf.wth

# Run the model, report time spent, capture output to log.
time DailyDayCent -s ../schedules/spin.sch -n $runname 2>&1 | tee -a $runname.log

# Convert any daily output files to CSV, for easier analysis...
# ...and ~50% smaller files!
# N.B. Some .out files have weird headers--see notes/outfile-headers.txt.
# We don't fix those here, we just turn them from invalid
# space-delimited headers into invalid CSV headers.
../bash/out2csv.sh -a -d $runname "$dirname"_ outfiles.in

# Extract variables of interest from monthly binary file.
# The arguments are confusing:
# 	First: input.bin, specified WITHOUT the .bin,
#	Second: output.lis, specified WITHOUT the .lis,
# 	Third: vars_to_extract.txt, specified INCLUDING the .txt
DailyDayCent_list100 $runname "binmonthly" outvars.txt

# Convert list100 output to CSV, with help from a fake outfiles.in.
echo "1 binmonthly.lis" > outfiles_tmp.txt
../bash/out2csv.sh -a -d $runname "$dirname"_ outfiles_tmp.txt
rm outfiles_tmp.txt

# OK, let's plot some diagnostics.
lisvars=($(< outvars.txt))
Rscript ../R/plotlis.r "$dirname"_binmonthly.csv ${lisvars[@]}
