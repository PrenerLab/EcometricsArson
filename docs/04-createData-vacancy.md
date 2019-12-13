Create Data - Vacancy
================
Christopher Prener, Ph.D.
(December 13, 2019)

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

    ## Linking to GEOS 3.6.1, GDAL 2.1.3, PROJ 4.9.3

``` r
# other packages
library(here)
```

    ## here() starts at /Users/prenercg/GitHub/PrenerLab/EcometricsArson

## Open Grid Data

The grid data have a large number of variables from a prior study. We’ll
start by cleaning them up on
import:

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

    ## Reading layer `grids_low' from data source `/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/vacancy' using driver `ESRI Shapefile'
    ## Simple feature collection with 215 features and 33 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: 265635.5 ymin: 299492.6 xmax: 278988.1 ymax: 326438.7
    ## epsg (SRID):    NA
    ## proj4string:    +proj=tmerc +lat_0=35.83333333333334 +lon_0=-90.5 +k=0.9999333333333333 +x_0=250000 +y_0=0 +datum=NAD83 +units=m +no_defs

Next, we’ll create a copy that only contains the `grid_id` column. Since
shapefile variable names get truncated, we’ll store the main analytical
data set as a `.csv` file separate from the geometric data:

``` r
# make copy
grids <- vacancy %>%
  select(grid_id)

# re-project
grids <- st_transform(grids, crs = 26915)

# remove geometry
st_geometry(vacancy) <- NULL
```

## Store Copy

Since the goal of the `data/clean/` folder is to keep a record of all
the individual data sets being used in the project, I’ll write a copy of
the `grids` object into that
subdirectory:

``` r
st_write(obj = grids, dsn = here("data", "raw", "grids", "grids.shp"), delete_dsn = TRUE)
```

    ## Deleting source `/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/grids/grids.shp' using driver `ESRI Shapefile'
    ## Writing layer `grids' to data source `/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/grids/grids.shp' using driver `ESRI Shapefile'
    ## features:       215
    ## fields:         1
    ## geometry type:  Multi Polygon

We’ll also write the vacancy data as a `.csv` file:

``` r
write_csv(vacancy, path = here("data", "clean", "grids_vacancy.csv"))
```
