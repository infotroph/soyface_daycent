#!/usr/bin/env Rscript

library(ggplot2)
library(grid)
library(DeLuciatoR) # https://github.com/infotroph/DeLuciatoR
library(ggplotTicks) # https://github.com/infotroph/ggplotTicks
theme_set(theme_ggEHD(16))

args = commandArgs(trailingOnly = TRUE)

targets= read.csv("../validation_data/soilc-target-vals.csv")

# assumes reading from a (csv converted from a) monthly .lis file
lis= read.csv(args[1])
lis=lis[lis$time>=1850,]
lis.yr = aggregate(lis, by=list(run=lis$run, year=floor(lis$time)), mean)

plt=(ggplot(data=targets, aes(x=sim_year, y=g_soilC_m2_top20))
	+ xlab("Year")
	+ ylab(expression(paste("g C ", m^-2)))
	+ geom_point(aes(color=site), size=4)
	+ geom_line(data=lis.yr, aes(x=year, y=somtc, fill="DayCENT")))
png_ggsized(
	ggobj = mirror_ticks(plt),
	filename=paste0(args[1], "_somtc_vs_targ.png"),
	maxwidth=10.5,
	maxheight=7,
	units="in",
	res=300)

plt=(ggplot(data=targets, aes(x=sim_year, y=g_soilN_m2_top20))
	+ xlab("Year")
	+ ylab(expression(paste("g N ", m^-2)))
	+ geom_point(aes(color=site), size=4)
	+ geom_line(data=lis.yr, aes(x=year, y=somte.1., fill="DayCENT")))
png_ggsized(
	ggobj = mirror_ticks(plt),
	filename=paste0(args[1], "_somtn_vs_targ.png"),
	maxwidth=10.5,
	maxheight=7,
	units="in",
	res=300)
