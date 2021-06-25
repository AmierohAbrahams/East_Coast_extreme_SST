# Loading libraries
library(tidyverse)
library(ggpubr)


# Loading in MHW and MCS data
load("data/MCS.RData")
load("data/MHW.RData")

# Loading in the climatology data
# MHW
load("data/mhw_Thyspunt_clim.Rdata")
load("data/mhw_seaview_clim.Rdata")
load("data/mhw_port_clim.Rdata")

# MCS

load("data/mcs_seaview_clim.Rdata")
load("data/mcs_Thyspunt_clim.Rdata")
load("data/mcs_port_clim.Rdata")

moi <- c(12, 1, 2, 3)


# ---------------------------------------------------------------------------------------------------------------------------------------
# Creating the MHW and MCS table

# Table of marine cold spells
MCS <- MCS %>% 
  dplyr::select(site,duration, date_start, date_peak, date_end, intensity_mean, intensity_max, intensity_cumulative, rate_onset, rate_decline)

MCS %>%
  write.table(file = "MCS.csv")

# Table of marine heatwaves

MHW <- MHW %>% 
  dplyr::select(site,duration, date_start, date_peak, date_end, intensity_mean, intensity_max, intensity_cumulative, rate_onset, rate_decline)

MHW %>% 
  write.table(file = "MHW.csv")
# ---------------------------------------------------------------------------------------------------------------------------------------_
# Creating the plots Figure 2 matchin AJ
# Data used in this section can be found on the data_analyses.R script

plot1 <- mhw_seaview_event$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>% 
  ggplot(aes(x = date_start, y = intensity_cumulative)) +
  geom_lolli(aes(colour = duration), colour_n = "navy", n = 3) +
  scale_x_date(limits = as.Date(c("2012-01-01", "2021-04-30"))) +
  scale_colour_viridis_c(direction = -1, option = "C") +
  guides(colour = guide_legend(title = "Duration\n[days]")) +
  labs(title = "Marine heatwaves",
       subtitle = "Seaview, DJFM", 
       x = "Start Date",
       y = expression(paste("Cumulative intensity [", degree, "C]"))) +
  theme_bw()

plot2 <- mhw_Thyspunt_event$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>% 
  ggplot(aes(x = date_start, y = intensity_cumulative)) +
  geom_lolli(aes(colour = duration), colour_n = "navy", n = 3) +
  scale_x_date(limits = as.Date(c("2012-01-01", "2021-04-30"))) +
  scale_colour_viridis_c(direction = -1, option = "C") +
  guides(colour = guide_legend(title = "Duration\n[days]")) +
  labs(title = "Marine heatwaves",
       subtitle = "Thyspunt, DJFM", 
       x = "Start Date",
       y = expression(paste("Cumulative intensity [", degree, "C]"))) +
  theme_bw()

plot3 <- mhw_port_event$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>% 
  ggplot(aes(x = date_start, y = intensity_cumulative)) +
  geom_lolli(aes(colour = duration), colour_n = "navy", n = 3) +
  scale_x_date(limits = as.Date(c("2012-01-01", "2021-04-30"))) +
  scale_colour_viridis_c(direction = -1, option = "C") +
  guides(colour = guide_legend(title = "Duration\n[days]")) +
  labs(title = "Marine heatwaves",
       subtitle = "Port St Francis, DJFM", 
       x = "Start Date",
       y = expression(paste("Cumulative intensity [", degree, "C]"))) +
  theme_bw()

combined_MHW <- ggarrange(plot1, plot2,plot3, ncol =1)
ggsave(filename = "combined_MHW.jpg", plot = combined_MHW, width=180, height = 200, units = "mm",dpi = 300)

# -------------------------------------------------------------------------------------------------------------------------------------
# Marine coldspells Figure 2 matchin AJ

plot1_mcs <- mcs_seaview_event$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>% 
  ggplot(aes(x = date_start, y = intensity_cumulative)) +
  geom_lolli(aes(colour = duration), colour_n = "navy", n = 3) +
  scale_x_date(limits = as.Date(c("2012-01-01", "2021-04-30"))) +
  scale_colour_viridis_c(direction = -1, option = "C") +
  guides(colour = guide_legend(title = "Duration\n[days]")) +
  labs(title = "Marine coldspells",
       subtitle = "Seaview, DJFM", 
       x = "Start Date",
       y = expression(paste("Cumulative intensity [", degree, "C]"))) +
  theme_bw()

