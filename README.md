# DayCent parameters for modeling SoyFACE temperature & CO2 manipulations

This repository contains *nearly* all the files you need to recreate the DayCent model results presented in "[Elevated CO<sub>2</sub> and temperature increase soil C losses from a soy-maize ecosystem](https://doi.org/10.1111/gcb.13378)", by Christopher K. Black, Sarah C. Davis, Tara W. Hudiburg, Carl J. Bernacchi, and Evan H. DeLucia (Global Change Biology 2017; volume 23 issue 1, pp. 435-445).

The results we present in the paper were obtained using Git revision 0e7a7d1184f80a15681f195961f38730aec73988, which is tagged as `gcb2016_r2` and is also archived in the paper's [Dryad data package](http://dx.doi.org/10.5061/dryad.bn7j3).

## What you *will* find here:

DayCent input parameters, output files, most of the validation data, run-management scripts, and plotting code.

## What you will *not* find here:

* DayCent itself. For that, See ["Prerequisites", below](#prerequisites).
* Chris's full Git history from the model development process. The development version contains three years of blind alleys and expletives and typos, so copying files into this public version was a way of cleaning up after myself. If something seems missing, [ask](http://twitter.com/infotroph) and I'll dig it out of the development repository.
* Raw data or analysis code from the field experiment portion of the paper. Find this [on Dryad](http://dx.doi.org/10.5061/dryad.bn7j3).
* Validation data that contains unpublished values provided to me by collaborators. For details on what I've left out, see the [validation data README](validation_data/README.md).


## Overview

This simulation consists of a set of three linked models, each initialized with the output from the previous model:

1. A spinup run to bring all C pools to equilibrium by simulating ~4000 years of untilled tallgrass prairie with periodic grazing and burning.
2. A historical agriculture scenario from 1867 to 2000, with mixed cropping and pasture early in the late 19th and early 20th century evolving into pure maize-soybean rotation by 1950. The simulation uses actual observed weather, and cultivar yields and fertilization rates are taken from USDA NASS records for Champaign County.
3. A simulation of the SoyFACE heating and CO2 experiment, run as a set of four parallel models, each with or without a step CO2 increase in 2001 and a step temperature increase in 2009. the simulation uses observed weather and the same planting/harvest as the SoyFACE field, so direct comparisons of observed vs. modeled plant phenology and soil conditions should be valid. This simulation continues into the future from 2011-2109, recycling the same planting dates and weather file.


## Details

To run the model, first install all the [prerequisites](#prerequisites), then either run `$(make all)` to recreate the full set of simulations, or run individual simulations by calling their corresponding bash script.

Each script takes two arguments: a name for the run and a name for the directory to put it in. As a shortcut, if the directory name is not provided, it is taken from the run name: `$(./bash/run_spinup.sh testspin)` and `$(./bash/run_spinup.sh testspin testspin)` would both produce a directory named `testspin` with a run named `testspin` inside it. Each run script does the following things:

1. Creates a new output directory, or switches to the existing directory you specified.
2. If `<runnname>.bin` exists, exits with an error rather than overwrite existing DayCent output.
3. Creates links in the output directory for:
	- *all* the parameter files in `common_100s`,
	- the *relevant version* of each file in `differing_100s`. "Relevant version" is mostly identifiable by name (e.g. the spinup script uses `spin_fix.100` but the the 20th-century scenario uses `ag_fix.100`), but some of the `ag_` files are reused for the FACE runs (e.g. `ag_sitepar.in` is used for both the 20th-century and the FACE scenarios).
	- The *relevant* files from `schedules` and `weather`. If editing these, make sure to include the same weather files that are called for in the schedule.
	- If the current run is an extension of an earlier step of the simulation, the DayCent binary file to be extended, probably linked from a different output directory. If you're invoking the run scripts by hand using directory names that differ from the ones in the Makefile, you may need to edit this path.
4. Creates a randomized weather file if needed, using `weather-shuffler.R`. Spinup and ag runs use one, FACE run does not.
5. Runs DayCent, then extracts variables of interest from the binary output file.
6. Converts all outputs, both daily and monthly, from space-delimited to CSV using `out2csv.sh`. If you run the model several times in the same directory, the outputs will be concatenated together, one CSV per output file, with each row identified by run name. This is very handy for e.g. model averaging across multiple runs with randomized weather.
7. Deletes the space-delimited outputs after converting. Note that the links to input files are NOT deleted after the run, but they are overwritten by subsequent runs with different names in the same directory.
8. Generates some simple diagnostic plots of all variables extracted from binary output, using `plotlis.R`.


The run scripts produce univariate timeseries plots of all variables extracted from the binary file (i.e. those listed in `outvars.txt` for a given run). For fancier plots, including the DayCent-related figures from the paper, run `$(make plots)`, or look in the Makefile for script names and syntax examples.


## Prerequisites

To run the model, first you'll need a working copy of the DayCent model, which is only available from the Parton research group at Colorado State University (http://www.nrel.colostate.edu/projects/daycent/). They do not maintain formal version numbers, so the best version description I can give is that I compiled my own binaries from source code the DayCent team provided in July 2012, which appears to be code-named  "DailyDayCent", and that I compiled and ran it on both OS X 10.8 and on Amazon Linux 3.14.48-33.39.amzn1.x86_64, with results that were qualitatively similar but not numerically identical--a few variables differed by a percent or two, i.e. more than pure float error but not enough to worry me. All the results presented in the paper were obtained on OS X.

Once you have binaries, make sure both `DayCent` and `Daycent_list100` are installed somewhere your shell can find them. You may need to add them to your `PATH`, perhaps with an incantation similar to `export PATH=$PATH:/path/to/your/DayCent/bin`.

The model-running scripts are written in `bash` and assume that `bash`, `sed`, `tee`, and `Rscript` are available. If you have a standard Unix toolchain and a working installation of R, these assumptions are probably true. If you use Windows, Cygwin will probably work, but I haven't tried.

To draw diagnotic plots, you will need R and the R packages `ggplot2`, `cowplot`, [`ggplotTicks`](https://github.com/infotroph/ggplotTicks) and [`DeLuciatoR`](https://github.com/infotroph/DeLuciatoR). The last two are not available from CRAN; follow the links for installation instructions.

If you find another prerequisite not listed here, please tell me.
