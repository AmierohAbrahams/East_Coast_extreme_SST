# Make world coastline ----------------------------------------------------

require(rgeos); require(maptools) # maptools must be loaded after rgeos
library(PBSmapping)
library(ggplot2)

gshhsDir <- "/Users/ajsmit/spatial/gshhg-bin-2.3.7"
lats <- c(-90, 90)
lons <- c(0, 360)
shore <- importGSHHS(paste0(gshhsDir, "/gshhs_l.b"), xlim = lons, ylim = lats, maxLevel = 1, useWest = FALSE)


# create a theme ----------------------------------------------------------

# library(extrafont)
theme_map <- function(...) {
  theme_minimal() +
    theme(
      axis.text = element_text(size = 10, color = "black"),
      axis.title = element_text(size = 10, color = "black"),
      legend.background = element_rect(colour = "black", size = 0.2),
      legend.position = c(0.093, 0.70),
      panel.background = element_rect(colour = NA, fill = "grey95"),
      panel.grid.major = element_line("grey40", linetype = "dotted", size = 0.2),
      panel.grid.minor = element_line("grey40", linetype = "dotted", size = 0.2),
      ...
    )
}

# library(extrafont)
theme_plot <- function(...) {
  theme_minimal() +
    theme(
      axis.text = element_text(size = 10, color = "black"),
      axis.title = element_text(size = 10, color = "black"),
      legend.background = element_rect(colour = "black", size = 0.2),
      legend.position = c(0.093, 0.70),
      panel.background = element_rect(colour = "black", fill = "grey95"),
      panel.grid.major = element_line("grey40", linetype = "dotted", size = 0.2),
      panel.grid.minor = element_blank(),
      ...
    )
}


# Colours -----------------------------------------------------------------

# 19 colours from:
# Backeberg, B. C., et al. (2012). Impact of intensified Indian Ocean
# winds on mesoscale variability in the Agulhas system.
# Nature Climate Change, 2(8), 608–612. http://doi.org/10.1038/nclimate1587
col1 <- c("#223D80", "#264C8B", "#285B97", "#2378AB", "#237AAF", "#348FBF",
          "#65ADD1", "#95CAE2", "#CBE6EF", "#FFFFFE", "#F3C9CA", "#E8969A",
          "#E06D71", "#D94A50", "#D6373C", "#D53136", "#D42B31", "#CD2830",
          "#B5282F")

# 16 colours from:
# Biastich et al (2008) Mesoscale perturbations control inter-ocean exchange
# south of Africa. Geophysical Research Letters, 35, L20602. http://doi:10.1029/2008GL035132
col3 <- c("#d6fefe", "#bcfdfe", "#acf1f7", "#a2d9ea", "#98c1de", "#8eaad0",
          "#8593c4", "#8a79ac", "#b85c71", "#eb483f", "#ed6137", "#ef7e35",
          "#f29d38", "#f5bc41", "#fadd4b", "#fffd54")

col1_51 <- colorRampPalette(col1)(51) # make more colours inbetween...

col2 <- c("#8600FF", "#3F94FE", "#77CAFD", "#99EEFF", "#D9FFD9", "#FFFFFF",
          "#FFFF4C", "#FFCC00", "#FF7E00", "#FF0000", "#5E0000")

cols15 <- c("#002b27", "#003a35", "#004943", "#005852", "#006861",
            "#007770", "#00867f", "#00958e", "#00a49e", "#00b3ad",
            "#00c2bd", "#00d2cd", "#00e1de", "#00f0ee", "#00ffff") #15 colours


# Topo map ----------------------------------------------------------------

