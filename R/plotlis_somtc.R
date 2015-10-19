#!/usr/bin/env Rscript

# A specialized variant of plotlis.R, created mostly to present annual values instead of monthly fluctuations for the publication version of total SOM C predictions.

library(ggplot2)
library(grid)
library(dplyr)
library(ggplotTicks)
library(DeLuciatoR)
theme_set(theme_ggEHD(16))

# If argv exists already, we're being sourced from inside another script.
# If not, we're running standalone and taking arguments from the command line.
if(!exists("argv")){
	argv = commandArgs(trailingOnly = TRUE)
}

lis = read.csv(argv[1], colClasses=c("character", rep("numeric", 30)))
lis = lis[lis$time >=1950,]
lis$run = relevel(factor(lis$run), ref="ctrl")

lis = (lis
	%>% mutate(year=floor(time))
	%>% group_by(run, year)
	%>% select(somtc)
	%>% summarise_each(funs(mean)))

scale_labels = c(
	ctrl="Control",
	heat="Heat",
	co2=expression(CO[2]),
	heatco2=expression(paste("Heat+", CO[2])))
scale_colors = c(ctrl="black", heat="black", co2="grey", heatco2="grey")
scale_linetypes = c(ctrl=1, heat=2, co2=1, heatco2=2)

plt = (ggplot(data=lis, aes(x=year, y=somtc, color=run, lty=run))
	+geom_line()
	+scale_color_manual(labels=scale_labels, values=scale_colors)
	+scale_linetype_manual(labels=scale_labels, values=scale_linetypes)
	+ylab(expression(paste("Daycent SOM, g C ", m^2)))
	+theme(
		legend.title=element_blank(),
		legend.key=element_blank(),
		legend.position=c(0.15,0.85),
		legend.background=element_blank(),
		legend.text.align=0))
png_ggsized(
	mirror.ticks(plt),
	filename=paste0(argv[1], "_somtc.png"),
	maxheight=9,
	maxwidth=6.5,
	units="in",
	res=600)
