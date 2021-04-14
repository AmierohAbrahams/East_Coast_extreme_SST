# OISST_event_detection_v2.R


# Setup -------------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(plyr)
library(tidync)
library(heatwaveR)
library(data.table)
library(doParallel)
registerDoParallel(cores = 16)

base_URL <- "/Users/ajsmit/MEGA/data/East_Coast_extreme_SST/OISST"

load(paste0(base_URL, "/", "OISST_17march.RData"))


# Functions ---------------------------------------------------------------

# CLIMATOLOGY FUNCTION using heatwaveR
ts2clm_grid <- function(data, suffix, coldSpells) {
  if (coldSpells) {
    pctile <- 20
  }
  else {
    pctile <- 80
  }
  out <- ts2clm(data, x = t, y = temp,
                climatologyPeriod = c("1982-01-01", "2011-12-31"),
                robust = FALSE, maxPadLength = 3, windowHalfWidth = 5,
                pctile = pctile, smoothPercentile = TRUE,
                smoothPercentileWidth = 31, clmOnly = FALSE
  )
  # fwrite(out,
  #        file = paste0(base_URL, "/", region, "/", region, suffix, "_climatology.csv"),
  #        append = FALSE)
  return(out)
}

# DETECT FUNCTION using heatwaveR
OISST_detect2 <- function(dat, coldSpells = FALSE) {
  require(heatwaveR)
  out <- heatwaveR::detect_event(dat, coldSpells = coldSpells)
  event <- out$climatology %>% 
    dplyr::filter(t >= "2017-01-01")
  return(event)
}


# Make the climatologies --------------------------------------------------

# Run once
# unfortunately these need to be run individually, and the 
# memory cleared each time; the best is to kill the rsession...
# > killall -9 rsession
hot <- plyr::ddply(.data = OISST_17march, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                   coldSpells = FALSE, .parallel = TRUE)
save(hot, file = paste0(base_URL, "/", "OISST_MHW_climatology_80perc.RData"))
rm(hot); gc()

cold <- plyr::ddply(.data = OISST_17march, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                    coldSpells = TRUE, .parallel = TRUE)
save(cold, file = paste0(base_URL, "/", "OISST_MCS_climatology_20perc.RData"))
rm(cold); gc()


# Detect events -----------------------------------------------------------

# Unlike ts2clm_grid(), detect_event() works fine on large data sets
# and using multicore
# parallel = FALSE gives more helpful error messages during testing...
# run sequentially in a loop...

load(paste0(base_URL, "/", "OISST_MCS_climatology_20perc.RData"))
MCS <- ddply(cold, c("lon", "lat"), OISST_detect2, coldSpells = TRUE, .parallel = TRUE)
fwrite(MCS, file = paste0(base_URL, "/", "OISST_MCS_protoevents_20perc.csv"))
remove(MCS); remove(cold)

load(paste0(base_URL, "/", "OISST_MHW_climatology_80perc.RData"))
MHW <- ddply(hot, c("lon", "lat"), OISST_detect2, .parallel = TRUE)
fwrite(MHW, file = paste0(base_URL, "/", "OISST_MHW_protoevents_80perc.csv"))
remove(MHW); remove(hot)
