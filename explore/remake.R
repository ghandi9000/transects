### remake.R --- 
## Filename: remake.R
## Description: Remake datasets for analysis
## Author: Noah Peart
## Created: Mon Apr 13 20:07:47 2015 (-0400)
R
## Last-Updated: Fri Apr 24 20:39:22 2015 (-0400)
##           By: Noah Peart
######################################################################
source("helpers.R")
require(plyr)
require(dplyr)

## Data with estimated heights/boles
if (file.exists("temp/transect.csv")) {
    tp <- read.csv("temp/transect.csv")
} else if (file.exists("../data/transect.csv")) {
    tp <- read.csv("../data/transect.csv")
} else
    tp <- read.csv("~/work/temp/transect.csv")

################################################################################
##
##                                 Transects
##
################################################################################
## tidy, wide -> long
yrs <- c(87, 98, 99, 10, 11)
cols <- grep("canht|^STAT|^DBH|^HT[[:digit:]]|^ht[[:digit:]]+|^bv|TRAN|TPLOT|TAG|SPEC|ASP|ELEV|DIST|^HR$|TRAD|ABSRAD", names(tp))
dat <- tp[, cols]
cols <- grep("[A-Za-z]+$|87$|98$|99$|10$|11$", names(dat))
dat <- dat[, cols]  # remove other year columns
dat[, paste0("HT", c(87, 98, 10))] <- rep(NA, nrow(dat))
dat <- rename(dat, ABSRAD99=ABSRAD, TRAD99=TRAD)
dat[, paste0("ABSRAD", c(87, 98, 10))] <- NA
dat[, paste0("TRAD", c(87, 98, 10))] <- NA

## Growth columns
## 87, 98 => no S transects, no HH of LL elevations
dat[, paste0("BA",yrs)] <- 0.00007854 * dat[,paste0("DBH", yrs)]**2
## vars <- c("DBH", "ht", "bv", "canht", "HTTCR", "BA")
## for (v in vars) {
##     dat[,paste0("g_", v, 86)] <- (dat[,paste0(v, 98)] - dat[,paste0(v, 86)])/12
##     dat[,paste0("g_", v, 87)] <- (dat[,paste0(v, 98)] - dat[,paste0(v, 87)])/11
##     dat[,paste0("g_", v, 98)] <- (dat[,paste0(v, 10)] - dat[,paste0(v, 98)])/12
## }

dat <- reshape(dat, times = yrs, direction = "long",
               varying = list(
               TRAD = grepInOrder("^TRAD", yrs, dat),
               ABSRAD = grepInOrder("^ABSRAD", yrs, dat),
               STAT = grepInOrder("^STAT", yrs, dat),
               DBH = grepInOrder("^DBH", yrs, dat),
               BV = grepInOrder("^bv", yrs, dat),
               HTOBS = grepInOrder("^HT", yrs, dat),
               HT = grepInOrder("^ht", yrs, dat),
               CANHT = grepInOrder("canht", yrs, dat)),
               v.names = c("TRAD", "ABSRAD", "STAT", "DBH", "BV", "HTOBS", "HT", "CANHT"),
               timevar = "YEAR")
dat$YEAR <- factor(dat$YEAR)

tp <- dat[!is.na(dat$DBH) | !is.na(dat$HT) | !is.na(dat$HTOBS), ]
tp$BA <- 0.00007854*tp$DBH*tp$DBH

## Polar -> cartesian
coords <- pol2cart(tp$DIST, (tp$HR%%12)/12 * 2*pi + pi/2)
tp$X <- -coords[,1]
tp$Y <- coords[,2]



## Save
saveRDS(tp, "../temp/tp.rds")

## ## Add canopy heights
## inds <- match(interaction(dat$TPLOT, dat$TRAN, dat$YEAR),
##               interaction(hh_plot$TPLOT, hh_plot$TRAN, hh_plot$time))
## dat$CANHT <- hh_plot[inds, "ht_mean"]

################################################################################
##
##                                   CHECK
##
################################################################################
## ## Transect/tplot htobs counts (HH only) observed heights
## tst <- tp %>% group_by(TRAN, TPLOT) %>% filter(!is.na(HT99) | !is.na(HT11)) %>%
##     summarise(n99 = sum(!is.na(HT99)),
##               n11 = sum(!is.na(HT11)))

## tst2 <- dat %>% group_by(TRAN, TPLOT, YEAR) %>% filter(!is.na(HTOBS)) %>%
##     summarise(count = n())

## par(mfrow = c(2,1))
## with(tp[tp$TRAN=="E320" & tp$TPLOT==16,], plot(DBH11, HT11))
## with(dat[dat$YEAR==11 & dat$TRAN=="E320" & dat$TPLOT==16,], plot(DBH, HTOBS))

## ## TRAD and ABSRAD
## tst3 <- tp %>% group_by(TRAN, TPLOT) %>%
##     summarise(trad99=unique(TRAD),
##               trad11=unique(TRAD11),
##               absrad99=unique(ABSRAD),
##               absrad11=unique(ABSRAD11))

## tst4 <- dat %>% group_by(TRAN, TPLOT, YEAR) %>%
##     filter(YEAR %in% c(99, 11)) %>%
##     summarise(trad=unique(TRAD),
##               absrad=unique(ABSRAD))

## table(tst3$trad99)
## table(tst4[tst4$YEAR==99, "trad"])
## table(tst3$trad11)
## table(tst4[tst4$YEAR==11, "trad"])

## table(tst3$absrad99)
## table(tst4[tst4$YEAR==99, "absrad"])
## table(tst3$absrad11)
## table(tst4[tst4$YEAR==11, "absrad"])

## ## Locations (cartesian)
## tst5 <- tp[tp$TRAN == "E320" & tp$TPLOT == 16 & tp$YEAR == 99, ]
## unique(tst5$TRAD)
## unique(tst5$ABSRAD)
## plot(tst5$X, tst5$Y, col=tst5$HR)
## legend("topleft", legend=c("Hours", as.character(1:12)), col=c(NA,1:12), pch=16)
