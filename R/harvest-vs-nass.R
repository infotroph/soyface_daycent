#!/usr/bin/env Rscript

library(ggplot2)
library(grid)
library(gridExtra)
library(DeLuciatoR) # See https://github.com/infotroph/DeLuciatoR
library(devtools)
source_url("https://raw.githubusercontent.com/infotroph/ggplot-ticks/master/mirror.ticks.r")
theme_set(theme_ggEHD(16))

args = commandArgs(trailingOnly = TRUE)

corntargets = read.csv("../validation_data/NASS/cornyield-champcty.csv")
soytargets = read.csv("../validation_data/NASS//soyyield-champcty.csv")

corntargets$gCm2 =
	(corntargets$Value
	* 25401.2 # grams in 56 lb
	* 0.845 # 15.5% moisture
	/ 4046.86 # m^2 per acre
	* 0.42) # grain is 42% C

soytargets$gCm2 =
	(soytargets$Value
	* 27215.5 # grams in 60 lb
	* 0.87 # 13% moisture
	/ 4046.86 # m^2 per acre
	* 0.50) # grain is 50% C



# Robert Paul's AG biomass estimation method
corntargets$estshootC =
	(corntargets$Value
	* 56 # lbs/bu
	* 0.845 # 15.5% moisture
	* 0.4536 # kg/lb
	* 100 / 45.9 # grain is 45.9% of dry shoot weight
	* 0.4362 #  whole shoot is 43.62 % C
	* 1000 # g/kg
	/ 4046.86) # m^2 per acre

# assumes reading from harvest.csv
harv = read.csv(args[1])
harv$year = floor(harv$time)

cornharv = harv[floor(harv$crpval)==3,]
soyharv = harv[floor(harv$crpval)==60,]

# Simulation alternates corn/soy, so only regress NASS values from the same years simulated.
# Note that for value-over-time lineplots below I use the full NASS set rather than this.
cornharv$NASScgrain = corntargets$gCm2[match(cornharv$year, corntargets$Year)]
cornharv$NASSagcacc = corntargets$estshootC[match(cornharv$year, corntargets$Year)]

soyharv$NASScgrain = soytargets$gCm2[match(soyharv$year, soytargets$Year)]

# add equation and R2 to regression plots.
lm_eqn = function(mod){
	eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(R)^2~"="~r2,
		list(a = format(coef(mod)[1], digits = 2),
			b = format(coef(mod)[2], digits = 2),
			r2 = format(summary(mod)$r.squared, digits = 2)))
	as.character(as.expression(eq))
}

pltcorn = (ggplot(data=cornharv, aes(x=year))
	+ geom_line(data=corntargets, aes(x=Year, y=gCm2, color="NASS"))
	# + geom_point(data=corntargets, aes(x=Year, y=gCm2, color="NASS"))
	+ geom_line(aes(y=cgrain, color="DayCENT"))
	+ geom_point(aes(y=cgrain, color="DayCENT"))
	+ ylab(expression(paste("Corn grain, g C ", m^-2))))
png_ggsized(
	ggobj = mirror.ticks(pltcorn),
	filename=paste0(args[1], "_corn_vs_nass.png"),
	maxwidth=10.5,
	maxheight=7,
	units="in",
	res=300)

pltcornshoot = (ggplot(data=cornharv, aes(x=year))
	+ geom_line(data=corntargets, aes(x=Year, y=estshootC, color="NASS"))
	# + geom_point(data=corntargets, aes(x=Year, y=estshootC, color="NASS"))
	+ geom_line(aes(y=agcacc, color="DayCENT"))
	+ geom_point(aes(y=agcacc, color="DayCENT"))
	+ ylab(expression(paste("Corn shoot biomass, g C ", m^-2))))
png_ggsized(
	ggobj = mirror.ticks(pltcornshoot),
	filename=paste0(args[1], "_cornshoot_vs_nass.png"),
	maxwidth=10.5,
	maxheight=7,
	units="in",
	res=300)