plot2_mcs <- mcs_Thyspunt_event$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>% 
  ggplot(aes(x = date_start, y = intensity_cumulative)) +
  geom_lolli(aes(colour = duration), colour_n = "navy", n = 3) +
  scale_x_date(limits = as.Date(c("2012-01-01", "2021-04-30"))) +
  scale_colour_viridis_c(direction = -1, option = "C") +
  guides(colour = guide_legend(title = "Duration\n[days]")) +
  labs(title = "Marine coldspells",
       subtitle = "Thyspunt, DJFM", 
       x = "Start Date",
       y = expression(paste("Cumulative intensity [", degree, "C]"))) +
  theme_bw()

plot3_mcs <- mcs_port_event$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>% 
  ggplot(aes(x = date_start, y = intensity_cumulative)) +
  geom_lolli(aes(colour = duration), colour_n = "navy", n = 3) +
  scale_x_date(limits = as.Date(c("2012-01-01", "2021-04-30"))) +
  scale_colour_viridis_c(direction = -1, option = "C") +
  guides(colour = guide_legend(title = "Duration\n[days]")) +
  labs(title = "Marine colspells",
       subtitle = "Port St Francis, DJFM", 
       x = "Start Date",
       y = expression(paste("Cumulative intensity [", degree, "C]"))) +
  theme_bw()

combined_MCS <- ggarrange(plot1_mcs, plot2_mcs,plot3_mcs, ncol =1)
ggsave(filename = "combined_MCS.jpg", plot = combined_MCS, width=180, height = 200, units = "mm",dpi = 300)

# ------------------------------------------------------------------------------------------------------------------------------------
# Figure 3:
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

region3_MHW_sel <- mhw_seaview_event$event %>% 
  dplyr::filter(month(date_start) %in% moi) %>%
  group_by(year(date_start)) %>%
  dplyr::filter(intensity_cumulative == max(intensity_cumulative)) %>% 
  dplyr::select(duration:intensity_max, intensity_cumulative, rate_onset, rate_decline) %>% 
  dplyr::arrange(desc(intensity_cumulative)) %>% 
  # head(10) %>%
  ungroup()

MHW_years_sel_start <- region3_MHW_sel$date_start
MHW_years_sel_end <- region3_MHW_sel$date_end

sort(year(MHW_years_sel_start))

clim <- mhw_seaview_event$climatology

mhw_seaview_event = clim[-c(2200:2229),]

all_events <- mhw_seaview_event %>% 
  dplyr::select(doy:thresh) %>% 
  dplyr::rename(MHW_thresh = thresh,
                region3_seas = seas,
                region3_temp = temp) %>% 
  dplyr::mutate(MCS_thresh = mcs_Thyspunt_event$climatology$thresh,
                region2_seas = mcs_Thyspunt_event$climatology$seas,
                region2_temp = mcs_Thyspunt_event$climatology$temp)

plt1 <- flames(MHW_years_sel_start[1], MHW_years_sel_end[1])
plt2 <- flames(MHW_years_sel_start[2], MHW_years_sel_end[2])
plt3 <- flames(MHW_years_sel_start[3], MHW_years_sel_end[3])
plt4 <- flames(MHW_years_sel_start[4], MHW_years_sel_end[4])
plt5 <- flames(MHW_years_sel_start[5], MHW_years_sel_end[5])

# l <- get_legend(plt1)

combo_flame <- ggarrange(plt1 + theme_minimal() + theme(legend.position = 'none'),
                         plt2 + theme_minimal() + theme(legend.position = 'none'),
                         plt3 + theme_minimal() + theme(legend.position = 'none'),
                         plt4 + theme_minimal() + theme(legend.position = 'none'),
                         plt5 + theme_minimal() + theme(legend.position = 'none'),
                         ncol = 2, nrow = 3, labels = "AUTO")


ggsave(filename = "combo_flame.jpg", plot = combo_flame, width=180, height = 200, units = "mm",dpi = 300)
















