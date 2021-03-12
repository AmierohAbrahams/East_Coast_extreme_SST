# The packages we will need
# install.packages("dplyr")
# install.packages("lubridate")
# install.packages("ggplot2")
# install.packages("tidync")
# install.packages("doParallel")
# install.packages("rerddap")
# install.packages("plyr") # Note that this library should never be loaded, only installed

# The packages we will use
library(dplyr) # A staple for modern data management in R
library(lubridate) # Useful functions for dealing with dates
library(ggplot2) # The preferred library for data visualisation
library(tidync) # For easily dealing with NetCDF data
library(rerddap) # For easily downloading subsets of data
library(doParallel) # For parallel processing

MUR_sub_dl <- function(time_df){
  MUR_dat <- griddap(x = "jplMURSST41", 
                       url = "https://coastwatch.pfeg.noaa.gov/erddap/", 
                       time = c(time_df$start, time_df$end), 
                       #zlev = c(0, 0),
                       latitude = c(-37.5, -27.5),
                       longitude = c(20, 35),
                       fields = "analysed_sst")$data %>% 
    mutate(time = as.Date(stringr::str_remove(time, "T00:00:00Z"))) %>% 
    dplyr::rename(t = time, temp = analysed_sst) %>% 
    select(lon, lat, t, temp) %>% 
    na.omit()
}


dl_years <- data.frame(date_index = 1:1,
                       start = as.Date(c("2002-06-01")),
                       end = as.Date(c("2021-03-05")))
system.time(
  MUR_data <- dl_years %>% 
    group_by(date_index) %>% 
    group_modify(~MUR_sub_dl(.x)) %>% 
    ungroup() %>% 
    select(lon, lat, t, temp)
) 

save(MUR_data, file = "data/MUR.RData")

MUR_data %>% 
  filter(t == "2003-06-01") %>% 
  ggplot(aes(x = lon, y = lat)) +
  geom_tile(aes(fill = temp)) +
  # borders() + # Activate this line to see the global map
  scale_fill_viridis_c() +
  coord_quickmap(expand = F) +
  labs(x = NULL, y = NULL, fill = "SST (°C)") +
  theme(legend.position = "bottom")
