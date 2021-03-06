Create Data - Grids
================
Christopher Prener, Ph.D.
(March 13, 2020)

## Introduction

This notebook builds on the grid-level vacancy estimates created in
`04-createData-vacancy.Rmd`. The crime and demographic data will be
added to each grid square to create the neighborhood-level analysis data
set.

## Dependencies

This notebook requires the following packages:

``` r
# tidystl packages
library(compstatr)
library(stlcsb)

# tidyverse packages
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(readr)

# spatial packages
library(areal)
library(sf)
```

    ## Linking to GEOS 3.7.2, GDAL 2.4.2, PROJ 5.2.0

``` r
library(tigris)
```

    ## To enable 
    ## caching of data, set `options(tigris_use_cache = TRUE)` in your R script or .Rprofile.

    ## 
    ## Attaching package: 'tigris'

    ## The following object is masked from 'package:graphics':
    ## 
    ##     plot

``` r
# other packages
library(here)
```

    ## here() starts at /Users/prenercg/GitHub/PrenerLab/EcometricsArson

## Load Base Data

All of the data will be interpolated into the grids that already contain
vacancy metrics:

``` r
# read
grids <- st_read(here("data", "raw", "grids"), stringsAsFactors = FALSE) %>%
  rename()
```

    ## Reading layer `grids' from data source `/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/grids' using driver `ESRI Shapefile'
    ## Simple feature collection with 215 features and 1 field
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: 733360 ymin: 4268394 xmax: 746170.8 ymax: 4295511
    ## epsg (SRID):    NA
    ## proj4string:    +proj=utm +zone=15 +ellps=GRS80 +units=m +no_defs

``` r
# re-project
grids <- st_transform(grids, crs = 26915)
```

## Add Arson Data

The arson data is stored in `arson.csv`. Since these are point data,
I’ll read them in, project them, and then use a spatial join to create
counts per grid square. First, we’ll load the data and project them:

``` r
# load
arson <- read_csv(here("data", "clean", "point_arson.csv")) %>%
  filter(cs_year >= 2013 & cs_year <= 2017)
```

    ## Parsed with column specification:
    ## cols(
    ##   cs_year = col_double(),
    ##   date_occur = col_character(),
    ##   crime = col_double(),
    ##   description = col_character(),
    ##   ileads_address = col_double(),
    ##   ileads_street = col_character(),
    ##   x_coord = col_double(),
    ##   y_coord = col_double()
    ## )

``` r
# project
arson <- cs_projectXY(arson, varX = x_coord, varY = y_coord, crs = 26915)

# print valid rows
nrow(arson)
```

    ## [1] 1191

Next, we’ll perform the intersection:

``` r
# project
arson <- st_intersection(arson, grids)
```

    ## Warning: attribute variables are assumed to be spatially constant throughout all
    ## geometries

``` r
# print valid rows
nrow(arson)
```

    ## [1] 1170

Finally, we’ll remove the geometry, sum our data by `grid_id`, and join
our counts to the `grids` object:

``` r
# remove geometry
st_geometry(arson) <- NULL

# perform spatial join
arson %>%
  group_by(grid_id) %>%
  summarize(arson = n()) %>%
  left_join(grids, ., by = "grid_id") %>%
  mutate(arson = ifelse(is.na(arson) == TRUE, 0, arson)) -> grids

# clean-up
rm(arson)
```

## Violent Crimes

The violent crime data is stored in `violent.csv`. As before, I’ll read
them in, project them, and then use a spatial join to create counts per
grid square. First, we’ll load the data and project them:

``` r
# load
violent <- read_csv(here("data", "clean", "point_violent.csv")) %>%
  filter(cs_year >= 2013 & cs_year <= 2017)
```

    ## Parsed with column specification:
    ## cols(
    ##   cs_year = col_double(),
    ##   date_occur = col_character(),
    ##   crime = col_double(),
    ##   description = col_character(),
    ##   ileads_address = col_double(),
    ##   ileads_street = col_character(),
    ##   x_coord = col_double(),
    ##   y_coord = col_double()
    ## )

