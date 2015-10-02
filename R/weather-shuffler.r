#!/usr/bin/env Rscript

# Read a Daycent weather file in the current directory, 
# randomly permute the years, write it back out.
# Intended for generating detrended spinups.

# TODO: Does not consider leap years in any way. Should it?

weather.files = commandArgs(trailingOnly = TRUE)
stopifnot(length(weather.files) == 2)

weather = read.table(
	file=weather.files[1],
	col.names=c("day", "mon", "year", "doy", "maxtmp", "mintmp", "precip"))
		#BUGBUG: will break if using extra production drivers!

years.shuffled = sample(unique(weather$year))
roworder = order(match(weather$year, years.shuffled), weather$doy)
weather.shuffled = weather[roworder, ]

write.table(
	x=weather.shuffled, 
	file=weather.files[2],
	row.names=FALSE, 
	col.names=FALSE)