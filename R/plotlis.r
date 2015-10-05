#!/usr/bin/env Rscript

library(ggplot2)
library(grid)
source("~/R/ggplot-ticks/mirror.ticks.r")
source("../tools/ggpng.r")
source("../tools/ggthemes.r")
theme_set(theme_delucia(16))

# Probably only applies to spinup results:
# Only plot output from this year or later.
# Psst: If you *never* care about the early output, you may want to
# adjust 'output starting year' in your schedule file!
plot_cutoff = 1850

# If argv exists already, we're being sourced from inside another script. 
# If not, we're running standalone and taking arguments from the command line.
if(!exists("argv")){ 
	argv = commandArgs(trailingOnly = TRUE)
}

lis = read.csv(argv[1])

# lis files from runs with output starting late in simulation 
# have one crufty row from start time; we don't need to see that.
times = sort(unique(lis$time))[1:2]
if(times[2] - times[1] > 1){
	lis = lis[lis$time > min(lis$time),] 
}

lis = lis[lis$time >= plot_cutoff,]
plotarg=function(arg){
	map = call("aes", x=as.name("time"), y=as.name(arg))
	plt = (ggplot(data=lis, mapping=eval(map))
		+geom_line(aes(color=factor(run)))
		+labs(color="Run"))
	ggpng(plt, paste0(argv[1], "_", arg,".png"))
}

lapply(argv[-1], plotarg)
