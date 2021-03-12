# MUR_1km_download.R


# Setup -------------------------------------------------------------------

.libPaths(c("~/R-packages", .libPaths()))
library(tidyverse)
library(lubridate)
library(tidync)
library(doParallel)
registerDoParallel(cores = 50)
# library(ncdf4)

# File location
base_URL <- "https://podaac-opendap.jpl.nasa.gov/opendap/allData/ghrsst/data/GDS2/L4/GLOB/JPL/MUR/v4.1"


# Download ----------------------------------------------------------------

# Function for downloading a given subset from a desired date
download_MUR_1km <- function(file_date, lon_range, lat_range){
  
  file_name <- paste0(base_URL,"/",year(file_date),"/",yday(file_date),"/",
                      gsub("-", "", file_date),"090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc")
  suppressWarnings( # I think the tidync function does something funny with the remote access
    MUR_dat <- tidync(file_name) %>%
      hyper_filter(lon = between(lon, lon_range[1], lon_range[2]),
                   lat = between(lat, lat_range[1], lat_range[2])) %>% 
      hyper_tibble() %>% 
      select(lon, lat, time, analysed_sst) %>% 
      dplyr::rename(t = time, temp = analysed_sst) %>% 
      na.omit() %>% 
      mutate(t = as.Date(as.POSIXct(t, origin = "1981-01-01 00:00:00.0")),
             temp = temp-273.15) # Convert from K to C
  )
  return(MUR_dat)
}

# Download all dates
EC_MUR <- plyr::ldply(seq(as.Date("2002-06-01"), as.Date("2021-03-05"), by = "day"), download_MUR_1km,
                      .parallel = F, lon_range = c(20, 35), lat_range = c(-37.5, -27.5))

