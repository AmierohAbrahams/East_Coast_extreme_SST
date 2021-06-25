# 2.3.OISST_selected_events.R
# 
# Creates the following figures and tables:
# Table 1
# Table 2
# AJS Figure 2A,B,C
# AJS Figure 3
# AJS Figure 4

library(tidyverse)
library(colorspace)
library(ggpubr)
library(lubridate)
library(plyr)
library(heatwaveR)
library(data.table)
library(doParallel)
registerDoParallel(cores = 16)

base_URL <- "/Volumes/OceanData/Agulhas_MHW/OISST"
load(paste0(base_URL, "/", "OISST_EC.RData"))

source("R_scripts/bounding_boxes.R")

# focus only on DJFM
moi <- c(12, 1, 2, 3)


# Region 3 ----------------------------------------------------------------

# calculate the MHWs for Region 3, and uses this to determine the most intense
# MHWs during the instrumental era
# use these data to make Table1A
# use these data to create the event_line plots for the top 10 most intense MHWs
region3 <- OISST_data %>% 
  dplyr::filter(lon >= bbox$region3[3] & lon <= bbox$region3[4],
                lat >= bbox$region3[1] & lat <= bbox$region3[2]) %>% 
  dplyr::group_by(t) %>% 
  dplyr::summarise(temp = mean(temp)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(temp = temp - mean(temp))

region3_MHW_clim <- ts2clm(region3, x = t, y = temp,
                     climatologyPeriod = c("1982-01-01", "2011-12-31"),
                     robust = FALSE, maxPadLength = 3, windowHalfWidth = 5,
                     pctile = 90, smoothPercentile = TRUE,
                     smoothPercentileWidth = 31, clmOnly = FALSE)

region3_MHW <- detect_event(region3_MHW_clim, minDuration = 7)


# Same as above but for Region 2 MCSs -------------------------------------

region2 <- OISST_data %>% 
  dplyr::filter(lon >= bbox$region2[3] & lon <= bbox$region2[4],
                lat >= bbox$region2[1] & lat <= bbox$region2[2]) %>% 
  dplyr::group_by(t) %>% 
  dplyr::summarise(temp = mean(temp)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(temp = temp - mean(temp))

region2_MCS_clim <- ts2clm(region2, x = t, y = temp,
                     climatologyPeriod = c("1982-01-01", "2011-12-31"),
                     robust = FALSE, maxPadLength = 3, windowHalfWidth = 5,
                     pctile = 10, smoothPercentile = TRUE,
                     smoothPercentileWidth = 31, clmOnly = FALSE)

region2_MCS <- detect_event(region2_MCS_clim, minDuration = 7, coldSpells = TRUE)


# Produce Table 1 ---------------------------------------------------------

region3_MHW_sel <- region3_MHW$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>%
  group_by(year(date_start)) %>%
  dplyr::filter(intensity_cumulative == max(intensity_cumulative)) %>% 
  dplyr::select(duration:intensity_max, intensity_cumulative, rate_onset, rate_decline) %>% 
  dplyr::arrange(desc(intensity_cumulative)) %>% 
  # head(10) %>%
  ungroup()

region3_MHW_sel %>% 
  write.table(file = "selected_region3_MHW.csv")


# Produce Table 2 ---------------------------------------------------------

region2_MCS_sel <- region2_MCS$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>%
  group_by(year(date_start)) %>%
  dplyr::filter(intensity_cumulative == max(intensity_cumulative)) %>% 
  dplyr::select(duration:intensity_max, intensity_cumulative, rate_onset, rate_decline) %>% 
  dplyr::arrange(intensity_cumulative) %>% 
  # head(10) %>%
  ungroup()

region2_MCS_sel %>% 
  write.table(file = "selected_region2_MCS.csv")


# Produce Figure 2A -------------------------------------------------------

region3_MHW$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>% 
  ggplot(aes(x = date_start, y = intensity_cumulative)) +
  geom_lolli(aes(colour = duration), colour_n = "navy", n = 3) +
  scale_x_date(limits = as.Date(c("1982-01-01", "2021-04-30"))) +
  scale_colour_viridis_c(direction = -1, option = "C") +
  guides(colour = guide_legend(title = "Duration\n[days]")) +
  labs(title = "Marine heatwaves",
       subtitle = "Region 3, DJFM", 
    x = "Start Date",
       y = expression(paste("Cumulative intensity [", degree, "C]"))) +
  theme_bw()

# find the dates of the top 10 MHWs
MHW_years_sel_start <- region3_MHW_sel$date_start
MHW_years_sel_end <- region3_MHW_sel$date_end

sort(year(MHW_years_sel_start))


# i <- 1
# event_line(region3_MHW, spread = 180, metric = "intensity_cumulative", 
#            start_date = MHW_years_sel_start[i], end_date = MHW_years_sel_end[i])
# date1 <- MHW_years_sel_start[1]
# date2 <- MHW_years_sel_end[1]


# Produce Figure 2B -------------------------------------------------------

region2_MCS$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>% 
  ggplot(aes(x = date_start, y = intensity_cumulative)) +
  geom_lolli(aes(colour = duration), colour_n = "navy", n = 3) +
  scale_x_date(limits = as.Date(c("1982-01-01", "2021-04-30"))) +
  scale_colour_viridis_c(direction = -1, option = "C") +
  guides(colour = guide_legend(title = "Duration\n[days]")) +
  labs(title = "Marine cold spells",
       subtitle = " Region 2, DJFM", 
       x = "Start Date",
       y = expression(paste("Cumulative intensity [", degree, "C]"))) +
  theme_bw()


# Make Figure 2C ----------------------------------------------------------

# Find all years with MHWs
region3_MHW_sel2 <- region3_MHW$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>%
  group_by(year(date_start)) %>%
  dplyr::filter(intensity_cumulative == max(intensity_cumulative)) %>% 
  ungroup() %>% 
  dplyr::select(event_no, date_start) %>%
  dplyr::summarise(year = unique(year(date_start)))

all_events2 <- all_events %>% 
  dplyr::mutate(diff = RcppRoll::roll_mean(region3_temp - region2_temp, n = 10, align = "center", fill = NA),
                year = year(t)) %>% 
  dplyr::filter(month(t) %in% moi) %>% 
  dplyr::mutate(has_event = (year(t) %in% region3_MHW_sel2$year) * 1)

# Make the plot
ggplot(all_events2, aes(x = t, y = diff, group = year)) +
  geom_line(aes(colour = as.factor(has_event)), size = 0.2) +
  scale_colour_manual(values = c("black", "red")) +
  guides(colour = guide_legend(title = "Event",
                               frame.colour = "black",
                               frame.linewidth = 0.4,
                               ticks.colour = "black",
                               barheight = unit(50, units = "mm"),
                               barwidth = unit(4, units = "mm"),
                               draw.ulim = F,
                               title.position = 'top',
                               title.hjust = 0.5,
                               label.hjust = 0.5)) +
  labs(title = "Difference in temperature anomalies",
       subtitle = " Region 3 - Region 2, DJFM",
       y = "[°C]",
       x = NULL) +
  theme_bw()


# A function for the event_line graphs in Fig. 3 --------------------------

flames <- function(date1, date2) {
  data <- all_events %>% 
    dplyr::filter(t >= date1 - 60 & t <= date2 + 60)
  data_top <- all_events %>% 
    dplyr::filter(t >= date1 & t <= date2)
  plot <- ggplot(data = data, aes(x = t)) +
    # Region 3 MHWs
    geom_flame(aes(y = region3_temp, y2 = MHW_thresh, fill = "MHW_all"), show.legend = TRUE) +
    geom_flame(data = data_top, aes(y = region3_temp, y2 = MHW_thresh, fill = "MHW_top"),  show.legend = TRUE) +
    geom_line(aes(y = region3_temp, colour = "region3_temp")) +
    geom_line(aes(y = region3_seas, colour = "region3_seas"), size = 0.9) +
    geom_line(aes(y = MHW_thresh, colour = "MHW_thresh"), linetype = "dashed", size = 0.3) +
    # Region 2 MCSs
    geom_flame(aes(y = MCS_thresh, y2 = region2_temp, fill = "MCS_all"), show.legend = TRUE) +
    # geom_flame(data = data_top, aes(y = MCS_thresh, y2 = region2_temp, fill = "MCS_top"),  show.legend = TRUE) +
    geom_line(aes(y = region2_temp, colour = "region2_temp")) +
    geom_line(aes(y = region2_seas, colour = "region2_seas"), size = 0.9) +
    geom_line(aes(y = MCS_thresh, colour = "MCS_thresh"), linetype = "dashed", size = 0.3) +
    scale_colour_manual(name = "Line Colour",
                        values = c("region3_temp" = "red4",
                                   "region3_seas" = "red4",
                                   "MHW_thresh" =  "red4",
                                   "region2_temp" = "cyan4",
                                   "region2_seas" = "cyan4",
                                   "MCS_thresh" = "cyan4"),
                        labels = c("Temperature", "MMW Threshold",
                                   "Climatology", "MCS Threshold")) +
    scale_fill_manual(name = "Event Colour", 
                      values = c("MHW_all" = "salmon", 
                                 "MHW_top" = "red",
                                 "MCS_all" = "powderblue", 
                                 "MCS_top" = "blue")) +
    scale_x_date(date_labels = "%b %Y") +
    guides(colour = guide_legend(override.aes = list(fill = NA))) +
    labs(y = expression(paste("Temp. [", degree, "C]")), x = NULL) +
    theme_minimal()
  return(plot)
}


# Produce and assemble Fig. 3(A-J) ----------------------------------------
# marine heatwaves

all_events <- region3_MHW$climatology %>% 
  dplyr::select(doy:thresh) %>% 
  dplyr::rename(MHW_thresh = thresh,
                region3_seas = seas,
                region3_temp = temp) %>% 
  dplyr::mutate(MCS_thresh = region2_MCS$climatology$thresh,
                region2_seas = region2_MCS$climatology$seas,
                region2_temp = region2_MCS$climatology$temp)

plt1 <- flames(MHW_years_sel_start[1], MHW_years_sel_end[1])
plt2 <- flames(MHW_years_sel_start[2], MHW_years_sel_end[2])
plt3 <- flames(MHW_years_sel_start[3], MHW_years_sel_end[3])
plt4 <- flames(MHW_years_sel_start[4], MHW_years_sel_end[4])
plt5 <- flames(MHW_years_sel_start[5], MHW_years_sel_end[5])
plt6 <- flames(MHW_years_sel_start[6], MHW_years_sel_end[6])
plt7 <- flames(MHW_years_sel_start[7], MHW_years_sel_end[7])
plt8 <- flames(MHW_years_sel_start[8], MHW_years_sel_end[8])
plt9 <- flames(MHW_years_sel_start[9], MHW_years_sel_end[9])
plt10 <- flames(MHW_years_sel_start[10], MHW_years_sel_end[10])

# l <- get_legend(plt1)

combo_flame <- ggarrange(plt1 + theme_minimal() + theme(legend.position = 'none'),
                         plt2 + theme_minimal() + theme(legend.position = 'none'),
                         plt3 + theme_minimal() + theme(legend.position = 'none'),
                         plt4 + theme_minimal() + theme(legend.position = 'none'),
                         plt5 + theme_minimal() + theme(legend.position = 'none'),
                         plt6 + theme_minimal() + theme(legend.position = 'none'),
                         plt7 + theme_minimal() + theme(legend.position = 'none'),
                         plt8 + theme_minimal() + theme(legend.position = 'none'),
                         plt9 + theme_minimal() + theme(legend.position = 'none'),
                         plt10 + theme_minimal() + theme(legend.position = 'none'),
                         ncol = 2, nrow = 5, labels = "AUTO")


# Which years have no MHWs in DJFM Region 3? ------------------------------

region3_MHW_none <- region3_MHW$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>%
  group_by(year(date_start)) %>%
  dplyr::mutate(year = year(date_start)) %>% 
  ungroup() %>% 
  dplyr::summarise(year = unique(year)) %>% 
  dplyr::select(year)

no_MHW_years <- data.frame(all_years = seq(from = 1982, to = 2021, by = 1))
no_MHW_years$has_event <- no_MHW_years$all_years %in% region3_MHW_none$year

# no_MHW_years_sel <- sort(filter(no_MHW_years, has_event != TRUE)$all_years)
no_MHW_years_sel <- sort(sample(filter(no_MHW_years, has_event != TRUE)$all_years, 10))
# these were selected at random
# no_MHW_years_sel <- sort(c(2015, 1989, 2004, 1998, 2003, 1983, 1985, 1982, 1984, 1988))
no_MHW_years_sel_start <- as.Date(paste0(no_MHW_years_sel, "-02-15"))
no_MHW_years_sel_end <- as.Date(paste0(no_MHW_years_sel, "-02-25"))


# Figure 4,  years without MHWs -------------------------------------------

plt1 <- flames(no_MHW_years_sel_start[1], no_MHW_years_sel_end[1])
plt2 <- flames(no_MHW_years_sel_start[2], no_MHW_years_sel_end[2])
plt3 <- flames(no_MHW_years_sel_start[3], no_MHW_years_sel_end[3])
plt4 <- flames(no_MHW_years_sel_start[4], no_MHW_years_sel_end[4])
plt5 <- flames(no_MHW_years_sel_start[5], no_MHW_years_sel_end[5])
plt6 <- flames(no_MHW_years_sel_start[6], no_MHW_years_sel_end[6])
plt7 <- flames(no_MHW_years_sel_start[7], no_MHW_years_sel_end[7])
plt8 <- flames(no_MHW_years_sel_start[8], no_MHW_years_sel_end[8])
plt9 <- flames(no_MHW_years_sel_start[9], no_MHW_years_sel_end[9])
plt10 <- flames(no_MHW_years_sel_start[10], no_MHW_years_sel_end[10])

# l <- get_legend(plt1)

combo_flame_no_MHW <- ggarrange(plt1 + theme_minimal() + theme(legend.position = 'none'),
                         plt2 + theme_minimal() + theme(legend.position = 'none'),
                         plt3 + theme_minimal() + theme(legend.position = 'none'),
                         plt4 + theme_minimal() + theme(legend.position = 'none'),
                         plt5 + theme_minimal() + theme(legend.position = 'none'),
                         plt6 + theme_minimal() + theme(legend.position = 'none'),
                         plt7 + theme_minimal() + theme(legend.position = 'none'),
                         plt8 + theme_minimal() + theme(legend.position = 'none'),
                         plt9 + theme_minimal() + theme(legend.position = 'none'),
                         plt10 + theme_minimal() + theme(legend.position = 'none'),
                         ncol = 2, nrow = 5, labels = "AUTO")



# t-test btw cor coef of years with/without MHWs --------------------------

# Using data for 
# no_MHW_years_sel_start and MHW_years_sel_start
# correlation between Region 2 and Region 3
# compare with t-test between the two
no_MHW_years_sel_start
MHW_years_sel_start

data_no_ev <- all_events %>% 
  dplyr::filter(year(t) %in% year(no_MHW_years_sel_start),
                month(t) %in% moi) %>% 
  dplyr::mutate(year = year(t))

data_ev <- all_events %>% 
  dplyr::filter(year(t) %in% year(MHW_years_sel_start),
                month(t) %in% moi) %>% 
  dplyr::mutate(year = year(t))

cor_fun <- function(df) cor.test(df$region3_temp, df$region2_temp) %>% broom::tidy()

no_ev_cor <- data_no_ev %>% 
  group_by(year) %>% 
  nest() %>% 
  dplyr::mutate(model = map(data, cor_fun)) %>% 
  dplyr::select(-data) %>% unnest(cols = model)

ev_cor <- data_ev %>% 
  group_by(year) %>% 
  nest() %>% 
  dplyr::mutate(model = map(data, cor_fun)) %>% 
  dplyr::select(-data) %>% unnest(cols = model)

t.test(no_ev_cor$estimate, ev_cor$estimate)
