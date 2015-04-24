### remake.R --- 
## Filename: remake.R
## Description: Remake datasets for analysis
## Author: Noah Peart
## Created: Mon Apr 13 20:07:47 2015 (-0400)
R
## Last-Updated: Fri Apr 24 11:11:38 2015 (-0400)
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
dat[, paste0("HT", c(87, 98, 10))] <- rep(NA, nrow(dat))

dat <- reshape(dat, times = yrs, direction = "long",
               varying = list(
               STAT = grep("^STAT", names(dat)),
               DBH = grep("^DBH", names(dat)),
               BV = grep("^bv", names(dat)),
               HTOBS = grep("^HT[[:digit:]]", names(dat)),
               HT = grep("^ht[[:digit:]]", names(dat)),
               CANHT = grep("canht", names(dat))),
               v.names = c("STAT", "DBH", "BV", "HTOBS", "HT", "CANHT"),
               timevar = "YEAR")
#dat$YEAR <- factor(dat$YEAR)

dat <- dat[!is.na(dat$DBH) | !is.na(dat$HT) | !is.na(dat$HTOBS), ]
tp$BA <- 0.00007854*tp$DBH*tp$DBH

## Polar -> cartesian


saveRDS(tp, "../temp/tp.rds")

## ## Add canopy heights
## inds <- match(interaction(dat$TPLOT, dat$TRAN, dat$YEAR),
##               interaction(hh_plot$TPLOT, hh_plot$TRAN, hh_plot$time))
## dat$CANHT <- hh_plot[inds, "ht_mean"]

## Transect/tplot htobs counts (HH only)
tst <- tp %>% group_by(TRAN, TPLOT) %>% filter(!is.na(HT99) | !is.na(HT11)) %>%
    summarise(n99 = sum(!is.na(HT99)),
              n11 = sum(!is.na(HT11)))

tst2 <- dat %>% group_by(TRAN, TPLOT, YEAR) %>% filter(!is.na(HTOBS)) %>%
    summarise(count = n())

par(mfrow = c(2,1))
plot(tp[tp$TRAN=="E320" & tp$TPLOT==16, "HT99"])
plot(dat[dat$YEAR==87 & dat$TRAN=="E320" & dat$TPLOT==16, "HTOBS"])

dd <- data.frame(v3=rep(3, 10), v2=rep(2, 10), v1=rep(1, 10), tag=sample(1:100, 10))
reshape(dd, times=1:3, varying="v", v.names="v", direction = "long")
sort(names(tp))
tp <- tp[, order(names(tp))]
