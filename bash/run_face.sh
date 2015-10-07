#!/bin/bash

# Run experiment stage of SoyFACE climate change simulations.
# Usage example: $(./bash/run_face.sh "facetest_" facesims)
# produces a directory named "facesims", containing results from
# four runs named "facetest_ctrl", "facetest_co2", "facetest_heat",
# "facetest_heatco2"
# See run_spin.sh for more complete notes/warnings about each step.

schedbase="../schedules/face_"
trtary=(ctrl co2 heat heatco2)
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
ln -sf ../differing_100s/face_fix.100 fix.100
ln -sf ../differing_100s/ag_soyface.100 soyface.100
ln -sf ../differing_100s/face_outfiles.in outfiles.in
ln -sf ../differing_100s/face_outvars.txt outvars.txt
ln -sf ../differing_100s/ag_sitepar.in sitepar.in
ln -sf ../differing_100s/ag_soils.in soils.in
ln -sf ../weather/sfdm01_11.wth sfdm01_11.wth
ln -sf ../weather/tminscale.dat tminscale.dat
ln -sf ../weather/tmaxscale.dat tmaxscale.dat

# Link in binary from ag run. Edit if names change!
ln -sf  ../out_ag/ag1.bin ag.bin

for trt in ${trtary[*]}; do
	echo "Treatment $trt" | tee -a  "$runname".log

	# Run model
	time DailyDayCent \
		-s "$schedbase$trt".sch \
		-n "$runname$trt" \
		-e ag.bin \
		2>&1 | tee -a "$runname".log

	# Convert daily output
	../bash/out2csv.sh -a -d "$trt" "$dirname"_ outfiles.in

	# Extract & convert monthly output
	DailyDayCent_list100 "$runname$trt" "binmonthly" outvars.txt
	echo "1 binmonthly.lis" > outfiles_tmp.txt
	../bash/out2csv.sh -a -d "$trt" "$dirname"_ outfiles_tmp.txt
	rm outfiles_tmp.txt
done

# Now some plots
lisvars=($(< outvars.txt))
Rscript ../R/plotlis.R "$dirname"_binmonthly.csv ${lisvars[@]}


