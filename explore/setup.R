### setup.R --- 
## Filename: setup.R
## Description: create/cache neighbor matrices/datasets
## Author: Noah Peart
## Created: Sun Apr 12 17:04:02 2015 (-0400)
## Last-Updated: Tue Apr 21 20:40:21 2015 (-0400)
##           By: Noah Peart
######################################################################
## source("~/work/ecodatascripts/vars/heights/canopy/load_canopy.R")
require(plyr)
require(dplyr)
require(ggplot2)

if (!file.exists("../temp"))
    dir.create("../temp")  # store prepped data
if (!file.exists("../temp/tp.rds")) {
    source("remake.R")
} else
    tp <- readRDS("../temp/tp.rds")
