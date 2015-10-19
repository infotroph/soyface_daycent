# Validation data for DayCent model of the SoyFACE climate change experiment

A few datasets I used for model validation are NOT included here, because they include unpublished data kindly shared by others but not authorized for release. I will try to list these below, but in general reference to a file on the path `validation_data/private/` is a call to an unshared dataset. I have attempted to make the scripts that use these fail as gracefully as possible, and I plan to update this directory any time a private dataset goes public.

## Contents of this directory

* `NASS/`

	Annual statistics on historic yield and acres planted of corn, soybeans, wheat, oats, and hay in Champaign County IL, from 1925 to 2011, from the USDA National Agricultural Statistics Service. I downloaded these versions in late 2012 from the NASS Quick Stats web interface (http://quickstats.nass.usda.gov). For each dataset, I drilled down by hand to the particular crop & data item combination I wanted, chose Champaign County, IL, selected all available years, and saved the result as a CSV by clicking the provided "spreadsheet" link. If you're reading this and want to send me a script that performs the same queries using the NASS API, I'd love to include it.

* `soilc-target-vals.csv`

	Compiled layer-by-layer soil bulk densities and organic C/N contents from a variety of soils (that I contend are) comparable to the values I should expect this simulation to produce: All are mollisols that formed under tallgrass prairie in the glaciated Midwest, and most sites have paired samples from native prairie or old prairie restorations alongside similar soils with known agricultural histories.

	Key to columns:

	- `site`: City and state where the samples were collected, plus more specific identifier when multiple sites are from the same city.
	- `citation`: The Bibtex citekey I use to refer to this paper in my reference manager. Mostly left over from before I added the DOI column--Maybe should be deleted?
	- `DOI`: Digital object identifier for the paper this datapoint came from. See there for any details I didn't include here.
	- `sim_year`: The year *of DayCent model output* for which I'm treating this datpoint as informative. This is *not* necessarily the same as the year the sample was collected.
	- `rotation`: Management conditions at the time the sample was collected.
	- `soil_series`: NCSS taxonomy name for the soil series in this sample.
	- `bulk_density`: Dry sample density in g/cm^3.
	- `g_soilC_kg`, `g_soilN_kg`: C and N contents, expressed on a per-weight basis.
	- `layer_top_cm`, `layer_bottom_cm`: vertical depth, in cm, from the soil surface to the top and bottom respectively of this layer.
	- `g_soilC_m2_thislayer`, `g_soilN_m2_thislayer`: total area-basis SOC/SON in this soil layer. Derived units; should be equal to e.g. `(g_soilC_kg)/(1000 g/kg)*(bulk_density)*(layer_bottom_cm - layer_top_cm)*(10000 cm^2/m^2)`.
	- `g_soilC_m2_top20`, `g_soilN_m2_top20`: Total grams of SOC/SON, to a depth of 20 cm, per square meter (the same units DayCent reports). Since these values sum over several lines of the rest of the file, I report them on the line corresponding to the shallowest reported layer and leave deeper layers blank in this column. (Yes, it would have been much better to make a separate table for the totals. Next time!)

* `soyface-2009to2011-soilresp.csv`

	Mixed-model estimates of treatment mean±SE respiration rates in the T-FACE experimental plots on each measurement day of the heating experiment. I do have the raw data these are calculated from and I ought to post them somewhere, but for Daycent diagnostics the treatment means are easier to deal with.

	Key to columns (Many are messy od redundant -- this is a barely-cleaned copy-paste of SAS output! I only use `Heat`, `CO2`, `Estimate`, `Std.Err`, `Date`, `Part`, `Season`.):

	- `Effect`: This column is constant here: always `Heat*CO2*Day`.
	- `Heat`: Heat treatment. `c`=ambient temperature, `h`=canopy temperature increased by overhead infrared heating to a target of 3.5 °C aboe ambient.
	- `CO2`: CO2 treatment. `Ambient`=ambient field conditions (~385 ppm CO2), `Elevated`=FACE fumigation to a target of 585 ppm.
	- `Day`: Sampling date, formatted YYYYMMDD. When it took more than one day to complete a round of measurements and weather was constant, I collapsed dates and recorded Day as the midpoint. When it took more than five days to complete a sampling or weather changed in the middle, I recorded them as separate samplings with smaller N.
	- `Estimate`, `Std.err`: Predicted mean and standard error of respiration rate for this day/treatment combo, calculated as an LS mean.
	- `DF`, `t.val`, `Pr.t`: Kenward-Roger corrected tests for the (completely uninteresting) hypothesis that respiration = 0 for each treatment/day combo.
	- `Date`: Same as `Day`, but formatted YYYY-MM-DD instead of YYYYMMDD.
	- `Part`: Which component of soil respiration this estimate applies to. `Rtot`=whole soil, `Raut`=roots+rhizosphere, `Rhet`=soil heterotrophs.
	- `Season`: Which crop (if any) was in the field during the measurement?

* `private/`

	If you're reading the public version of this repository, this directory does not exist! It's where I store the validation datasets that I don't have permission to share in public, which are:

	- `SoyFACE-Soymass-ctrl.csv`, `SoyFACE-Soymass-co2.csv`: Measurements of soybean plant biomass, broken down by CO2 treatment and component (stem, leaf, seed, root), from ~biweekly destructive harvests throughout the 2001 to 2007 growing seasons. Provided to CKB by Andrew D.B. Leakey; contains data from at least the A. Leakey, L. Ainsworth, R. Nelson labs. This dataset was discussed, but not made accessible, in [Twine et al. 2013](dx.doi.org/10.1111/gcb.12270).

## Further notes on validation that need to live somewhere

My validation data on fertilizer use came from USDA in the form of a giant, messy Excel file spanning the years from ~1960 to 2010 in the form of 32 different worksheets, some broken down by state and others not. Rather than include the file directly, I note that it's available from https://catalog.data.gov/dataset/fertilizer-use-and-price and that the full extent of the information I used from it is is captured in the following quote from my project notes file:

> Are my fertilization rates realistic? Downloaded historic fertilizer use data, broken down by state and crop, from http://www.ers.usda.gov/Data/FertilizerUse/ and saved as sfsiteval/fertilizeruse.xls. Key points:
> * Average N fertilization rate for IL was
	- 1964: 72 lb/ac = 8.07 g/m2
	- 1970: ~120 = 13.5
	- 1980: ~140 = 15.7
	- 1990 thru now: ~160 = 17.9
> * 90% of IL corn was fertilized by 1964, never below 94% since 1967.
> * ~10% of IL soybean fertilized, more or less steady with ~5% scatter
> * The few soybeans that were fertilized got ~15 lb/ac in 60s, increasing to ~25 by 90s (highly variable).
