#!/usr/bin/env Rscript

library(ggplot2)
library(grid)
library(cowplot)
library(DeLuciatoR) # https://github.com/infotroph/DeLuciatoR
library(ggplotTicks) # https://github.com/infotroph/ggplotTicks
gtable_filter = gtable::gtable_filter

theme_set(theme_ggEHD(16))

args = commandArgs(trailingOnly = TRUE)

targets= read.csv("../validation_data/soilc-target-vals.csv")

# assumes reading from a (csv converted from a) monthly .lis file
lis= read.csv(args[1])
lis=lis[lis$time>=1850,]
lis.yr = aggregate(lis, by=list(run=lis$run, year=floor(lis$time)), mean)

cplt=(ggplot(data=targets, aes(x=sim_year, y=g_soilC_m2_top20))
	+ xlab("Year")
	+ ylab(expression(paste("g C ", m^-2)))
	+ geom_point(aes(color=site), size=4)
	+ geom_line(data=lis.yr, aes(x=year, y=somtc, fill="DayCENT")))
ggsave_fitmax(
	filename=paste0(args[1], "_somtc_vs_targ.png"),
	plot=mirror_ticks(cplt),
	maxwidth=10.5,
	maxheight=7,
	units="in",
	dpi=300)

nplt=(ggplot(data=targets, aes(x=sim_year, y=g_soilN_m2_top20))
	+ xlab("Year")
	+ ylab(expression(paste("g N ", m^-2)))
	+ geom_point(aes(color=site), size=4)
	+ geom_line(data=lis.yr, aes(x=year, y=somte.1., fill="DayCENT")))
ggsave_fitmax(
	filename=paste0(args[1], "_somtn_vs_targ.png"),
	plot=mirror_ticks(nplt),
	maxwidth=10.5,
	maxheight=7,
	units="in",
	dpi=300)

combplt= (ggdraw()
		+ draw_plot(mirror_ticks(cplt) + theme(
				legend.position="none",
				plot.margin=unit(c(0.1,0,0,0.1), "in")),
			x=0, y=0.5, width=0.5, height=0.5)
		+ draw_plot(mirror_ticks(nplt) + theme(
				legend.position="none",
				plot.margin=unit(c(0.1,0,0,0.1), "in")),
			x=0, y=0, width=0.5, height=0.5)
		+ draw_plot(
			gtable_filter(ggplotGrob(cplt), "guide-box"),
			x=0.5, y=0.5, width=0.3, height=0)
		+ draw_plot_label(
			label=c("(a)", "(b)"),
			x=c(0, 0),
			y=c(1, 0.5),
			hjust=-5,
			vjust=2.5,
			size=18,
			fontface="bold"))

ggsave(
	filename=paste0(args[1], "_somtcn_vs_targ.png"),
	plot=combplt,
	height=8,
	width=10.5,
	units="in",
	dpi=300)
