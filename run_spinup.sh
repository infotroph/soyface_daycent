#!/bin/bash

# Run spinup stage of SoyFACE climate change simulations.
# Usage example: $(./run_spinup.sh spin_test spin)
# This sets the output to land in a directory named "spin",
# creates it if it doesn't exist,
# link in all required parameter files,
# runs the simulation with all outputs named "spin_test",
# and plots diagnostics.

runname=$1
schedfile='../schedules/spin.sch'
weatherin='../weather/cu.wth'
weatherout='cushuf.wth' # Name must match weather file used in schedfile.

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
# Beware: overwrites any existing versions of these files!
ln -sf ../common_100s/* .

ln -sf ../run_specific/spin_fix.100 fix.100
ln -sf ../run_specific/spin_soyface.100 soyface.100
ln -sf ../run_specific/spin_outfiles.in outfiles.in
ln -sf ../run_specific/spin_outvars.txt outvars.txt
ln -sf ../run_specific/spin_sitepar.in sitepar.in
ln -sf ../run_specific/spin_soils.in soils.in

# Randomize order of years in weather file,
# but keep days of each year together
Rscript ../R/weather-shuffler.r $weatherin $weatherout

# Run the model, report time spent, capture output to log.
time DailyDayCent -s $schedfile -n $runname 2>&1 | tee -a $runname.log

# Extract variables of interest from binary file.
# The arguments are confusing:
# 	First: input.bin, specified WITHOUT the .bin,
#	Second: output.lis, specified WITHOUT the .lis,
# 	Third: vars_to_extract.txt, specified INCLUDING the .txt
DailyDayCent_list100 $runname $runname outvars.txt

# Convert list100 output to CSV, with help from a fake outfiles.in.
echo "1 $runname.lis" > "$runname"_outfiles_tmp.txt
../bash/out2csv.sh -a -d $runname $dirname "$runname"_outfiles_tmp.txt
rm "$runname"_outfiles_tmp.txt

# Convert any daily output files to CSV as well.
# N.B. Some .out files have weird headers--see notes/outfile-headers.txt.
# We don't fix those here, we just turn them from invalid
# space-delimited headers into invalid CSV headers.
../bash/out2csv.sh -a -d $runname $dirname outfiles.in

# OK, let's plot some diagnostics.
Rscript ../R/plotlis.r "$dirname".csv somtc som3c som2c.2. somte.1. somse.1. tminrl.1. cproda aglivc stdedc agcprd bgcjprd bgcmprd som2e.1.1. som2e.2.1. som3e.1. stream.2. stream.5. stream.6.


