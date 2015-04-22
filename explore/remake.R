### remake.R --- 
## Filename: remake.R
## Description: Remake datasets for analysis
## Author: Noah Peart
## Created: Mon Apr 13 20:07:47 2015 (-0400)
## Last-Updated: Wed Apr 22 02:23:23 2015 (-0400)
##           By: Noah Peart
######################################################################
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
cols <- grep("canht|^STAT|^DBH|^HT[[:digit:]]|^ht[[:digit:]]+|^bv|TRAN|TPLOT|TAG|SPEC|ASP|ELEV|DIST|^HR$", names(tp))
dat <- tp[, cols]
cols <- grep("[A-Za-z]+$|87$|98$|99$|10$|11$", names(dat))
dat <- dat[, cols]  # remove other year columns
dat[, paste0("HT", c(87, 98, 10))] <- NA

dat <- reshape(dat, times = yrs, direction = "long",
               varying = list(
               STAT = grep("^STAT", names(dat)),
               DBH = grep("^DBH", names(dat)),
               BV = grep("^bv", names(dat)),
               HT = grep("^ht[[:digit:]]", names(dat)),
               HTOBS = grep("^HT[[:digit:]]", names(dat)),
               CANHT = grep("canht", names(dat))),
               v.names = c("STAT", "DBH", "BV", "HT", "HTOBS", "CANHT"),
               timevar = "YEAR")
dat$YEAR <- factor(dat$YEAR)
tp <- dat[!is.na(dat$DBH), ]
tp$BA <- 0.00007854*tp$DBH*tp$DBH

## Polar -> cartesian


saveRDS(tp, "../temp/tp.rds")

## ## Add canopy heights
## inds <- match(interaction(dat$TPLOT, dat$TRAN, dat$YEAR),
##               interaction(hh_plot$TPLOT, hh_plot$TRAN, hh_plot$time))
## dat$CANHT <- hh_plot[inds, "ht_mean"]
