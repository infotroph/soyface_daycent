
COMMONDEPS = \
	common_100s/* \
	bash/out2csv.sh

SPINDEPS = \
	differing_100s/spin_* \
	weather/cu.wth \
	schedules/spin.sch

AGDEPS = \
	differing_100s/ag_* \
	weather/cu.wth \
	schedules/ag.sch \
	out_spin/spin1.bin

FACEDEPS = \
	differing_100s/face_* \
	differing_100s/ag_soyface.100 \
	differing_100s/ag_sitepar.in \
	differing_100s/ag_soils.in \
	weather/sfdm01_11.wth \
	weather/tminscale.dat \
	weather/tmaxscale.dat \
	schedules/face_* \
	out_ag/ag1.bin

all: spin ag face plots

out_spin/spin1.bin: $(COMMONDEPS) $(SPINDEPS) R/weather-shuffler.R bash/run_spinup.sh
	./bash/run_spinup.sh spin1 out_spin

out_ag/ag1.bin: $(COMMONDEPS) $(AGDEPS) R/weather-shuffler.R bash/run_ag.sh
	./bash/run_ag.sh ag1 out_ag

out_face/out_facectrl.bin: $(COMMONDEPS) $(FACEDEPS) bash/run_face.sh
	./bash/run_face.sh out_face

out_face/out_face_abvC-seasonal.png: R/plotlivec.R out_face/out_face_livec.csv
	cd out_face && Rscript ../R/plotlivec.R out_face

out_face/out_face_binmonthly.csv_somtc_fancy.png: R/plotlis_somtc.R out_face/out_face_binmonthly.csv
	cd out_face && Rscript ../R/plotlis_somtc.R out_face_binmonthly.csv

out_face/out_face_resp_vs_dc.png: R/plotresp.R validation_data/soyface-2009to2011-soilresp.csv out_face/out_face_mresp.csv out_face/out_face_gresp.csv out_face/out_face_sysc.csv
	cd out_face && Rscript ../R/plotresp.R "out_face"

out_ag/out_ag_binmonthly.csv_somtc_vs_targ.png out_ag/out_ag_binmonthly.csv_somtn_vs_targ.png: R/cn-vs-targ.R out_ag/out_ag_binmonthly.csv
	cd out_ag && Rscript ../R/cn-vs-targ.R out_ag_binmonthly.csv

out_ag/out_ag_harvest.csv_grainvsnass.png: R/harvest-vs-nass.R out_ag/out_ag_harvest.csv
	cd out_ag && Rscript ../R/harvest-vs-nass.R out_ag_harvest.csv

.phony: all spin spin-many ag face plots agplots faceplots

spin: out_spin/spin1.bin
spin-many: spin
	echo 'this may take a few minutes' && \
	./bash/run_spinup.sh spin2 out_spin && \
	./bash/run_spinup.sh spin3 out_spin && \
	./bash/run_spinup.sh spin4 out_spin && \
	./bash/run_spinup.sh spin5 out_spin
ag: out_ag/ag1.bin
agplots: out_ag/out_ag_harvest.csv_grainvsnass.png \
	out_ag/out_ag_binmonthly.csv_somtc_vs_targ.png \
	out_ag/out_ag_binmonthly.csv_somtn_vs_targ.png \
	out_ag/out_ag_binmonthly.csv_somtcn_vs_targ.png
face: out_face/out_facectrl.bin
faceplots: \
	out_face/out_face_abvC-seasonal.png \
	out_face/out_face_binmonthly.csv_somtc_fancy.png \
	out_face/out_face_resp_vs_dc.png
plots: agplots faceplots