``` r
# project
violent <- cs_projectXY(violent, varX = x_coord, varY = y_coord, crs = 26915)

# print valid rows
nrow(violent)
```

    ## [1] 28999

Next, we’ll perform the intersection:

``` r
# project
violent <- st_intersection(violent, grids)
```

    ## Warning: attribute variables are assumed to be spatially constant throughout all
    ## geometries

``` r
# print valid rows
nrow(violent)
```

    ## [1] 27559

Finally, we’ll remove the geometry, sum our data by `grid_id`, and join
our counts to the `grids` object:

``` r
# remove geometry
st_geometry(violent) <- NULL

# perform spatial join
violent %>%
  group_by(grid_id) %>%
  summarize(violent = n()) %>%
  left_join(grids, ., by = "grid_id") %>%
  mutate(violent = ifelse(is.na(violent) == TRUE, 0, violent)) -> grids

# clean-up
rm(violent)
```

## Property Crimes

The property crime data is stored in `property.csv`. As before, I’ll
read them in, project them, and then use a spatial join to create counts
per grid square. First, we’ll load the data and project them:

``` r
# load
property <- read_csv(here("data", "clean", "point_property.csv")) %>%
  filter(cs_year >= 2013 & cs_year <= 2017)
```

    ## Parsed with column specification:
    ## cols(
    ##   cs_year = col_double(),
    ##   date_occur = col_character(),
    ##   crime = col_double(),
    ##   description = col_character(),
    ##   ileads_address = col_double(),
    ##   ileads_street = col_character(),
    ##   x_coord = col_double(),
    ##   y_coord = col_double()
    ## )

``` r
# project
property <- cs_projectXY(property, varX = x_coord, varY = y_coord, crs = 26915)

# print valid rows
nrow(property)
```

    ## [1] 100350

Next, we’ll perform the intersection:

``` r
# project
property <- st_intersection(property, grids)
```

    ## Warning: attribute variables are assumed to be spatially constant throughout all
    ## geometries

``` r
# print valid rows
nrow(property)
```

    ## [1] 99535

Finally, we’ll remove the geometry, sum our data by `grid_id`, and join
our counts to the `grids` object:

``` r
# remove geometry
st_geometry(property) <- NULL

# perform spatial join
property %>%
  group_by(grid_id) %>%
  summarize(property = n()) %>%
  left_join(grids, ., by = "grid_id") %>%
  mutate(property = ifelse(is.na(property) == TRUE, 0, property)) -> grids

# clean-up
rm(property)
```

## Other Crimes

The other crime data is stored in `otherCrimes.csv`. As before, I’ll
read them in, project them, and then use a spatial join to create counts
per grid square. First, we’ll load the data and project them:

``` r
# load
otherCrimes <- read_csv(here("data", "clean", "point_otherCrimes.csv")) %>%
  filter(cs_year >= 2013 & cs_year <= 2017)
```

    ## Parsed with column specification:
    ## cols(
    ##   cs_year = col_double(),
    ##   date_occur = col_character(),
    ##   crime = col_double(),
    ##   description = col_character(),
    ##   ileads_address = col_double(),
    ##   ileads_street = col_character(),
    ##   x_coord = col_double(),
    ##   y_coord = col_double()
    ## )

``` r
# project
otherCrimes <- cs_projectXY(otherCrimes, varX = x_coord, varY = y_coord, crs = 26915)

# print valid rows
nrow(otherCrimes)
```

    ## [1] 38494

Next, we’ll perform the intersection:

``` r
# project
otherCrimes <- st_intersection(otherCrimes, grids)
```

    ## Warning: attribute variables are assumed to be spatially constant throughout all
    ## geometries

``` r
# print valid rows
nrow(otherCrimes)
```

    ## [1] 38156

Finally, we’ll remove the geometry, sum our data by `grid_id`, and join
our counts to the `grids` object:

``` r
# remove geometry
st_geometry(otherCrimes) <- NULL

# perform spatial join
otherCrimes %>%
  group_by(grid_id) %>%
  summarize(other_crime = n()) %>%
  left_join(grids, ., by = "grid_id") %>%
  mutate(other_crime = ifelse(is.na(other_crime) == TRUE, 0, other_crime)) -> grids

# clean-up
rm(otherCrimes)
```

