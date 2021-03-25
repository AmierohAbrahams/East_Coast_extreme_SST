# regionDefinition.R

bbox <- data.frame(AC = c(-45, -20, 6.25, 45), # Agulhas Current
                   # BC = c(-45, -5, -60, -25), # Brazil Current (works with gshhs)
                   BC = c(-45, -5, 300, 335), # Brazil Current (works with SST data)
                   EAC = c(-42.5, -15, 145, 160), # East Australian Current
                   GS = c(20, 50, 270, 320), # Gulf Stream (or 270-360 and 320-360 for AVISO+ data)
                   # KC = c(5, 60, 120, 180), # Kuroshio Current (wide)
                   KC = c(20, 45, 120, 175), # Kuroshio Current (narrow)
                   BenC = c(-35, -25, 15, 20), # Benguela Current
                   row.names = c("latmin", "latmax", "lonmin", "lonmax"))

# Below is for the full extent of the figures under "WBCs";
# the extent is such that:
# latRng <- 40
# lonRng <- 55
# the bounding boxes containing the gridded data are smaller subset of the full figure
# axes range, below:

bbox2 <- data.frame(AC        = c(-52.5,        -12.5,      -1.875,     53.125), # Agulhas Current
                   # BC       = c(-45,        -5,         -60,        -25), # Brazil Current (works with gshhs)
                   BC         = c(-45,          -5,         290,        345), # Brazil Current (works with SST data)
                   EAC        = c(-48.75,       -8.75,      125,        180), # East Australian Current
                   GS         = c(15,           55,         267.5,      322.5), # Gulf Stream
                   # KC       = c(5,            60,         120,        180), # Kuroshio Current (wide)
                   KC         = c(12.5,         52.5,       120,        175), # Kuroshio Current (narrow)
                   row.names  = c("latmin",     "latmax",   "lonmin",   "lonmax"))

# CMC0.2deg-CMC-L4-GLOB-v2.0
#AC % ./subset_dataset.py -s 19910901 -f 20170831 -b 6.25 45 -45 -20 -x CMC0.2deg-CMC-L4-GLOB-v2.0
#BC % ./subset_dataset.py -s 19910901 -f 20170831 -b -60 -25 -45 -5 -x CMC0.2deg-CMC-L4-GLOB-v2.0
#EAC% ./subset_dataset.py -s 19910901 -f 20170831 -b 145 160 -42.5 -15 -x CMC0.2deg-CMC-L4-GLOB-v2.0
#KC% ./subset_dataset.py -s 19910901 -f 20170831 -b 120 175 12.5 52.5 -x CMC0.2deg-CMC-L4-GLOB-v2.0
#GS% ./subset_dataset.py -s 19910901 -f 20170831 -b -90 -40 15 55 -x CMC0.2deg-CMC-L4-GLOB-v2.0

# MW_OI-REMSS-L4-GLOB-v4.0
#AC % ./subset_dataset.py -s 19980101 -f 20170831 -b 6.25 45 -45 -20 -x MW_OI-REMSS-L4-GLOB-v4.0
#BC % ./subset_dataset.py -s 19980101 -f 20170831 -b -60 -25 -45 -5 -x MW_OI-REMSS-L4-GLOB-v4.0

# MW_IR_OI-REMSS-L4-GLOB-v4.0
#AC % ./subset_dataset.py -s 20020601 -f 20170831 -b 6.25 45 -45 -20 -x MW_IR_OI-REMSS-L4-GLOB-v4.0
#BC % ./subset_dataset.py -s 20020601 -f 20170831 -b -60 -25 -45 -5 -x MW_IR_OI-REMSS-L4-GLOB-v4.0

# MUR-JPL-L4-GLOB-v4.1
#AC % ./subset_dataset.py -s 20020601 -f 20170831 -b 6.25 45 -45 -20 -x MUR-JPL-L4-GLOB-v4.1
#BC % ./subset_dataset.py -s 20020601 -f 20170831 -b -60 -25 -45 -5 -x MUR-JPL-L4-GLOB-v4.1

# NCDC-L4LRblend-GLOB-AVHRR_AMSR_OI
#AC ./subset_dataset.py -s 20020601 -f 20170831 -b 6.25 45 -45 -20 -x NCDC-L4LRblend-GLOB-AVHRR_AMSR_OI
#BC ./subset_dataset.py -s 20020601 -f 20170831 -b -60 -25 -45 -5 -x NCDC-L4LRblend-GLOB-AVHRR_AMSR_OI
#EAC% ./subset_dataset.py -s 20020601 -f 20170831 -b 145 160 -42.5 -15 -x NCDC-L4LRblend-GLOB-AVHRR_AMSR_OI
#KC% ./subset_dataset.py -s 20020601 -f 20170831 -b 120 175 12.5 52.5 -x NCDC-L4LRblend-GLOB-AVHRR_AMSR_OI
#GS% ./subset_dataset.py -s 20020601 -f 20170831 -b -90 -40 15 55 -x NCDC-L4LRblend-GLOB-AVHRR_AMSR_OI

# ./subset_dataset.py -s 19910901 -f 19910902 -b 6.25 45 -45 -20 -x CMC0.2deg-CMC-L4-GLOB-v2.0
# ./subset_dataset.py -s 19980101 -f 19980102 -b 6.25 45 -45 -20 -x MW_OI-REMSS-L4-GLOB-v4.0
# ./subset_dataset.py -s 20020601 -f 20020602 -b 6.25 45 -45 -20 -x MUR-JPL-L4-GLOB-v4.1
# ./subset_dataset.py -s 20020601 -f 20020602 -b 6.25 45 -45 -20 -x NCDC-L4LRblend-GLOB-AVHRR_AMSR_OI
#
# ./subset_dataset.py -s 19950501 -f 19950502 -b 120 175 12.5 52.5 -x CMC0.2deg-CMC-L4-GLOB-v2.0
