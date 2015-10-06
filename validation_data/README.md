# Validation data for DayCent model of the SoyFACE climate change experiment

A few datasets I used for model validation are NOT included here, because they include unpublished data kindly shared by others but not authorized for release. I will try to list these below, but in general reference to a file on the path `validation_data/private/` is a call to an unshared dataset. I have attempted to make the scripts that use these fail as gracefully as possible, and I plan to update this directory any time a private dataset goes public.

## Contents of this directory

* `NASS/`

	Annual statistics on historic yield and acres planted of corn, soybeans, wheat, oats, and hay in Champaign County IL, from 1925 to 2011, from the USDA National Agricultural Statistics Service. I downloaded these versions in late 2012 from the NASS Quick Stats web interface (http://quickstats.nass.usda.gov). For each dataset, I drilled down by hand to the particular crop & data item combination I wanted, chose Champaign County, IL, selected all available years, and saved the result as a CSV by clicking the provided "spreadsheet" link. If you're reading this and want to send me a script that performs the same queries using the NASS API, I'd love to include it.

* `private/`

	If you're reading the public version of this repository, this directory does not exist! It's where I store the validation datasets that I don't have permission to share in public.

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