## Disorder

The calls for disorder data are stored in `disorder.csv`. As before,
I’ll read them in, project them, and then use a spatial join to create
counts per grid square. The project process varies slightly because
these data are from a different source. First, we’ll load the data and
project them:

``` r
# load
disorder <- read_csv(here("data", "clean", "point_disorder.csv")) %>%
  filter(year >= 2013 & year <= 2017)
```

    ## Parsed with column specification:
    ## cols(
    ##   year = col_double(),
    ##   datetimeinit = col_datetime(format = ""),
    ##   category = col_character(),
    ##   probaddress = col_character(),
    ##   problemcode = col_character(),
    ##   srx = col_double(),
    ##   sry = col_double()
    ## )

``` r
# project
disorder <- csb_projectXY(disorder, varX = srx, varY = sry, crs = 26915)

# print valid rows
nrow(disorder)
```

    ## [1] 148450

Next, we’ll perform the intersection:

``` r
# project
disorder <- st_intersection(disorder, grids)
```

    ## Warning: attribute variables are assumed to be spatially constant throughout all
    ## geometries

``` r
# print valid rows
nrow(disorder)
```

    ## [1] 148390

Finally, we’ll remove the geometry, sum our data by `grid_id`, and join
our counts to the `grids` object:

``` r
# remove geometry
st_geometry(disorder) <- NULL

# perform spatial join
disorder %>%
  group_by(grid_id) %>%
  summarize(disorder = n()) %>%
  left_join(grids, ., by = "grid_id") %>%
  mutate(disorder = ifelse(is.na(disorder) == TRUE, 0, disorder)) -> grids

# clean-up
rm(disorder)
```

## Vacancy

The vacancy counts already correspond to the `grids` object, so they
only need to be joined:

``` r
# load
vacancy <- read_csv(here("data", "clean", "grids_vacancy.csv")) %>%
  select(grid_id, prop_vacant)
```

    ## Parsed with column specification:
    ## cols(
    ##   grid_id = col_double(),
    ##   area_m2 = col_double(),
    ##   vacant_m2 = col_double(),
    ##   prop_vacant = col_double()
    ## )

``` r
# join
grids <- left_join(grids, vacancy, by = "grid_id")

# clean-up
rm(vacancy)
```

## Contemporary Demographic Data

Our demographic measures are at the census tract level, which means they
need to be interpolated into the grids. This process requires that the
demographic data be merged with the corresponding geometric data. First,
we’ll download those
data:

