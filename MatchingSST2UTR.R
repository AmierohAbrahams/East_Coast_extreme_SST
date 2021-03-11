# Matching remotely sensed SST to UTR

library(tidyverse)
library(ggpubr)
library(zoo)
library(lubridate)
library(ggrepel)
library(FNN)
library(stringr)
library(circular)
library(broom)
library(ggrepel)
library(purrr)
library(stlplus)

# Loading the SACTN data to identify sites

load("data/site_list_v4.2.RData")
load("data/OISST.RData")

OISST%>% 
  filter(t == "1982-01-01") %>% 
  ggplot(aes(x = lon, y = lat)) +
  geom_tile(aes(fill = temp)) +
  # borders() + # Activate this line to see the global map
  scale_fill_viridis_c() +
  coord_quickmap(expand = F) +
  labs(x = NULL, y = NULL, fill = "SST (°C)") +
  theme(legend.position = "bottom")

## Find nearest SST pixels
# Now we apply the FNN (Fast Nearest Neighbor) package to determine the nearesr SST pixel to the insitu collected sites. 
# In some cases however our sites are located close to eachother and as such more than one sites may have the same SST record.
# Here we use a pixel of 1. 

unique_pixel <- OISST %>% 
  select(lon, lat) %>%
  unique()

# Select 1 nearest pixel (k = 1)
# here we ue knnx to find the closes pixel to the insitu sites
match_index <- knnx.index(data = as.matrix(unique_pixel[,1:2]),
                          query = as.matrix(site_list[,5:6]), k = 1)

# Select SST pixels nearest to insitu sites
pixel_match <- unique_pixel[match_index,] %>%
  unite(col = combined, lon, lat, sep = "/", remove = F) %>%
  mutate(site = site_list$site)

OISST_matched <- right_join(OISST, filter(pixel_match), by = c("lon", "lat")) %>% 
  mutate(product = "OISST")
# save(OISST_matched, file = "data/OISST_matched.RData")













