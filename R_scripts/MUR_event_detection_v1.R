# MUR_event_detection.R

# Setup -------------------------------------------------------------------

library(tidyverse)
library(plyr)
library(lubridate)
library(tidync)
library(heatwaveR)
library(data.table)
library(doParallel)
registerDoParallel(cores = 8)

base_URL <- "/Users/ajsmit/MEGA/data/East_Coast_extreme_SST/MUR"

read_MUR_1km <- function(region) {
  file_name <- paste0(base_URL, "/", region, "/", "MUR-JPL-L4-GLOB-v4.1.nc")
  MUR_dat <- tidync(file_name) %>%
    hyper_tibble() %>% 
    select(lon, lat, time, analysed_sst) %>% 
    dplyr::rename(t = time, temp = analysed_sst) %>% 
    na.omit() %>% 
    mutate(t = as.Date(as.POSIXct(t, origin = "1981-01-01 00:00:00.0")),
           temp = temp - 273.15) # Convert from K to C
  return(MUR_dat)
}


# Define the function for event detection ---------------------------------

event_only <- function(df, coldSpells = FALSE) {
  
  if (coldSpells) {
    pctile <- 10
    suffix <- "_MCS"
    }
  else {
    pctile <- 90
    suffix <- "_MHW"
    }
  
  # First calculate the climatologies
  clim <- ts2clm(data = df, climatologyPeriod = c("2003-01-01", "2020-12-31"), pctile = pctile)
  # Then the events
  event <- detect_event(data = clim, coldSpells = coldSpells)
  # Return only the event metric dataframe of results
  save(event, file = paste0(base_URL, "/", region, "/", region, suffix, ".RData"))
  return(event$event)
}


# Detect events -----------------------------------------------------------

# Run once
region <- "Port_Edward_to_Durban"
region1 <- read_MUR_1km(region)
system.time(
  region1_events <- plyr::ddply(.data = region1, .variables = c("lon", "lat"), .fun = event_only,
                                coldSpells = FALSE, .parallel = FALSE)
) # 348.089 seconds
rm(region1)
rm(region1_events)

region <- "East_London_to_Port_Edward"
region2 <- read_MUR_1km(region)
system.time(
  region2_events <- plyr::ddply(.data = region2, .variables = c("lon", "lat"), .fun = event_only,
                                coldSpells = TRUE, .parallel = TRUE)
) # 861.103 seconds
rm(region2)
rm(region2_events)

region <- "Cape_St_Francis_to_East_London"
region3 <- read_MUR_1km(region)
system.time(
  region3_events <- plyr::ddply(.data = region3, .variables = c("lon", "lat"), .fun = event_only,
                                coldSpells = TRUE, .parallel = TRUE)
) # 738.261 seconds
rm(region3)
rm(region3_events)

region <- "Cape_Agulhas_to_Cape_St_Francis"
region4 <- read_MUR_1km(region)
system.time(
  region4_events <- plyr::ddply(.data = region4, .variables = c("lon", "lat"), .fun = event_only,
                                coldSpells = TRUE, .parallel = TRUE)
) # 940.405 seconds
rm(region4)
rm(region4_events)

region <- "St_Helena_Bay_to_Cape_Agulhas"
region5 <- read_MUR_1km(region)
system.time(
  region5_events <- plyr::ddply(.data = region5, .variables = c("lon", "lat"), .fun = event_only,
                                coldSpells = TRUE, .parallel = TRUE)
) # 567.373 seconds
rm(region5)
rm(region5_events)


# ddply method ------------------------------------------------------------

# CLIMATOLOGY FUNCTION using heatwaveR
ts2clm_grid <- function(data, region, suffix, coldSpells) {
  if (coldSpells) {
    pctile <- 10
    suffix <- "_MCS"
  }
  else {
    pctile <- 90
    suffix <- "_MHW"
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





# Using a tidier way ------------------------------------------------------

library(furrr)
future::plan(multisession)

region1_split <- region1 %>% 
  split(list("lon", "lat"))

out1 <- region1_split %>% 
  future_map_dfr(ts2clm_grid, region = "region1", coldSpells = FALSE)

out2 <- region1 %>% 
  group_by(lon, lat) %>%
  nest() %>% 
  mutate(out = future_map_dfr(data, ts2clm_grid, region = "region1", coldSpells = FALSE))



# DETECT FUNCTION using heatwaveR
OISST_detect2 <- function(dat) {
  require(heatwaveR)
  # dat$t <- fastDate(dat$t)
  out <- heatwaveR::detect_event(dat)
  event <- out$event
  return(event)
}

setClass('myDate')
setAs(from = "character", to = "myDate", def = function(from) as.Date(fastPOSIXct(from, tz = NULL)))

# Unlike ts2clm(), detect_event() works fine on large data sets and using multicore

# detect AC events
# parallel = FALSE gives more helpful error messages during testing...
AC.cl <- fread(paste0(clDir, "/AC-avhrr-only-v2.19810901-20180930_climatology.csv"),
               colClasses = list("numeric" = 1:3, "myDate" = 4, "numeric" = 5:7))

AC.ev <- ddply(clim, .(lon, lat), OISST_detect2, .parallel = TRUE, .progress = "text")
fwrite(AC.ev, file = paste0(evDir, "/AC-avhrr-only-v2.19810901-20180930_events.csv"))
remove(AC.cl); remove(AC.ev)
