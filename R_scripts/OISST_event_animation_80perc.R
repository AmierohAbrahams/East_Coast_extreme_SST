# MUR_event_plot.R

# Setup -------------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(plyr)
library(ggpubr)
library(doParallel)
library(colorspace)
registerDoParallel(cores = 16)

base_URL <- "/Users/ajsmit/MEGA/data/East_Coast_extreme_SST/OISST"

hot_files <- list.files(path = base_URL, pattern = "_MHW_protoevents_80perc.csv", recursive = TRUE, full.names = TRUE)
cold_files <- list.files(path = base_URL, pattern = "_MCS_protoevents_20perc.csv", recursive = TRUE, full.names = TRUE)

load_fun <- function(file) {
  events <- read_csv(file)
  return(events)
}

MHW_events <- tibble(filename = hot_files) %>%
  mutate(file_contents = map(filename, ~ load_fun(.)),
         filename = basename(filename)) %>% 
  unnest(cols = file_contents) %>% 
  filter(t >= "2021-01-01",
         event == TRUE)

MCS_events <- tibble(filename = cold_files) %>%
  mutate(file_contents = map(filename, ~ load_fun(.)),
         filename = basename(filename)) %>% 
  unnest(cols = file_contents) %>% 
  filter(t >= "2021-01-01",
         event == TRUE)

MCS_events$class <- rep("cold", length = nrow(MCS_events))
MHW_events$class <- rep("hot", length = nrow(MHW_events))
plt.dat <- rbind(MCS_events, MHW_events)
plt.dat$exceedance <- plt.dat$temp - plt.dat$thresh
rm(list = c("MHW_events", "MCS_events"))


# Make the plots ----------------------------------------------------------

source("R_scripts/plot_layers.R")
# source("R_scripts/plot_theme.R")

detail_xlim <- c(15, 35)
detail_ylim <- c(-36.25, -27.5)

dates <- c("2021-01-02", "2021-01-02")

anim_plot <- function(data) {
  
  plot <- ggplot() +
    geom_tile(data = data, aes(x = lon, y = lat, fill = temp - thresh)) +
    get("OISST_AC_layers_zoomed") +
    scale_fill_continuous_diverging(palette = "Blue-Red 3", mid = 0,
                                    limits = c(-3.2, 3.8), breaks = c(-3, -2, -1, 0, 1, 2, 3)) +
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
    labs(title = paste0("OISST Extreme SST (80th and 20th percentiles)"),
         subtitle = unique(data$t)) +
    theme_map()
  
  ggsave(filename = paste0("animation/OISST_animation_sequence_80perc_",
                                  as.character(unique(data$t)), ".jpg"),
         plot = plot, width = 2.6, height = 1.3125, scale = 2.6)
}

plt.dat %>%
  # dplyr::filter(t < "2021-01-03") %>%
  dplyr::group_split(t) %>%
  purrr::map(.f = anim_plot)


# Animate... --------------------------------------------------------------

# animate in the terminal using ffmpeg:
ffmpeg \
-framerate 5 \
-pattern_type glob -i 'OISST_*_80perc.jpg' \
-vf scale=1280:-2 \
OISST_Extreme_events_animate_80perc.mp4 \
;