``` r
tracts <- tracts(state = 29, county = 510, year = 2017, class = "sf") %>%
  select(GEOID)
```

    ## Downloading: 16 kB     Downloading: 16 kB     Downloading: 16 kB     Downloading: 16 kB     Downloading: 25 kB     Downloading: 25 kB     Downloading: 25 kB     Downloading: 25 kB     Downloading: 41 kB     Downloading: 41 kB     Downloading: 47 kB     Downloading: 47 kB     Downloading: 47 kB     Downloading: 47 kB     Downloading: 47 kB     Downloading: 47 kB     Downloading: 64 kB     Downloading: 64 kB     Downloading: 72 kB     Downloading: 72 kB     Downloading: 73 kB     Downloading: 73 kB     Downloading: 73 kB     Downloading: 73 kB     Downloading: 86 kB     Downloading: 86 kB     Downloading: 86 kB     Downloading: 86 kB     Downloading: 89 kB     Downloading: 89 kB     Downloading: 89 kB     Downloading: 89 kB     Downloading: 110 kB     Downloading: 110 kB     Downloading: 110 kB     Downloading: 110 kB     Downloading: 110 kB     Downloading: 110 kB     Downloading: 120 kB     Downloading: 120 kB     Downloading: 120 kB     Downloading: 120 kB     Downloading: 120 kB     Downloading: 120 kB     Downloading: 120 kB     Downloading: 120 kB     Downloading: 130 kB     Downloading: 130 kB     Downloading: 130 kB     Downloading: 130 kB     Downloading: 140 kB     Downloading: 140 kB     Downloading: 140 kB     Downloading: 140 kB     Downloading: 140 kB     Downloading: 140 kB     Downloading: 140 kB     Downloading: 140 kB     Downloading: 150 kB     Downloading: 150 kB     Downloading: 150 kB     Downloading: 150 kB     Downloading: 150 kB     Downloading: 150 kB     Downloading: 150 kB     Downloading: 150 kB     Downloading: 170 kB     Downloading: 170 kB     Downloading: 180 kB     Downloading: 180 kB     Downloading: 190 kB     Downloading: 190 kB     Downloading: 200 kB     Downloading: 200 kB     Downloading: 200 kB     Downloading: 200 kB     Downloading: 200 kB     Downloading: 200 kB     Downloading: 200 kB     Downloading: 200 kB     Downloading: 220 kB     Downloading: 220 kB     Downloading: 230 kB     Downloading: 230 kB     Downloading: 230 kB     Downloading: 230 kB     Downloading: 240 kB     Downloading: 240 kB     Downloading: 250 kB     Downloading: 250 kB     Downloading: 250 kB     Downloading: 250 kB     Downloading: 270 kB     Downloading: 270 kB     Downloading: 270 kB     Downloading: 270 kB     Downloading: 280 kB     Downloading: 280 kB     Downloading: 280 kB     Downloading: 280 kB     Downloading: 280 kB     Downloading: 280 kB     Downloading: 290 kB     Downloading: 290 kB     Downloading: 300 kB     Downloading: 300 kB     Downloading: 300 kB     Downloading: 300 kB     Downloading: 320 kB     Downloading: 320 kB     Downloading: 320 kB     Downloading: 320 kB     Downloading: 320 kB     Downloading: 320 kB     Downloading: 320 kB     Downloading: 320 kB     Downloading: 320 kB     Downloading: 320 kB     Downloading: 330 kB     Downloading: 330 kB     Downloading: 330 kB     Downloading: 330 kB     Downloading: 350 kB     Downloading: 350 kB     Downloading: 360 kB     Downloading: 360 kB     Downloading: 360 kB     Downloading: 360 kB     Downloading: 370 kB     Downloading: 370 kB     Downloading: 370 kB     Downloading: 370 kB     Downloading: 370 kB     Downloading: 370 kB     Downloading: 370 kB     Downloading: 370 kB     Downloading: 380 kB     Downloading: 380 kB     Downloading: 380 kB     Downloading: 380 kB     Downloading: 390 kB     Downloading: 390 kB     Downloading: 390 kB     Downloading: 390 kB     Downloading: 400 kB     Downloading: 400 kB     Downloading: 400 kB     Downloading: 400 kB     Downloading: 400 kB     Downloading: 400 kB     Downloading: 400 kB     Downloading: 400 kB     Downloading: 420 kB     Downloading: 420 kB     Downloading: 430 kB     Downloading: 430 kB     Downloading: 450 kB     Downloading: 450 kB     Downloading: 450 kB     Downloading: 450 kB     Downloading: 460 kB     Downloading: 460 kB     Downloading: 460 kB     Downloading: 460 kB     Downloading: 480 kB     Downloading: 480 kB     Downloading: 480 kB     Downloading: 480 kB     Downloading: 490 kB     Downloading: 490 kB     Downloading: 490 kB     Downloading: 490 kB     Downloading: 510 kB     Downloading: 510 kB     Downloading: 520 kB     Downloading: 520 kB     Downloading: 520 kB     Downloading: 520 kB     Downloading: 520 kB     Downloading: 520 kB     Downloading: 540 kB     Downloading: 540 kB     Downloading: 540 kB     Downloading: 540 kB     Downloading: 540 kB     Downloading: 540 kB     Downloading: 560 kB     Downloading: 560 kB     Downloading: 560 kB     Downloading: 560 kB     Downloading: 560 kB     Downloading: 560 kB     Downloading: 570 kB     Downloading: 570 kB     Downloading: 570 kB     Downloading: 570 kB     Downloading: 590 kB     Downloading: 590 kB     Downloading: 590 kB     Downloading: 590 kB     Downloading: 590 kB     Downloading: 590 kB     Downloading: 590 kB     Downloading: 590 kB     Downloading: 610 kB     Downloading: 610 kB     Downloading: 620 kB     Downloading: 620 kB     Downloading: 620 kB     Downloading: 620 kB     Downloading: 620 kB     Downloading: 620 kB     Downloading: 620 kB     Downloading: 620 kB     Downloading: 640 kB     Downloading: 640 kB     Downloading: 640 kB     Downloading: 640 kB     Downloading: 640 kB     Downloading: 640 kB     Downloading: 640 kB     Downloading: 640 kB     Downloading: 660 kB     Downloading: 660 kB     Downloading: 660 kB     Downloading: 660 kB     Downloading: 660 kB     Downloading: 660 kB     Downloading: 660 kB     Downloading: 660 kB     Downloading: 670 kB     Downloading: 670 kB     Downloading: 670 kB     Downloading: 670 kB     Downloading: 680 kB     Downloading: 680 kB     Downloading: 680 kB     Downloading: 680 kB     Downloading: 680 kB     Downloading: 680 kB     Downloading: 690 kB     Downloading: 690 kB     Downloading: 690 kB     Downloading: 690 kB     Downloading: 700 kB     Downloading: 700 kB     Downloading: 700 kB     Downloading: 700 kB     Downloading: 700 kB     Downloading: 700 kB     Downloading: 710 kB     Downloading: 710 kB     Downloading: 710 kB     Downloading: 710 kB     Downloading: 710 kB     Downloading: 710 kB     Downloading: 720 kB     Downloading: 720 kB     Downloading: 720 kB     Downloading: 720 kB     Downloading: 740 kB     Downloading: 740 kB     Downloading: 750 kB     Downloading: 750 kB     Downloading: 750 kB     Downloading: 750 kB     Downloading: 750 kB     Downloading: 750 kB     Downloading: 760 kB     Downloading: 760 kB     Downloading: 760 kB     Downloading: 760 kB     Downloading: 780 kB     Downloading: 780 kB     Downloading: 780 kB     Downloading: 780 kB     Downloading: 780 kB     Downloading: 780 kB     Downloading: 790 kB     Downloading: 790 kB     Downloading: 790 kB     Downloading: 790 kB     Downloading: 790 kB     Downloading: 790 kB     Downloading: 800 kB     Downloading: 800 kB     Downloading: 810 kB     Downloading: 810 kB     Downloading: 820 kB     Downloading: 820 kB     Downloading: 820 kB     Downloading: 820 kB     Downloading: 830 kB     Downloading: 830 kB     Downloading: 830 kB     Downloading: 830 kB     Downloading: 840 kB     Downloading: 840 kB     Downloading: 840 kB     Downloading: 840 kB     Downloading: 850 kB     Downloading: 850 kB     Downloading: 850 kB     Downloading: 850 kB     Downloading: 850 kB     Downloading: 850 kB     Downloading: 860 kB     Downloading: 860 kB     Downloading: 860 kB     Downloading: 860 kB     Downloading: 870 kB     Downloading: 870 kB     Downloading: 870 kB     Downloading: 870 kB     Downloading: 880 kB     Downloading: 880 kB     Downloading: 880 kB     Downloading: 880 kB     Downloading: 880 kB     Downloading: 880 kB     Downloading: 880 kB     Downloading: 880 kB     Downloading: 890 kB     Downloading: 890 kB     Downloading: 890 kB     Downloading: 890 kB     Downloading: 900 kB     Downloading: 900 kB     Downloading: 900 kB     Downloading: 900 kB     Downloading: 910 kB     Downloading: 910 kB     Downloading: 910 kB     Downloading: 910 kB     Downloading: 910 kB     Downloading: 910 kB     Downloading: 910 kB     Downloading: 910 kB     Downloading: 910 kB     Downloading: 910 kB     Downloading: 920 kB     Downloading: 920 kB     Downloading: 930 kB     Downloading: 930 kB     Downloading: 930 kB     Downloading: 930 kB     Downloading: 930 kB     Downloading: 930 kB     Downloading: 940 kB     Downloading: 940 kB     Downloading: 940 kB     Downloading: 940 kB     Downloading: 960 kB     Downloading: 960 kB     Downloading: 960 kB     Downloading: 960 kB     Downloading: 960 kB     Downloading: 960 kB     Downloading: 960 kB     Downloading: 960 kB     Downloading: 970 kB     Downloading: 970 kB     Downloading: 970 kB     Downloading: 970 kB     Downloading: 980 kB     Downloading: 980 kB     Downloading: 980 kB     Downloading: 980 kB     Downloading: 1,000 kB     Downloading: 1,000 kB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.2 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.3 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.4 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.5 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.6 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.7 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.8 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 3.9 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.1 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.2 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.3 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.4 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.5 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.6 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.7 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.8 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 4.9 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.1 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.2 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.3 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.4 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.5 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.6 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.7 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.8 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 5.9 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.1 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.2 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.3 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.4 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.5 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.6 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.7 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.8 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 6.9 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.1 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.2 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.3 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.4 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.5 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.6 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.7 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.8 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 7.9 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.1 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.2 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.3 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.4 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.5 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.6 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.7 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.8 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 8.9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.1 MB     Downloading: 9.2 MB     Downloading: 9.2 MB     Downloading: 9.2 MB     Downloading: 9.2 MB     Downloading: 9.2 MB     Downloading: 9.2 MB

