#!/usr/bin/env Rscript

library(ggplot2)
library(grid)
library(DeLuciatoR) # https://github.com/infotroph/DeLuciatoR
library(ggplotTicks) # https://github.com/infotroph/ggplotTicks
theme_set(theme_ggEHD(16))

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

lis = read.csv(argv[1], check.names=FALSE)

# lis files from runs with output starting late in simulation
# have one crufty row from start time; we don't need to see that.
times = sort(unique(lis$time))[1:2]
if(times[2] - times[1] > 1){
	lis = lis[lis$time > min(lis$time),]
}

lis = lis[lis$time >= plot_cutoff,]
for(arg in argv[-1]){
	map = call("aes", x=as.name("time"), y=as.name(arg))

	plt = (ggplot(data=lis, mapping=eval(map))
		+geom_line(aes(color=factor(run)))
		+labs(color="Run"))
	ggsave_fitmax(
		filename=paste0(argv[1], "_", arg,".png"),
		plot=mirror_ticks(plt),
		maxwidth=10.5,
		maxheight=7,
		units="in",
		dpi=300)
}
