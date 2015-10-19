#!/usr/bin/env Rscript

library(ggplot2)
library(grid)
library(ggplotTicks)
library(DeLuciatoR)

sfbiomass.ctrl = read.csv("../validation_data/private/SoyFACE-Soymass-ctrl.csv", na.strings=".")
sfbiomass.co2 = read.csv("../validation_data/private/SoyFACE-Soymass-co2.csv", na.strings=".")
sfbiomass = rbind(sfbiomass.ctrl, sfbiomass.co2)
rm(list=c("sfbiomass.ctrl", "sfbiomass.co2"))

# 45.32% = whole-shoot soy C content estimate from energy farm 2010
sfbiomass$shoot.C = sfbiomass$total.shoot * 0.4532 

levels(sfbiomass$CO2)=c("co2", "ctrl")
sfbiomass$Year = factor(sfbiomass$Year)

# If argv exists already, we're being sourced from inside another script. 
# If not, we're running standalone and taking arguments from the command line.
if(!exists("argv")){ 
	argv = commandArgs(trailingOnly = TRUE)
}

livec = read.csv(paste(argv[1], "_livec.csv", sep=""))
deadc = read.csv(paste(argv[1], "_deadc.csv", sep=""))
livec$stdedc = deadc$stdedc
rm(deadc)
livec$Year = factor(floor(livec$time))

# Only interested in soy data from years soy was in the west field.
sfbiomass = sfbiomass[sfbiomass$Year %in% c(2001, 2003, 2005, 2007),,drop=FALSE]

livec = livec[livec$Year %in% c(2001, 2003, 2005, 2007),,drop=FALSE]
#livec = livec[livec$time < 2012,]

#remove T-FACE runs before heat turned on (/should/ be identical to ctrl and co2)
livec = livec[-which(livec$time < 2009 & livec$run %in% c("heat", "heatco2")),]

# aboveground biomass through the growing season.
png(filename=paste(argv[1], "_abvC-seasonal.png", sep=""),
	width=10.5,
	height=7,
	units="in",
	res=300)
plt=(ggplot(
		sfbiomass, 
		aes(Julian.Day, shoot.C, color=CO2))
	+geom_point()
	+geom_line(data=livec, aes(dayofyr, aglivc+stdedc, color=run))
	+facet_wrap(~Year)
	+ylab(expression(paste("Shoot biomass, g C ", m^-2)))
	+xlab("Day of year")
	+scale_color_manual(values=c(ctrl="black", co2="grey"))
	+theme_ggEHD())
plot(mirror.ticks(plt))
dev.off()
rm(plt)

# library(dplyr)

# sfbiomass_mean = (
# 	sfbiomass 
# 	%>% group_by(Year, Julian.Day, CO2)
# 	%>% select(shoot.C)
# 	%>% summarise(shootC_mean = mean(shoot.C), shootC_sd = sd(shoot.C))
# )	

# livec_prod = (
# 	livec
# 	%>% select("aglivc", "stdedc") 
# 	%>% mutate(agc = aglivc+stdedc)
# )

# sfdc_biomass = merge(
# 	x=sfbiomass_mean, 
# 	y=livec_prod, 
# 	by.x=c("Year", "Julian.Day", "CO2"), 
# 	by.y=c("Year", "dayofyr", "run"))

# (ggplot(sfdc_biomass, 
# 	aes(
# 		y=shootC_mean, 
# 		ymin=shootC_mean-shootC_sd, 
# 		ymax=shootC_mean+shootC_sd, 
# 		x=agc, 
# 		color=CO2))
# +geom_pointrange()
# +geom_smooth(method="lm")
# +geom_abline(yintercept=0, slope=1)
# +coord_flip()
# +facet_wrap(~Year)
# +xlab(expression(paste("DayCent biomass, g C ", m^-2)))
# +ylab(expression(paste("Observed biomass, g C ", m^-2))))
