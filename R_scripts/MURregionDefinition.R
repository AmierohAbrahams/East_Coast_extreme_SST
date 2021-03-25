# regionDefinition.R

# MUR subreggions
bbox <- data.frame(region1 = c(-34.9, -32.3, 17.6, 20), # Cape Agulhas to St Helena Bay
                   region2 = c(-34.5, -32.8, 24.6, 28.1), # Cape St Francis to East London
                   region3 = c(-31.2, -29.8, 30.1, 31.7), # Durban to Port Edward
                   row.names = c("latmin", "latmax", "lonmin", "lonmax"))


# MUR Download
# 
# -b lonmin lonmax latmin latmax
# 
# 1. Cape Peninsula Region
# 1.1 python 2.7 script
# ./subset_dataset.py -s 20020601 -f 20210320 -b 18.0 19.0 -34.5 -33.8 -x MUR-JPL-L4-GLOB-v4.1
# 
# 1.2 THREDDS data server request
# Data Access >> THREDDS >> NetcdfSubset: /thredds/ncss/grid/OceanTemperature/MUR-JPL-L4-GLOB-v4.1.nc
# Select analysed_sst, analysis_error, mask
# north = -33.8
# south = -34.5
# east = 18
# west = 19
# start = 2002-06-01T09:00:00Z
# end = 2021-03-23T09:00:00Z
# Add 2D Lat/Lon to file (if needed for CF compliance)
# 
# https://thredds.jpl.nasa.gov/thredds/ncss/OceanTemperature/MUR-JPL-L4-GLOB-v4.1.nc?var=analysed_sst&var=analysis_error&var=mask&north=-33.8&west=18&east=19&south=-34.5&disableProjSubset=on&horizStride=1&time_start=2002-06-01T09%3A00%3A00Z&time_end=2021-03-23T09%3A00%3A00Z&timeStride=1&addLatLon=true
# 
# 2. Cape Agulhas to St. Helena Bay Region
# 2.1 python 2.7 script
# ./subset_dataset.py -s 20020601 -f 20210320 -b 17.6 20 -34.9 -32.3 -x MUR-JPL-L4-GLOB-v4.1
# 
# 2.2 THREDDS data server request
# Data Access >> THREDDS >> NetcdfSubset: /thredds/ncss/grid/OceanTemperature/MUR-JPL-L4-GLOB-v4.1.nc
# Select analysed_sst, analysis_error, mask
# north = -32.3
# south = -34.9
# east = 20
# west = 17.6
# start = 2002-06-01T09:00:00Z
# end = 2021-03-23T09:00:00Z
# Add 2D Lat/Lon to file (if needed for CF compliance)
# 
# https://thredds.jpl.nasa.gov/thredds/ncss/OceanTemperature/MUR-JPL-L4-GLOB-v4.1.nc?var=analysed_sst&var=analysis_error&north=-32.3&west=17.6&east=20&south=-34.9&disableProjSubset=on&horizStride=1&time_start=2002-06-01T09%3A00%3A00Z&time_end=2021-03-23T09%3A00%3A00Z&timeStride=1&addLatLon=true
# 
# 3. Cape St. Francis to East London Region
# 3.1 python 2.7 script
# ./subset_dataset.py -s 20020601 -f 20210320 -b 24.6 28.1 -34.5 -32.8 -x MUR-JPL-L4-GLOB-v4.1
# 
# 3.2 THREDDS data server request
# Data Access >> THREDDS >> NetcdfSubset: /thredds/ncss/grid/OceanTemperature/MUR-JPL-L4-GLOB-v4.1.nc
# Select analysed_sst, analysis_error, mask
# north = -32.8
# south = -34.5
# east = 28.1
# west = 24.6
# start = 2002-06-01T09:00:00Z
# end = 2021-03-23T09:00:00Z
# Add 2D Lat/Lon to file (if needed for CF compliance)
# 
# https://thredds.jpl.nasa.gov/thredds/ncss/OceanTemperature/MUR-JPL-L4-GLOB-v4.1.nc?var=analysed_sst&var=analysis_error&north=-32.8&west=24.6&east=28.1&south=-34.5&horizStride=1&time_start=2002-06-01T09%3A00%3A00Z&time_end=2021-03-23T09%3A00%3A00Z&timeStride=1&addLatLon=true
# 
# 4. Durban to Port Edward Region
# 4.1 python 2.7 script
# ./subset_dataset.py -s 20020601 -f 20210320 -b 31.7 30.1 -31.2 -29.8 -x MUR-JPL-L4-GLOB-v4.1
# 
# 4.2 THREDDS data server request
# Data Access >> THREDDS >> NetcdfSubset: /thredds/ncss/grid/OceanTemperature/MUR-JPL-L4-GLOB-v4.1.nc
# Select analysed_sst, analysis_error, mask
# north = -29.8
# south = -31.2
# east = 31.7
# west = 30.1
# start = 2002-06-01T09:00:00Z
# end = 2021-03-23T09:00:00Z
# Add 2D Lat/Lon to file (if needed for CF compliance)
# 
# https://thredds.jpl.nasa.gov/thredds/ncss/OceanTemperature/MUR-JPL-L4-GLOB-v4.1.nc?var=analysed_sst&var=analysis_error&north=-29.8&west=30.1&east=31%2C7&south=-31.2&horizStride=1&time_start=2002-06-01T09%3A00%3A00Z&time_end=2021-03-23T09%3A00%3A00Z&timeStride=1&addLatLon=true