# library(raster)
# library(rgdal)
# library(sp)
# library(dplyr)
#
# file_in <- "/Users/ajsmit/spatial/Natural_Earth_Data/SR_HR/SR_HR.tif"
# dem <- raster(file_in)
#
# # Prepare for ggplot2 (long format) and tidy up a bit
# dem_df <- as_tibble(as.data.frame(dem, xy = TRUE))
# names(dem_df) <- c("lon", "lat", "z")
# rm(dem)
xlim_AC <- c(-1.875, 53.125)
ylim_AC <- c(-52.5, -12.5)
# dem_AC <- dem_df %>%
#   filter(lon >= xlim_AC[1] & lon <=xlim_AC[2]) %>%
#   filter(lat >= ylim_AC[1] & lat <=ylim_AC[2])


# Find the subregion box extents ------------------------------------------

bx <- read.csv2("../setup/subRegions.csv")
AC.bx <- c(bx[1:9, c(4:7)])
BC.bx <- c(bx[10:18, c(4:7)])
EAC.bx <- c(bx[19:27, c(4:7)])
KC.bx <- c(bx[28:36, c(4:7)])
GS.bx <- c(bx[37:45, c(4:7)])


# Set the default plot options --------------------------------------------

AC.layers = list(
  geom_vline(xintercept = seq(10, 45, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_hline(yintercept = seq(-45, -20, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_polygon(data = shore, aes(x = X, y = Y, group = PID),
               colour = "#162b34", fill = "#162b34", size = 0.2),
  coord_fixed(ratio = 1, xlim = c(-1.875, 53.125), ylim = c(-52.5, -12.5), expand = TRUE),
  scale_x_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°E", sep = ""), breaks = c(10, 20, 30, 40)),
  scale_y_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°S", sep = ""), breaks = c(-45, -35, -25)),
  labs(x = NULL, y = NULL)
)

BC.layers = list(
  geom_vline(xintercept = seq(300, 335, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_hline(yintercept = seq(-40, -10, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_polygon(data = shore, aes(x = X, y = Y, group = PID),
               colour = "#162b34", fill = "#162b34", size = 0.2),
  coord_fixed(ratio = 1, xlim = c(290, 345), ylim = c(-45, -5), expand = TRUE),
  scale_x_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°E", sep = ""), breaks = c(300, 310, 320, 330)),
  scale_y_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°S", sep = ""), breaks = c(-40, -30, -20, -10)),
  labs(x = NULL, y = NULL)
)

EAC.layers <- list(
  geom_vline(xintercept = c(145, 150, 155, 160), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_hline(yintercept = seq(-40, -15, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_polygon(data = shore, aes(x = X, y = Y, group = PID),
               colour = "#162b34", fill = "#162b34", size = 0.2),
  coord_fixed(ratio = 1, xlim = c(125, 180), ylim = c(-48.75, -8.75), expand = TRUE),
  scale_x_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°E", sep = ""), breaks = c(145, 155)),
  scale_y_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°S", sep = ""), breaks = c(-40, -30, -20)),
  labs(x = NULL, y = NULL)
)

KC.layers <- list(
  geom_vline(xintercept = seq(125, 170, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_hline(yintercept = seq(20, 45, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_polygon(data = shore, aes(x = X, y = Y, group = PID),
               colour = "#162b34", fill = "#162b34", size = 0.2),
  coord_fixed(ratio = 1, xlim = c(120, 175), ylim = c(12.5, 52.5), expand = TRUE),
  scale_x_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°E", sep = ""), breaks = c(130, 140, 150, 160, 170)),
  scale_y_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°N", sep = ""), breaks = c(20, 30, 40)),
  labs(x = NULL, y = NULL)
)

GS.layers <- list(
  geom_vline(xintercept = seq(270, 320, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_hline(yintercept = seq(20, 50, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_polygon(data = shore, aes(x = X, y = Y, group = PID),
               colour = "#162b34", fill = "#162b34", size = 0.2),
  coord_fixed(ratio = 1, xlim = c(267.5, 322.5), ylim = c(15, 55), expand = TRUE),
  scale_x_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°E", sep = ""), breaks = c(275, 285, 295, 305, 315)),
  scale_y_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°N", sep = ""), breaks = c(20, 30, 40, 50)),
  labs(x = NULL, y = NULL)
)


