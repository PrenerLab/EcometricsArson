Create Data - Vacancy
================
Christopher Prener, Ph.D.
(December 09, 2019)

## Introduction

This notebook creates the grid-level vacancy estimates for further
analyses. These spatial data will also be used as a base to interpolate
demographic data into.

## Dependencies

This notebook requires the following packages:

``` r
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
library(sf)
```

    ## Linking to GEOS 3.7.2, GDAL 2.4.2, PROJ 5.2.0

``` r
# other packages
library(here)
```

    ## here() starts at /Users/chris/GitHub/PrenerLab/EcometricsArson

## Open Grid Data

The grid data have a large number of variables from a prior study. We’ll
start by cleaning them up and adding them to

``` r
vacancy <- st_read(here("data", "raw", "vacancy"), stringsAsFactors = FALSE) %>%
  select(OBJECTID_1, sq_m, v_sq_m, p_vacant) %>%
  rename(
    grid_id = OBJECTID_1,
    area_m2 = sq_m,
    vacant_m2 = v_sq_m,
    prop_vacant = p_vacant
  )
```

    ## Reading layer `grids_low' from data source `/Users/chris/GitHub/PrenerLab/EcometricsArson/data/raw/vacancy' using driver `ESRI Shapefile'
    ## Simple feature collection with 215 features and 33 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: 265635.5 ymin: 299492.6 xmax: 278988.1 ymax: 326438.7
    ## epsg (SRID):    26996
    ## proj4string:    +proj=tmerc +lat_0=35.83333333333334 +lon_0=-90.5 +k=0.999933333 +x_0=250000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs

## Store Copy

Since the goal of the `data/clean/` folder is to keep a record of all
the individual data sets being used in the project, I’ll write a copy of
the `vacancy` object into that subdirectory:

``` r
st_write(obj = vacancy, dsn = here("data", "clean", "vacancy", "vacancy.shp"), delete_dsn = TRUE)
```

    ## Warning in abbreviate_shapefile_names(obj): Field names abbreviated for
    ## ESRI Shapefile driver

    ## Deleting source `/Users/chris/GitHub/PrenerLab/EcometricsArson/data/clean/vacancy/vacancy.shp' using driver `ESRI Shapefile'
    ## Writing layer `vacancy' to data source `/Users/chris/GitHub/PrenerLab/EcometricsArson/data/clean/vacancy/vacancy.shp' using driver `ESRI Shapefile'
    ## Writing 215 features with 4 fields and geometry type Multi Polygon.
