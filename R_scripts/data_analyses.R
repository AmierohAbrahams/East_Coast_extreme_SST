# Loading the libraries
library(tidyverse)
library(heatwaveR)
library(lubridate)

# Loading the data
load("~/Documents/Manuscripts/Heatwave_fish_deaths/SACTN_data_prep/site_list_v5.RData")
load("~/Documents/Manuscripts/Heatwave_fish_deaths/SACTN_data_prep/SACTN_v5.RData")

# Filtering out data for the three sites
# The three sites are: Port_St_Francis, Seaview and Thyspunt all along the south coast

selected_sites <- c("Port St Francis/SAEON","Seaview/SAEON", "Thyspunt/SAEON")
# Then calculate the statistics
SACTN_sites <- SACTN_v5 %>%
  filter(index %in% selected_sites)
# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Port St Francis
SACTN_port <- SACTN_sites %>% 
  filter(index =="Port St Francis/SAEON") %>% 
  arrange(date) %>% 
  dplyr::rename(t = date) %>% 
  dplyr::select(t, temp) %>% 
  ungroup() %>% 
  dplyr::select(-index)

# Detect the events in a time series
mhw_port <- ts2clm(SACTN_port, climatologyPeriod = c("2012-01-01", "2021-02-26"))
mhw_port_event <- detect_event(mhw_port)

# View just a few metrics
port_event <- mhw_port_event$event %>% 
  dplyr::ungroup() %>%
  dplyr::select(duration, date_start, date_peak,date_end, intensity_mean, intensity_max, intensity_cumulative, rate_onset, rate_decline) %>% 
  dplyr::arrange(intensity_cumulative) 

# Climatology
mhw_port_clim <- mhw_port_event$climatology
save(mhw_port_clim, file = "mhw_port_clim.Rdata")

seasons_port <- port_event %>%
  ungroup() %>% 
  mutate(month = month(date_start, abbr = T, label = T),
         year = year(date_start)) %>% 
  mutate(season = ifelse(month %in% c("Dec", "Jan", "Feb", "Mar"), "Summer",        
                         ifelse(month %in% c("Apr", "May", "Jun", "Jul"), "Autumn",
                                ifelse(month %in% c("Aug", "Sep", "Oct", "Nov"), "Spring","Error")))) %>% 
  filter(season == "Summer") %>% 
  mutate(site = "Port St Francis")


# -------------------------------------------------------------------------------------------------------------------------------------------------------
SACTN_seaview <- SACTN_sites %>% 
  filter(index =="Seaview/SAEON") %>% 
  arrange(date) %>% 
  dplyr::rename(t = date) %>% 
  dplyr::select(t, temp) %>% 
  ungroup() %>% 
  dplyr::select(-index)

# Detect the events in a time series
mhw_seaview <- ts2clm(SACTN_seaview, climatologyPeriod = c("2012-01-01", "2021-02-26"))
mhw_seaview_event <- detect_event(mhw_seaview)

# View just a few metrics
seaview_event <- mhw_seaview_event$event %>% 
  dplyr::ungroup() %>%
  dplyr::select(duration, date_start, date_peak,date_end, intensity_mean, intensity_max, intensity_cumulative, rate_onset, rate_decline) %>% 
  dplyr::arrange(intensity_cumulative) 

# Climatology
mhw_seaview_clim <- mhw_seaview_event$climatology
save(mhw_seaview_clim, file = "mhw_seaview_clim.Rdata")


seasons_seaview <- seaview_event %>%
  ungroup() %>% 
  mutate(month = month(date_start, abbr = T, label = T),
         year = year(date_start)) %>% 
  mutate(season = ifelse(month %in% c("Dec", "Jan", "Feb", "Mar"), "Summer",        
                         ifelse(month %in% c("Apr", "May", "Jun", "Jul"), "Autumn",
                                ifelse(month %in% c("Aug", "Sep", "Oct", "Nov"), "Spring","Error")))) %>% 
  filter(season == "Summer") %>% 
  mutate(site = "Seaview")

# ---------------------------------------------------------------------------------------------------------------------------------------------

SACTN_Thyspunt <- SACTN_sites %>% 
  filter(index =="Thyspunt/SAEON") %>% 
  arrange(date) %>% 
  dplyr::rename(t = date) %>% 
  dplyr::select(t, temp) %>% 
  ungroup() %>% 
  dplyr::select(-index)

# Detect the events in a time series
mhw_Thyspunt <- ts2clm(SACTN_Thyspunt, climatologyPeriod = c("2012-01-01", "2021-02-26"))
mhw_Thyspunt_event <- detect_event(mhw_Thyspunt)

# View just a few metrics
Thyspunt_event <- mhw_Thyspunt_event$event %>% 
  dplyr::ungroup() %>%
  dplyr::select(duration, date_start, date_peak,date_end, intensity_mean, intensity_max, intensity_cumulative, rate_onset, rate_decline) %>% 
  dplyr::arrange(intensity_cumulative) 

# Climatology
mhw_Thyspunt_clim <- mhw_Thyspunt_event$climatology
save(mhw_Thyspunt_clim, file = "mhw_Thyspunt_clim.Rdata")

  
seasons_Thyspunt <- Thyspunt_event %>%
  ungroup() %>% 
  mutate(month = month(date_start, abbr = T, label = T),
         year = year(date_start)) %>% 
  mutate(season = ifelse(month %in% c("Dec", "Jan", "Feb", "Mar"), "Summer",        
                         ifelse(month %in% c("Apr", "May", "Jun", "Jul"), "Autumn",
                                ifelse(month %in% c("Aug", "Sep", "Oct", "Nov"), "Spring","Error")))) %>% 
  filter(season == "Summer") %>% 
  mutate(site = "Thyspunt")

