# MUR_onset_plot.R

# Setup -------------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(plyr)
library(ggpubr)
library(doParallel)
library(colorspace)
registerDoParallel(cores = 8)

base_URL <- "/Users/ajsmit/MEGA/data/East_Coast_extreme_SST/MUR"

hot_files <- list.files(path = base_URL, pattern = "_MHW_events.csv", recursive = TRUE, full.names = TRUE)
cold_files <- list.files(path = base_URL, pattern = "_MCS_events.csv", recursive = TRUE, full.names = TRUE)

load_fun <- function(file) {
  events <- read_csv(file)
  return(events)
}

MHW_events <- tibble(filename = hot_files) %>%
  mutate(file_contents = map(filename, ~ load_fun(.)),
         filename = basename(filename)) %>% 
  unnest(cols = file_contents)

MCS_events <- tibble(filename = cold_files) %>%
  mutate(file_contents = map(filename, ~ load_fun(.)),
         filename = basename(filename)) %>% 
  unnest(cols = file_contents)

MCS_events$class <- rep("cold", length = nrow(MCS_events))
MHW_events$class <- rep("hot", length = nrow(MHW_events))
plt.dat <- rbind(MCS_events, MHW_events)
rm(list = c("MHW_events", "MCS_events"))


# Make the plots ----------------------------------------------------------

source("R_scripts/MURregionDefinition.R")
source("R_scripts/plot_layers.R")
# source("R_scripts/plot_theme.R")

detail_xlim <- c(15, 35)
detail_ylim <- c(-36.25, -27.5)

plot <- plt.dat %>% 
  dplyr::filter(date_start >= "2021-01-01") %>%
  dplyr::group_by(lon, lat, class) %>% 
  dplyr::summarise(rate_onset = mean(rate_onset)) %>% 
  dplyr::ungroup() %>% 
  ggplot() +
  geom_tile(aes(x = lon, y = lat, fill = rate_onset)) +
  get("AC_layers_zoomed") +
  scale_fill_continuous_diverging(palette = "Blue-Red 3") +
  coord_sf(xlim = detail_xlim, ylim = detail_ylim, expand = FALSE) +
  guides(alpha = "none",
         fill = guide_colourbar(title = "[°C/day]",
                                frame.colour = "black",
                                frame.linewidth = 0.4,
                                ticks.colour = "black",
                                barheight = unit(50, units = "mm"),
                                barwidth = unit(4, units = "mm"),
                                draw.ulim = F,
                                title.position = 'top',
                                title.hjust = 0.5,
                                label.hjust = 0.5)) +
  labs(title = "MUR Extreme SST Mean Rate of Onset",
       subtitle = "2021-01-01 to 2021-03-23") +
  theme_map()

ggsave(filename = paste0("rate_onset_plot", ".jpg"),
       plot = plot, width = 2.6, height = 1.3125, scale = 2.6)


# Extremes: presence and absence ------------------------------------------

plot <- plt.dat %>% 
  dplyr::filter(date_start >= "2021-01-01") %>%
  dplyr::group_by(lon, lat, class) %>% 
  dplyr::summarise(rate_onset = mean(rate_onset)) %>% 
  dplyr::ungroup() %>% 
  ggplot() +
  geom_tile(aes(x = lon, y = lat, fill = class, colour = class), alpha = 0.6) +
  get("AC_layers_zoomed") +
  scale_fill_manual(values = c("blue", "red")) +
  scale_colour_manual(values = c("blue", "red")) +
  coord_sf(xlim = detail_xlim, ylim = detail_ylim, expand = FALSE) +
  guides(alpha = "none",
         colour = "none",
         fill = guide_legend(title = "Event\n type",
                                frame.colour = "black",
                                frame.linewidth = 0.4,
                                ticks.colour = "black",
                                barheight = unit(50, units = "mm"),
                                barwidth = unit(4, units = "mm"),
                                draw.ulim = F,
                                title.position = 'top',
                                title.hjust = 0.5,
                                label.hjust = 0.5)) +
  labs(title = "MUR Extreme SST Locations",
       subtitle = "2021-01-01 to 2021-03-23") +
  theme_map()

ggsave(filename = paste0("extremes_distribution", ".jpg"),
       plot = plot, width = 2.6, height = 1.3125, scale = 2.6)


# Number of events per pixel location -------------------------------------

plot <- plt.dat %>% 
  dplyr::filter(date_start >= "2021-01-01") %>% 
  dplyr::group_by(lon, lat, class) %>% 
  dplyr::mutate(event_no = (event_no - min(event_no)) + 1) %>% 
  dplyr::ungroup() %>% 
  ggplot() +
  geom_raster(aes(x = lon, y = lat, fill = event_no)) +
  get("AC_layers_zoomed") +
  scale_fill_continuous_sequential(palette = "Heat") +
  coord_sf(xlim = detail_xlim, ylim = detail_ylim, expand = FALSE) +
  guides(alpha = "none",
         colour = "none",
         fill = guide_legend(title = "Number\n of events",
                             frame.colour = "black",
                             frame.linewidth = 0.4,
                             ticks.colour = "black",
                             barheight = unit(50, units = "mm"),
                             barwidth = unit(4, units = "mm"),
                             draw.ulim = F,
                             title.position = 'top',
                             title.hjust = 0.5,
                             label.hjust = 0.5)) +
  labs(title = "MUR Extreme SST: number of events",
       subtitle = "2021-01-01 to 2021-03-23") +
  theme_map()

ggsave(filename = paste0("number_of_extremes", ".jpg"),
       plot = plot, width = 2.6, height = 1.3125, scale = 2.6)
  