require(fasttime)
library(plyr)

# functions.R

# a new date class
setClass('myDate')
setAs("character", "myDate", function(from) as.Date(fastPOSIXct(from, tz = NULL)))

# a fast date function
fastDate <- function(x, tz = NULL) {
  as.Date(fastPOSIXct(x, tz = tz))
}

# function to extract the dims
read_nc <- function(ncFile, region = region, csvDir = csvDir) {
  coords <- bbox[, region]
  nc <- nc_open(ncFile)
  pathLen <- nchar(ncDir) + 1 # to account for the "/" that needs to be inserted
  fNameStem <-
    substr(ncFile, pathLen + 1, pathLen + 13)
  fDate <- substr(ncFile, pathLen + 15, pathLen + 22)
  LatIdx <- which(nc$dim$lat$vals > coords[1] & nc$dim$lat$vals < coords[2])
  LonIdx <- which(nc$dim$lon$vals > coords[3] & nc$dim$lon$vals < coords[4])
  sst <- ncvar_get(nc,
                   varid = "sst",
                   start = c(LonIdx[1], LatIdx[1], 1, 1),
                   count = c(length(LonIdx), length(LatIdx), 1, 1)) %>%
    round(4)
  dimnames(sst) <- list(lon = nc$dim$lon$vals[LonIdx],
                        lat = nc$dim$lat$vals[LatIdx])
  nc_close(nc)
  sst <-
    as.data.frame(melt(sst, value.name = "temp"), row.names = NULL) %>%
    mutate(t = ymd(fDate)) %>%
    na.omit()
  fwrite(sst,
         file = paste(csvDir, "/", region, "-", fNameStem, ".", strtDate, "-", endDate, ".csv", sep = ""),
         append = TRUE)
  rm(sst)
}

# create grids
# testing...
# csvDir <- "/Users/ajsmit/spatial/OISSTv2/daily/csv"
# region <- "KC"
# byYear <- TRUE
#
setupGrid <- function(inDir, outDir, fName, byYear = TRUE) {
  require(lubridate)
  dat <- fread(paste0(inDir, "/", fName))
  region <- sapply(str_extract_all(fName, '\\b[A-Z]+\\b'), paste, collapse = ' ')
  # setkey(dat, NULL)
  lonVec <- unique(dat$lon)
  latVec <- unique(dat$lat)
  startDate <- as.Date(dat$t[1])
  endDate <- as.Date(dat$t[nrow(dat)])
  if (byYear) {
    timeVec <- year(seq(startDate, endDate, by = "year"))
  } else {
    timeVec <- seq(startDate, endDate, by = "day")
  }
  grid <- data.table(expand.grid(lon = lonVec, lat = latVec, year = timeVec))
  if (byYear) {
    fwrite(grid, file = paste0(outDir, "/", region, "_year_grid.csv"))
  } else {
    fwrite(grid, file = paste0(outDir, "/", region, "_day_grid.csv"))
  }
  rm(dat); rm(lonVec); rm(latVec); rm(timeVec); rm(startDate); rm(endDate)
}

# coords <- c(-45, -5, -60, -25)

# create shorelines
makeShore <- function(shoreDir, gshhsDir, region) {
  require(ggplot2)
  require(rgeos)
  require(maptools) # maptools must be loaded after rgeos
  lims <- bbox[, region]
  lats <- c(lims[1], lims[2])
  lons <- c(lims[3], lims[4])
  shore <- fortify(getRgshhsMap(paste0(gshhsDir, "/gshhs_f.b"),
                                xlim = lons, ylim = lats, level = 1, no.clip = FALSE, checkPolygons = TRUE))
  save(shore, file = paste0(shoreDir, "/", region, "-shore.Rdata"))
}

# create the basemap
baseMap <- function(shoreDir, shoreFile) {
  load(paste0(shoreDir, "/", shoreFile))
  region <- sapply(str_extract_all(shoreFile, "\\b[A-Z]+\\b"), paste, collapse = ' ')
  coords <- bbox[, region]
  ggplot(shore, aes(x = lon, y = lat)) +
    geom_polygon(aes(x = long, y = lat, group = group),
                 fill = "#929292", colour = "black", size = 0.1, show.legend = FALSE) +
    xlab("Longitude (°E)") +
    ylab("Latitude (°S)") +
    coord_fixed(ratio = 1,
                xlim = c(coords[3], coords[4]),
                ylim = c(coords[1], coords[2]), expand = FALSE) +
    theme_bw()
  ggsave(paste0(shoreDir, "/", region, "-shore.pdf"), width = 8, height = 8)
}

# A simple linear function (with Poissan option)
linFun <- function(annualEvent, poissan = FALSE) {
  if (poissan) {
    mod <- glm(y ~ year, family = poisson(link = "log"), data = annualEvent)
  }
  else {
    mod <- lm(y ~ year, data = annualEvent)
  }
  trend <- data.frame(slope = summary(mod)$coefficients[2,1] * 10,
                      pval = summary(mod)$coefficients[2,4])
  # trend <- summary(mod)$coefficients[2,c(1,4)]
  trend$pbracket <- cut(trend$pval, breaks = c(0, 0.001, 0.01, 0.05, 1))
  return(trend)
}