# Combining marine heatwaves

MHW <- rbind(seasons_port, seasons_seaview, seasons_Thyspunt)
save(MHW, file = "MHW.RData")

# -------------------------------------------------------------------------------------------------------------------------------------------------

## Marine coldspells and climatology
mcs_port <- ts2clm(SACTN_port, climatologyPeriod = c("2012-01-01", "2021-02-26"), pctile = 10)
mcs_port_event <- detect_event(mcs_port, coldSpells = TRUE)

# Climatology
mcs_port_clim <- mcs_port_event$climatology
save(mcs_port_clim, file = "mcs_port_clim.Rdata")

  
# View just a few metrics
mcs_port_event <- mcs_port_event$event %>% 
  dplyr::ungroup() %>%
  dplyr::select(duration, date_start, date_peak,date_end, intensity_mean, intensity_max, intensity_cumulative, rate_onset, rate_decline) %>% 
  dplyr::arrange(intensity_cumulative) 
  
  
seasons_port_mcs <- mcs_port_event %>%
  ungroup() %>% 
  mutate(month = month(date_start, abbr = T, label = T),
         year = year(date_start)) %>% 
  mutate(season = ifelse(month %in% c("Dec", "Jan", "Feb", "Mar"), "Summer",        
                         ifelse(month %in% c("Apr", "May", "Jun", "Jul"), "Autumn",
                                ifelse(month %in% c("Aug", "Sep", "Oct", "Nov"), "Spring","Error")))) %>% 
  filter(season == "Summer") %>% 
  mutate(site = "Port St Francis")

# --------------------------------------------------------------------------------------------------------------------------------------------------------

SACTN_seaview <- SACTN_sites %>% 
  filter(index =="Seaview/SAEON") %>% 
  arrange(date) %>% 
  dplyr::rename(t = date) %>% 
  dplyr::select(t, temp) %>% 
  ungroup() %>% 
  dplyr::select(-index)

# Detect the events in a time series
mcs_seaview <- ts2clm(SACTN_seaview, climatologyPeriod = c("2012-01-01", "2021-02-26"), pctile = 10)
mcs_seaview_event <- detect_event(mcs_seaview, coldSpells = TRUE)

# Climatology
mcs_seaview_clim <- mcs_seaview_event$climatology
save(mcs_seaview_clim, file = "mcs_seaview_clim.Rdata")

# View just a few metrics
mcs_seaview_event <- mcs_seaview_event$event %>% 
  dplyr::ungroup() %>%
  dplyr::select(duration, date_start, date_peak,date_end, intensity_mean, intensity_max, intensity_cumulative, rate_onset, rate_decline) %>% 
  dplyr::arrange(intensity_cumulative) 

seasons_seaview_mcs <- mcs_seaview_event %>%
  ungroup() %>% 
  mutate(month = month(date_start, abbr = T, label = T),
         year = year(date_start)) %>% 
  mutate(season = ifelse(month %in% c("Dec", "Jan", "Feb", "Mar"), "Summer",        
                         ifelse(month %in% c("Apr", "May", "Jun", "Jul"), "Autumn",
                                ifelse(month %in% c("Aug", "Sep", "Oct", "Nov"), "Spring","Error")))) %>% 
  filter(season == "Summer") %>% 
  mutate(site = "Seaview")

# ---------------------------------------------------------------------------------------------------------------------------------------------

SACTN_Thyspunt <- SACTN_sites %>% 
  filter(index =="Thyspunt/SAEON") %>% 
  arrange(date) %>% 
  dplyr::rename(t = date) %>% 
  dplyr::select(t, temp) %>% 
  ungroup() %>% 
  dplyr::select(-index)

# Detect the events in a time series
mcs_Thyspunt <- ts2clm(SACTN_Thyspunt, climatologyPeriod = c("2012-01-01", "2021-02-26"),  pctile = 10)
mcs_Thyspunt_event <- detect_event(mcs_Thyspunt,  coldSpells = TRUE)

# climatology
mcs_Thyspunt_clim <- mcs_Thyspunt_event$climatology 
save(mcs_Thyspunt_clim, file = "mcs_Thyspunt_clim.Rdata")


# View just a few metrics
mcs_Thyspunt_event <- mcs_Thyspunt_event$event %>% 
  dplyr::ungroup() %>%
  dplyr::select(duration, date_start, date_peak,date_end, intensity_mean, intensity_max, intensity_cumulative, rate_onset, rate_decline) %>% 
  dplyr::arrange(intensity_cumulative) 

seasons_Thyspunt_mcs <- mcs_Thyspunt_event %>%
  ungroup() %>% 
  mutate(month = month(date_start, abbr = T, label = T),
         year = year(date_start)) %>% 
  mutate(season = ifelse(month %in% c("Dec", "Jan", "Feb", "Mar"), "Summer",        
                         ifelse(month %in% c("Apr", "May", "Jun", "Jul"), "Autumn",
                                ifelse(month %in% c("Aug", "Sep", "Oct", "Nov"), "Spring","Error")))) %>% 
  filter(season == "Summer") %>% 
  mutate(site = "Thyspunt")

# Combining marine coldspells
MCS <- rbind(seasons_port_mcs, seasons_seaview_mcs, seasons_Thyspunt_mcs)
save(MCS, file = "MCS.RData")

# ------------------------------------------------------------------------------------------------------------------------