Next, we’ll load the demographic data and join them to the tract
geometry:

``` r
# load
demos <- read_csv(here("data", "clean", "tract_demographics.csv")) %>%
  mutate(GEOID = as.character(GEOID)) %>%
  select(GEOID, totalPop, medianInc, raceTotal, black, pvtyTotal, pvty, 
         emplyTotal, unemply, ownTotal, ownOcc) %>%
  rename(
    total_pop = totalPop,
    median_inc = medianInc
  )
```

    ## Parsed with column specification:
    ## cols(
    ##   .default = col_double()
    ## )

    ## See spec(...) for full column specifications.

``` r
# join
tracts <- left_join(tracts, demos, by = "GEOID")

# transform
tracts <- st_transform(tracts, crs = 26915)

# clean-up
rm(demos)
```

With our tract data prepared, we’ll make a copy of the grids data that
contain only the `grid_id` column:

``` r
grids_aw <- grids %>%
  select(grid_id)
```

Now that we have the grids and tract data ready to interpolate, we can
perform the
calculations:

``` r
grids_aw_17 <- aw_interpolate(grids_aw, tid = grid_id, source = tracts, sid = GEOID,
                 weight = "sum", output = "tibble",
                 extensive = c("total_pop", "median_inc", "raceTotal", "black", 
                               "pvtyTotal", "pvty", "emplyTotal", "unemply",
                               "ownTotal", "ownOcc"))
```

