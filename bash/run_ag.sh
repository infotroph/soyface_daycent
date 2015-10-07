#!/bin/bash

# Run historical agriculture stage of SoyFACE climate change simulations.
# Usage example: $(./run_ag.sh ag_test aghistory)
# See run_spin.sh for more complete notes/warnings about each step.

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
ln -sf ../differing_100s/ag_fix.100 fix.100
ln -sf ../differing_100s/ag_soyface.100 soyface.100
ln -sf ../differing_100s/ag_outfiles.in outfiles.in
ln -sf ../differing_100s/ag_outvars.txt outvars.txt
ln -sf ../differing_100s/ag_sitepar.in sitepar.in
ln -sf ../differing_100s/ag_soils.in soils.in

# Link in binary from spinup run. Edit if spinup names change!
ln -sf  ../spin/spin1.bin spin.bin

# Randomize order of years in first weather file,
# but keep days of each year together
Rscript ../R/weather-shuffler.r ../weather/cu.wth cushuf.wth

# Second weather file is not shuffled
ln -sf ../weather/cu.wth cu.wth

# Run the model, report time spent, capture output to log.
time DailyDayCent -s ../schedules/ag.sch -n $runname -e spin.bin 2>&1 | tee -a $runname.log

# Convert daily output files to CSV
../bash/out2csv.sh -a -d $runname "$dirname"_ outfiles.in

# Extract variables of interest from monthly binary file, convert to CSV
DailyDayCent_list100 $runname "binmonthly" outvars.txt
echo "1 binmonthly.lis" > outfiles_tmp.txt
../bash/out2csv.sh -a -d $runname "$dirname"_ outfiles_tmp.txt
rm outfiles_tmp.txt

# Plot output & diagnostics
lisvars=($(< outvars.txt))
Rscript ../R/plotlis.r "$dirname"_binmonthly.csv ${lisvars[@]}
Rscript ../R/cn-vs-targ.R "$dirname"_binmonthly.csv
Rscript ../R/harvest-vs-nass.R "$dirname"_harvest.csv