pltsoy = (ggplot(data=soyharv, aes(x=year))
	+ geom_line(data=soytargets, aes(x=Year, y=gCm2, color="NASS"))
	# + geom_point(data=soytargets, aes(x=Year, y=gCm2, color="NASS"))
	+ geom_line(aes(y=cgrain, color="DayCENT"))
	+ geom_point(aes(y=cgrain, color="DayCENT"))
	+ ylab(expression(paste("Soy grain, g C ", m^-2))))
png_ggsized(
	ggobj = mirror.ticks(pltsoy),
	filename=paste0(args[1], "_soy_vs_nass.png"),
	maxwidth=10.5,
	maxheight=7,
	units="in",
	res=300)

cornlm = lm(cgrain ~ NASScgrain, cornharv)
pltcornlm = (ggplot(data=cornharv, aes(x=NASScgrain, y=cgrain))
	+ geom_point()
	+ geom_smooth(method="lm")
	+ geom_abline(intercept=0, slope=1, lty="dashed")
	+ xlab(expression(paste("NASS corn grain, g C ", m^-2)))
	+ ylab(expression(paste("DayCENT corn grain, g C ", m^-2)))
	+ geom_text(aes(x=150, y=400, label=lm_eqn(cornlm)), parse=TRUE)) # adjust x,y as needed
png_ggsized(
	ggobj = mirror.ticks(pltcornlm),
	filename=paste0(args[1], "_corn_vs_nass_lm.png"),
	maxwidth=10.5,
	maxheight=7,
	units="in",
	res=300)

cornshootlm = lm(agcacc ~ NASSagcacc, cornharv)
pltcornshootlm = (ggplot(data=cornharv, aes(x=NASSagcacc, y=agcacc))
	+ geom_point()
	+ geom_smooth(method="lm")
	+ geom_abline(intercept=0, slope=1, lty="dashed")
	+ xlab(expression(paste("NASS corn shoot biomass (est from grain), g C ", m^-2)))
	+ ylab(expression(paste("DayCENT corn shoot biomass, g C ", m^-2)))
	+ geom_text(aes(x=200, y=700, label=lm_eqn(cornshootlm)), parse=TRUE)) # adjust x,y as needed
png_ggsized(
	ggobj = mirror.ticks(pltcornshootlm),
	filename=paste0(args[1], "_cornshoot_vs_nass_lm.png"),
	maxwidth=10.5,
	maxheight=7,
	units="in",
	res=300)

soylm = lm(cgrain ~ NASScgrain, soyharv)
pltsoylm = (ggplot(data=soyharv, aes(x=NASScgrain, y=cgrain))
	+ geom_point()
	+ geom_smooth(method="lm")
	+ geom_abline(intercept=0, slope=1, lty="dashed")
	+ xlab(expression(paste("NASS soy grain, g C ", m^-2)))
	+ ylab(expression(paste("DayCENT soy grain, g C ", m^-2)))
	+ geom_text(aes(x=80, y=250, label=lm_eqn(soylm)), parse=TRUE)) # adjust x,y as needed
png_ggsized(
	ggobj = mirror.ticks(pltsoylm),
	filename=paste0(args[1], "_soy_vs_nass_lm.png"),
	maxwidth=10.5,
	maxheight=7,
	units="in",
	res=300)

theme_set(theme_ggEHD(8))
# Can't use png_ggsized here: It expects a ggplot or gtable object,
# grid.arrange produces a grid object.
png(filename=paste(args[1], "_grainvsnass.png", sep=""),
	width=13,
	height=13,
	units="in",
	res=300)
grid.arrange(
	mirror.ticks(pltcorn
		+scale_color_grey()
		+theme(
			legend.title=element_blank(),
			legend.position=c(0.3,0.8))),
	mirror.ticks(pltcornlm+scale_color_grey()),
	mirror.ticks(pltsoy+scale_color_grey()+theme(legend.position="none")),
	mirror.ticks(pltsoylm+scale_color_grey()))
dev.off()