Since we interpolated all spatially extensive measures, we need to
calculate some relevant proportions and then remove the original count
data:

``` r
grids_aw_17 %>%
  mutate(black_prop = black/raceTotal) %>%
  mutate(pvty_prop = pvty/pvtyTotal) %>%
  mutate(unemply_prop = unemply/emplyTotal) %>%
  mutate(ownOcc_prop = ownOcc/ownTotal) %>%
  select(-raceTotal, -black, -pvtyTotal, -pvty, 
         -emplyTotal, -unemply, -ownTotal, -ownOcc) -> grids_aw_17
```

Finally, we’ll remove our raw data:

``` r
rm(tracts)
```

## Historic Demographic Data

Next, we’ll create estimates for both the 1950 total population and the
1970 total population at the grid level as well. First, we’ll read the
1950 data in and then interplate it:

``` r
# read tabular data
pop50 <- read_csv(here("data", "raw", "historic-population", "STL_DEMOGRAPHICS_pop50.csv")) %>%
  select(Geo_Name, SE_T001_001) %>%
  rename(
    TRACTID = Geo_Name,
    pop50 = SE_T001_001
  )
```

    ## Parsed with column specification:
    ## cols(
    ##   Geo_Name = col_character(),
    ##   Geo_QName = col_character(),
    ##   Geo_SUMLEV = col_double(),
    ##   Geo_FIPS = col_double(),
    ##   Geo_state = col_double(),
    ##   Geo_county = col_double(),
    ##   SE_T001_001 = col_double()
    ## )