# the GLS-AR2 -------------------------------------------------------------
gls_fun <- function(df) {
  out <- tryCatch( {
    model <- gls(
      temp ~ num,
      correlation = corARMA(form = ~ 1 | year, p = 2),
      method = "REML",
      data = df, na.action = na.exclude
    )
    stats <-
      data.frame(
        DT_model = round(as.numeric(coef(model)[2]) * 120, 3),
        se_trend = round(summary(model)[["tTable"]][[2, 2]], 10),
        sd_initial = round(sd(df$temp, na.rm = TRUE), 2),
        sd_residual = round(sd(model$residuals), 2),
        r = NA,
        R2 = NA,
        p_trend = summary(model)[["tTable"]][[2, 4]],
        p_seas = NA,
        length = length(df$temp),
        model = "gls"
      )
    return(stats)
  },
  error = function(cond) {
    stats <- data.frame(
      DT_model = NA,
      se_trend = NA,
      sd_initial = round(sd(df$temp, na.rm = TRUE), 2),
      sd_residual = NA,
      r = NA,
      R2 = NA,
      p_trend = NA,
      p_seas = NA,
      length = length(df$temp),
      model = "gls"
    )
    return(stats)
  })
  rm(model)
  return(out)
}

# DETECT FUNCTION
## function to detect the events or create the climatology
# warmEvents <- as.data.table(ddply(sst, .(lon, lat), OISST_detect,
# warm = TRUE, clim = FALSE, .parallel = TRUE, .progress = "text"))
OISST_detect <- function(dat, cold_spells = FALSE, clim = FALSE,
                         climatology_start = "1983-01-01",
                         climatology_end = "2012-12-31") {
  require(RmarineHeatWaves)
  dat <- dat[,3:4]
  dat$time <- fastDate(dat$time)
  whole <- make_whole(dat, x = time, y = temp)
  if (clim) {
    out <- RmarineHeatWaves::detect(whole, x = time, y = temp, min_duration = 5, max_gap = 2, cold_spells = FALSE,
                  climatology_start = climatology_start,
                  climatology_end = climatology_end, clim_only = TRUE)
    return(out)
  } else {
    out <- RmarineHeatWaves::detect(whole, x = time, y = temp, min_duration = 5, max_gap = 2, cold_spells = FALSE,
                  climatology_start = climatology_start,
                  climatology_end = climatology_end, clim_only = FALSE)
  }
    event <- out$event
    return(event)
}

# DETECT FUNCTION using heatwaveR
OISST_detect2 <- function(dat) {
  require(heatwaveR)
  # dat$t <- fastDate(dat$t)
  out <- heatwaveR::detect_event(dat)
  event <- out$event
  return(event)
}

# functions to calculate mean Aviso+ velocity
oceFun1 <- function(data) {
  colnames(data) <- c("lon", "lat", "time", "ugos", "vgos", "ugosa", "vgosa", "sla", "adt")
  out <- data %>%
    # dplyr::mutate(lon = round(lon, 0),
    #               lat = round(lat, 0)) %>%
    dplyr::group_by(lon, lat) %>%
    dplyr::summarise(ugos = round(mean(ugos, na.rm = TRUE), 4),
                     vgos = round(mean(vgos, na.rm = TRUE), 4),
                     ugosa = round(mean(ugosa, na.rm = TRUE), 4),
                     vgosa = round(mean(vgosa, na.rm = TRUE), 4),
                     mean.adt = round(mean(adt, na.rm = TRUE), 4),
                     var.adt = round(sd(adt, na.rm = TRUE), 4),
                     mean.sla = round(mean(sla, na.rm = TRUE), 4),
                     var.sla = round(sd(sla, na.rm = TRUE), 4)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(velocity = round(sqrt((vgos^2) + (ugos^2)), 4),
                  eke = (0.5 * (ugos^2 + vgos^2)) -
                    (0.5 * (mean(ugos, na.rm = TRUE)^2 + mean(vgos, na.rm = TRUE)^2)),
                  arrow_size = round(((abs(ugos * vgos) / max(abs(ugos * vgos))) + 0.3) / 6, 4))
  return(out)
}


oceFun2 <- function(data) {
  out <- data %>%
    dplyr::mutate(lon = round(lon, 0),
                  lat = round(lat, 0)) %>%
    dplyr::group_by(lon, lat) %>%
    dplyr::summarise(ugos = mean(ugos, na.rm = TRUE),
                     vgos = mean(vgos, na.rm = TRUE),
                     velocity = mean(velocity, na.rm = TRUE)) %>%
    dplyr::ungroup()
  return(out)
}

