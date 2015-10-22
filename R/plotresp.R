#!/usr/bin/env Rscript

library(ggplot2)
library(grid)
library(gridExtra)
library(DeLuciatoR) # https://github.com/infotroph/DeLuciatoR
library(ggplotTicks) # https://github.com/infotroph/ggplotTicks
theme_set(theme_ggEHD(16))

lm_eqn = function(mod){
	eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(R)^2~"="~r2,
		list(a = format(coef(mod)[1], digits = 2),
			b = format(coef(mod)[2], digits = 2),
			r2 = format(summary(mod)$r.squared, digits = 2)))
	as.character(as.expression(eq))
}

resp = read.csv(
	"../validation_data/soyface-2009to2011-soilresp.csv",
	colClasses=c(
		Effect="character",
		Heat="factor",
		CO2="factor",
		Day="character",
		Estimate="numeric",
		Std.err="numeric",
		DF="numeric",
		t.val="numeric",
		Pr.t="character",
		Date="Date",
		Part="factor",
		Season="factor"))


resp$Treatment = paste0(resp$Heat, resp$CO2)

# If argv exists already, we're being sourced from inside another script.
# If not, we're running standalone and taking arguments from the command line.
if(!exists("argv")){
	argv = commandArgs(trailingOnly = TRUE)
}

mresp = read.csv(paste0(argv[1], "_mresp.csv"), check.names=FALSE)
gresp = read.csv(paste0(argv[1], "_gresp.csv"), check.names=FALSE)
sysc = read.csv(paste0(argv[1], "_sysc.csv"), check.names=FALSE)

scaleflux = function(x){
	return(x
	/12 # g C/mol
	/86400 # sec/day
	*1e6) # µmol/mol
}

dcresp = data.frame(
	run=mresp$run,
	time=mresp$time,
	dayofyr=mresp$dayofyr,
	mleaf=scaleflux(mresp$"cmrspflux(1)"),
	mroot=scaleflux(mresp$"cmrspflux(2)" + mresp$"cmrspflux(3)"))
 dcresp$gleaf = scaleflux(gresp$"cgrspflux(1)")
 dcresp$groot = scaleflux(gresp$"cgrspflux(2)" + gresp$"cgrspflux(3)")
 dcresp$hetresp = scaleflux(sysc$CO2resp)

 rm(list=c("mresp", "gresp", "sysc"))

dcresp$Date = as.Date(
	paste(floor(dcresp$time), dcresp$dayofyr),
	format="%Y %j")
dcresp$Heat = factor(ifelse(
		dcresp$run %in% c("heat", "heatco2"),
		"h",
		"c"))
dcresp$CO2 = factor(ifelse(
	dcresp$run %in% c("co2", "heatco2"),
	"Elevated",
	"Ambient"))

# Why yes, I AM going from a four-level factor to two
# two-level factors back to a new four-level factor.
# Perhaps foolishly, I think this is the easiest way
# to get matching Treatment names between simulated and observed datasets
# without worrying about factor level ordering.
dcresp$Treatment = paste0(dcresp$Heat, dcresp$CO2)

dcresp = dcresp[dcresp$time >= 2009 & dcresp$time < 2012,]

dcresp_aut = dcresp
dcresp_aut$Part = "Raut"
dcresp_aut$Estimate = dcresp$mroot + dcresp$groot

dcresp_het = dcresp
dcresp_het$Part = "Rhet"
dcresp_het$Estimate = dcresp$hetresp

dcresp_tot = dcresp
dcresp_tot$Part = "Rtot"
dcresp_tot$Estimate = dcresp$hetresp + dcresp$mroot + dcresp$groot

dcresp_long=rbind(dcresp_aut, dcresp_het,dcresp_tot)

partexpr = data.frame(
	Part.txt=c("Rhet", "Raut", "Rtot"),
	Part.expr=c("R[het]","R[aut]","R[tot]"))
dcresp_long = merge(dcresp_long, partexpr, by.x="Part", by.y="Part.txt")
resp = merge(resp, partexpr, by.x="Part", by.y="Part.txt")

scale_labels = c(
	cAmbient="Control",
	hAmbient="Heat",
	cElevated=expression(CO[2]),
	hElevated=expression(paste("Heat+", CO[2])))

pltl=(ggplot(data=dcresp_long,
		aes(Date, Estimate, color=Treatment, shape=Treatment, lty=Treatment))
	+facet_grid(Part.expr~., labeller=label_parsed)
	+geom_line()
	+geom_pointrange(data=resp,
		aes(x=Date, y=Estimate, ymin=Estimate-Std.err, ymax=Estimate+Std.err),
		alpha=0.95)
	+scale_color_manual(
		labels=scale_labels,
		values=c(cAmbient="black", hAmbient="black", cElevated="grey", hElevated="grey"))
	+scale_shape_manual(
		labels=scale_labels,
		values=c(cAmbient=1, hAmbient=2, cElevated=16, hElevated=17))
	+scale_linetype_manual(
		labels=scale_labels,
		values=c(cAmbient=1, hAmbient=2, cElevated=1, hElevated=2))
	+theme(
		aspect.ratio=0.5,
		legend.position=c(0.5,0.94),
		legend.title=element_blank(),
		legend.key=element_blank(),
		legend.background=element_blank(),
		legend.text.align=0,
		strip.background=element_blank())
	+guides(col=guide_legend(ncol=2))
	+labs(
		y=expression(paste("Soil ", CO[2],  " efflux, µmol ", m^{-2}, " ", sec^{-1}))))

png_ggsized(
	mirror.ticks(pltl),
	filename=paste(argv[1], "_resp_vs_dc.png", sep=""),
	maxwidth=6.5,
	maxheight=9,
	units="in",
	res=300)
