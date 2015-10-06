#!/usr/bin/env Rscript

library(ggplot2)
library(grid)
source("~/R/ggplot-ticks/mirror.ticks.r")
source("../tools/ggthemes.r")


args = commandArgs(trailingOnly = TRUE)

# assumes reading from a monthly .lis file
targets= read.csv("~/UI/daycent/sfsiteval/soilc-target-vals.csv")

lis= read.csv(args[1])
lis=lis[lis$time>=1850,]
lis.yr = aggregate(lis, by=list(run=lis$run, year=floor(lis$time)), mean)

png(
	filename=paste(args[1], "_somtc_vs_targ.png", sep=""),
	width=10.5,
	height=7,
	units="in",
	res=300)
plt=(ggplot(data=targets, aes(x=year, y=gC.m2.top20)) 
	+ ylab(expression(paste("g C ", m^-2)))
	+ geom_point(aes(color=site), size=4)
	+ geom_line(data=lis.yr, aes(x=year, y=somtc, fill="DayCENT"))
	+ theme_delucia())
plot(mirror.ticks(plt))
dev.off()
rm(plt)

png(
	filename=paste(args[1], "_somtn_vs_targ.png", sep=""), 
	width=10.5,
	height=7,
	units="in",
	res=300)
plt=(ggplot(data=targets, aes(x=year, y=gN.m2.top20))
	+ ylab(expression(paste("g N ", m^-2)))
	+ geom_point(aes(color=site), size=4)
	+ geom_line(data=lis.yr, aes(x=year, y=somte.1., fill="DayCENT"))
	+ theme_delucia())
plot(mirror.ticks(plt))
dev.off()
rm(plt)
