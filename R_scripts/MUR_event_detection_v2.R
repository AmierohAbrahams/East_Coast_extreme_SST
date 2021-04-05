# MUR_event_detection_v2.R


# Setup -------------------------------------------------------------------

library(doParallel)
registerDoParallel(cores = 16)
library(tidyverse)
library(lubridate)
library(plyr)
library(tidync)
library(heatwaveR)
library(data.table)

base_URL <- "/Users/ajsmit/MEGA/data/East_Coast_extreme_SST/MUR"


# Functions ---------------------------------------------------------------

read_MUR_1km <- function(region) {
  file_name <- paste0(base_URL, "/", region, "/", "MUR-JPL-L4-GLOB-v4.1.nc")
  out <- tidync(file_name) %>%
    hyper_tibble() %>% 
    select(lon, lat, time, analysed_sst) %>% 
    dplyr::rename(t = time, temp = analysed_sst) %>% 
    na.omit() %>% 
    mutate(t = as.Date(as.POSIXct(t, origin = "1981-01-01 00:00:00.0")),
           temp = temp - 273.15) # Convert from K to C
  return(out)
}

# CLIMATOLOGY FUNCTION using heatwaveR
ts2clm_grid <- function(data, suffix, coldSpells) {
  if (coldSpells) {
    pctile <- 10
  }
  else {
    pctile <- 90
  }
  out <- ts2clm(data, x = t, y = temp,
                climatologyPeriod = c("2003-01-01", "2020-12-31"),
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
MUR_detect2 <- function(dat, coldSpells = FALSE) {
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
region <- "region1"
region1 <- read_MUR_1km(region)
hot <- plyr::ddply(.data = region1, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                   coldSpells = FALSE, .parallel = TRUE)
save(hot, file = paste0(base_URL, "/", region, "/", region, "_MHW_climatology.RData"))
rm(hot); gc()
cold <- plyr::ddply(.data = region1, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                    coldSpells = TRUE, .parallel = TRUE)
save(cold, file = paste0(base_URL, "/", region, "/", region, "_MCS_climatology.RData"))
rm(list = c("region1", "cold")); gc()

region <- "region2"
region2 <- read_MUR_1km(region)
hot <- plyr::ddply(.data = region2, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                   coldSpells = FALSE, .parallel = TRUE)
save(hot, file = paste0(base_URL, "/", region, "/", region, "_MHW_climatology.RData"))
rm(hot); gc()
cold <- plyr::ddply(.data = region2, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                    coldSpells = TRUE, .parallel = TRUE)
save(cold, file = paste0(base_URL, "/", region, "/", region, "_MCS_climatology.RData"))
rm(list = c("region2", "cold")); gc()

region <- "region3"
region3 <- read_MUR_1km(region)
hot <- plyr::ddply(.data = region3, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                   coldSpells = FALSE, .parallel = TRUE)
save(hot, file = paste0(base_URL, "/", region, "/", region, "_MHW_climatology.RData"))
rm(hot); gc()
cold <- plyr::ddply(.data = region3, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                    coldSpells = TRUE, .parallel = TRUE)
save(cold, file = paste0(base_URL, "/", region, "/", region, "_MCS_climatology.RData"))
rm(list = c("region3", "cold")); gc()

region <- "region4"
region4 <- read_MUR_1km(region)
hot <- plyr::ddply(.data = region4, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                   coldSpells = FALSE, .parallel = TRUE)
save(hot, file = paste0(base_URL, "/", region, "/", region, "_MHW_climatology.RData"))
rm(hot); gc()
cold <- plyr::ddply(.data = region4, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                    coldSpells = TRUE, .parallel = TRUE)
save(cold, file = paste0(base_URL, "/", region, "/", region, "_MCS_climatology.RData"))
rm(list = c("region4", "cold")); gc()

region <- "region5"
region5 <- read_MUR_1km(region)
hot <- plyr::ddply(.data = region5, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                   coldSpells = FALSE, .parallel = TRUE)
save(hot, file = paste0(base_URL, "/", region, "/", region, "_MHW_climatology.RData"))
rm(hot); gc()
cold <- plyr::ddply(.data = region5, .variables = c("lon", "lat"), .fun = ts2clm_grid,
                    coldSpells = TRUE, .parallel = TRUE)
save(cold, file = paste0(base_URL, "/", region, "/", region, "_MCS_climatology.RData"))
rm(list = c("region5", "cold")); gc()


# Detect events -----------------------------------------------------------

# Unlike ts2clm_grid(), detect_event() works fine on large data sets
# and using multicore
# parallel = FALSE gives more helpful error messages during testing...
# run sequentially in a loop...

regions <- c("region1", "region2", "region3", "region4", "region5")
for (i in regions) {
  region <- i
  # region <- "region1" ###
  load(paste0(base_URL, "/", region, "/", region, "_MCS_climatology.RData"))
  MCS <- ddply(cold, c("lon", "lat"), MUR_detect2, coldSpells = TRUE, .parallel = TRUE)
  fwrite(MCS, file = paste0(base_URL, "/", region, "/", region, "_MCS_protoevents.csv"))
  remove(MCS); remove(cold)
  
  load(paste0(base_URL, "/", region, "/", region, "_MHW_climatology.RData"))
  MHW <- ddply(hot, c("lon", "lat"), MUR_detect2, .parallel = TRUE)
  fwrite(MHW, file = paste0(base_URL, "/", region, "/", region, "_MHW_protoevents.csv"))
  remove(MHW); remove(hot)
}