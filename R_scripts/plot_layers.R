# Make world coastline ----------------------------------------------------

library(rnaturalearth)
library(sp)

world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)


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
# Biastoch et al (2008) Mesoscale perturbations control inter-ocean exchange
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


# Bathy data --------------------------------------------------------------

bathy <- data.table::fread("~/MEGA/data/GEBCO_2014_Grid/AC_bathy.csv")
xlim_AC <- range(bathy$lon)
ylim_AC <- range(bathy$lat)


# Zones of influence ------------------------------------------------------

load("data/setup/AC-mask_polys.RData")
mke <- fortify(mask.list$mke)
eke <- fortify(mask.list$eke)
int <- fortify(mask.list$int)


# Set the default plot options --------------------------------------------

AC_layers = list(
  geom_contour(
    data = bathy, aes(x = lon, y = lat, z = z),
    col = "black", size = 0.15, breaks = c(-500, -1000, -2000),
    show.legend = FALSE, global.breaks = FALSE
  ),
  geom_vline(xintercept = seq(10, 45, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_hline(yintercept = seq(-45, -20, 5), linetype = "dotted", size = 0.2, colour = "grey40"),
  geom_sf(data = world, colour = "#162b34", fill = "#162b34", size = 0.2),
  coord_sf(xlim = xlim_AC, ylim = ylim_AC, expand = FALSE),
  scale_x_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°E", sep = ""), breaks = c(10, 20, 30, 40)),
  scale_y_continuous(expand = c(0, 0), labels = scales::unit_format(unit = "°S", sep = ""), breaks = c(-45, -35, -25)),
  labs(x = NULL, y = NULL)
)