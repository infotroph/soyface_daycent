# DayCent parameters for modeling SoyFACE temperature & CO2 manipulations

Work in progress! This repository should eventually contain:

- [x] input parameters for running the model in DayCent (version ???, compiled from a zip archive dated 2012-06-13 and labeled `DailyDayCent_Linux_Source`).
- [X] Run scripts (mix of shell and R).
- [ ] Result-plotting scripts (mostly R).
- [ ] Validation scripts (mostly R).
- [ ] Archive of validation data (excluding unpublished values shared by others).
- [ ] Archive of final model output.
- [x] Plotting code for final figures (in R).
- [ ] Documentation of all of the above.

## The general scheme

This simulation consists of a set of three linked models, each initialized with the output from the previous model:

1. A spinup run to bring all C pools to equilibrium by simulating ~4000 years of untilled tallgrass prairie with periodic grazing and burning.
2. A historical agriculture scenario from 1867 to 2000, with mixed cropping and pasture early in the late 19th and early 20th century evolving into pure maize-soybean rotation by 1950. The simulation uses actual observed weather, and cultivar yields and fertilization rates are taken from USDA NASS records for Champaign County.
3. A simulation of the SoyFACE heating and CO2 experiment, run as a set of four parallel models, each with or without a step CO2 increase in 2001 and a step temperature increase in 2009. the simulation uses observed weather and the same planting/harvest as the SoyFACE field, so direct comparisons of observed vs. modeled plant phenology and soil conditions should be valid. This simulation continues into the future from 2011-2109, recycling the same planting dates and weather file.

## Details

The parameter files in `common_100s` are included in every simulation, while the files in `differing_100s` change between simulations: Anything whose name starts with `spin_` is included in the spinup, `ag_` goes in the 20th-century scenario, and `face_` is the climate change scenario. Files in `differing_100s` that have an `ag_` version but no `face_` version are also included in the FACE scenario runs.`

## Prerequisites

To run the model, first you'll need a working DayCent binary. As far as I know these are only available by talking directly to the Parton group at Colorado State University (http://www.nrel.colostate.edu/projects/daycent/), or to someone who has already worked with them. They do not maintain formal version numbers, so the best version description I can give is that for this model I compiled my own binaries on OS X 10.8 from source code the DayCent team provided in July 2012, which appears to be named  "DailyDayCent."

Once you have a DayCent binary, make sure it's installed somewhere your shell can find it. You may need to add it to your `PATH`, perhaps with an incantation similar to `export PATH=$PATH:/path/to/your/DayCent/bin`.

The model-running scripts are written in `bash` and assume a standard Unix toolchain, or at least `bash` and `sed`, is available. If you use Windows, Cygwin will probably work, but I haven't tried.

To draw diagnotic plots, you will need `R` and the R packages `ggplot2`, `gridExtra`, `devtools` (which may in turn, depending on your system configuration, require the development versions of the operating system libraries `libcurl`, `libxml2`, and `openssl`), and `DeLuciatoR` (which is not available from CRAN; follow the installation instructions at https://github.com/infotroph/DeLuciatoR).

If you find another prerequisite not listed here, please tell me.