``` r
# read geometric data
tract50 <- st_read(here("data", "raw", "historic-population", "STL_DEMOGRAPHICS_tracts50"),
                   stringsAsFactors = FALSE) %>%
  st_transform(crs = 26915)
```

    ## Reading layer `STL_DEMOGRAPHICS_tracts50' from data source `/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/historic-population/STL_DEMOGRAPHICS_tracts50' using driver `ESRI Shapefile'
    ## Simple feature collection with 128 features and 1 field
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: -90.32051 ymin: 38.53185 xmax: -90.16641 ymax: 38.77435
    ## epsg (SRID):    NA
    ## proj4string:    +proj=longlat +ellps=GRS80 +no_defs

``` r
# join
pop50 <- left_join(tract50, pop50, by = "TRACTID")

# interpolate
grids_aw_50 <- aw_interpolate(grids_aw, tid = grid_id, source = pop50, sid = TRACTID,
                 weight = "sum", output = "tibble", extensive = "pop50")

# remove raw data
rm(pop50, tract50)
```

We’ll the repeat the process with the 1970 era data:

``` r
# read tabular data
pop70 <- read_csv(here("data", "raw", "historic-population", "STL_DEMOGRAPHICS_pop70.csv")) %>%
  select(Geo_TractCode, SE_T001_001) %>%
  rename(
    TRACTID = Geo_TractCode,
    pop70 = SE_T001_001
  )
```

    ## Parsed with column specification:
    ## cols(
    ##   Geo_FIPS = col_double(),
    ##   Geo_NAME = col_double(),
    ##   Geo_QName = col_character(),
    ##   Geo_State = col_double(),
    ##   Geo_COUNTY = col_double(),
    ##   Geo_TractCode = col_double(),
    ##   Geo_TRACT = col_double(),
    ##   Geo_SUFFTRT = col_double(),
    ##   Geo_METROARA = col_double(),
    ##   Geo_PLACE = col_logical(),
    ##   Geo_URBANARA = col_logical(),
    ##   SE_T001_001 = col_double()
    ## )

``` r
# read geometric data
tract70 <- st_read(here("data", "raw", "historic-population", "STL_DEMOGRAPHICS_tracts70"),
                   stringsAsFactors = FALSE) %>%
  st_transform(crs = 26915)
```

    ## Reading layer `STL_DEMOGRAPHICS_tracts70' from data source `/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/historic-population/STL_DEMOGRAPHICS_tracts70' using driver `ESRI Shapefile'
    ## Simple feature collection with 126 features and 1 field
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: -90.32051 ymin: 38.53185 xmax: -90.16641 ymax: 38.77435
    ## epsg (SRID):    NA
    ## proj4string:    +proj=longlat +ellps=GRS80 +no_defs

``` r
# join
pop70 <- left_join(tract70, pop70, by = "TRACTID")

# interpolate
grids_aw_70 <- aw_interpolate(grids_aw, tid = grid_id, source = pop70, sid = TRACTID,
                 weight = "sum", output = "tibble", extensive = "pop70")

# remove raw data
rm(pop70, tract70)
```

## Combine Data

Finally, we’ll combine our various measures into a single object:

``` r
# joins
grids %>%
  left_join(., grids_aw_50, by = "grid_id") %>%
  left_join(., grids_aw_70, by = "grid_id") %>%
  left_join(., grids_aw_17, by = "grid_id") -> grids

# clean-up
rm(grids_aw_50, grids_aw_70, grids_aw_17, grids_aw)
```

## Write Data

With our data created, we can write the analytical data set to the
`data/analysis`
directory:

``` r
st_write(grids, dsn = here("data", "analysis", "spatial_analysis.geojson"),
         delete_dsn = TRUE)
```

    ## Deleting source `/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/analysis/spatial_analysis.geojson' using driver `GeoJSON'
    ## Writing layer `spatial_analysis' to data source `/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/analysis/spatial_analysis.geojson' using driver `GeoJSON'
    ## Writing 215 features with 15 fields and geometry type Multi Polygon.

Data are written in an open format to improve reproducibility.
