# LOading Libraries

# Setup -------------------------------------------------------------------
library(tidyverse)
library(lubridate)
library(heatwaveR)

# load the original data
# ("OISST_17march.RData")

# Detect the events in a time series
# ts <- ts2clm(OISST_17march, climatologyPeriod = c("1982-01-01", "2021-03-17"))
# mhw_OISST <- detect_event(ts)
# save(mhw_OISST, file = "mhw_OISST.RData")

load("/Users/ajsmit/MEGA/data/East_Coast_extreme_SST/OISST/mhw_OISST.RData")

# View just a few metrics
MHW_OISST_event <- mhw_OISST$event %>% 
  dplyr::ungroup() %>%
  dplyr::select(event_no, duration, date_start, date_peak, intensity_max, intensity_cumulative) 

MHW_OISST_clim <- mhw_OISST$climatology %>% 
  dplyr::ungroup() %>%
  dplyr::select(t, thresh, event,temp) %>% 
  filter(t >= "2021-01-01",
         event == TRUE)

#MCS's for the entire region

# ts_10th <- ts2clm(OISST_17march, climatologyPeriod = c("1982-01-01", "2021-03-17"), pctile = 10)
# mcs_OISST <- detect_event(ts_10th, coldSpells = TRUE)
# save(mcs_OISST, file = "mcs_OISST.RData")

load("/Users/ajsmit/MEGA/data/East_Coast_extreme_SST/OISST/mcs_OISST.RData")

# Looking at the events
MCS_OISST_event <- mcs_OISST$event %>% 
  dplyr::ungroup() %>%
  dplyr::select(event_no, duration, date_start,
                date_peak, intensity_mean, intensity_max, intensity_cumulative)

MCS_OISST_clim <- mcs_OISST$climatology %>% 
  dplyr::ungroup() %>%
  dplyr::select(t, thresh, event, temp) %>% 
  filter(t >= "2021-01-01",
         event == TRUE)

MCS_OISST_clim$class <- rep("cold", length = nrow(MCS_OISST_clim ))
MHW_OISST_clim$class <- rep("hot", length = nrow(MHW_OISST_clim))
plt.dat <- rbind(MCS_OISST_clim,MHW_OISST_clim)
plt.dat$exceedance <- plt.dat$temp - plt.dat$thresh

# Make the plots ----------------------------------------------------------

source("R_scripts/MURregionDefinition.R")
source("R_scripts/plot_layers.R")
source("R_scripts/plot_theme.R")

detail_xlim <- c(15, 35)
detail_ylim <- c(-36.25, -27.5)

dates <- c("2021-01-02", "2021-01-02")

anim_plot <- function(data) {
  
  plot <- ggplot() +
    geom_tile(data = plt.dat, aes(x = lon, y = lat, fill = temp - thresh)) +
    scale_fill_continuous_diverging(palette = "Blue-Red 3",
                                    limits = c(-2.3, 2.3), breaks = c(-2, -1, 0, 1, 2)) +
    coord_sf(xlim = detail_xlim, ylim = detail_ylim, expand = FALSE) +
    guides(alpha = "none",
           fill = guide_colourbar(title = "[°C]",
                                  frame.colour = "black",
                                  frame.linewidth = 0.4,
                                  ticks.colour = "black",
                                  barheight = unit(50, units = "mm"),
                                  barwidth = unit(4, units = "mm"),
                                  draw.ulim = F,
                                  title.position = 'top',
                                  title.hjust = 0.5,
                                  label.hjust = 0.5)) +
    labs(title = paste0("OISST Extreme SST", " ", unique(data$t))) +
    theme_map()
  
  ggsave(filename = paste0("animation/OISST_animation_sequence_",
                           as.character(unique(data$t)), ".jpg"),
         plot = plot, width = 2.6, height = 1.3125, scale = 2.6)
}

plt.dat %>%
  # dplyr::filter(t < "2021-01-03") %>%
  dplyr::group_split(t) %>%
  purrr::map(.f = anim_plot)


