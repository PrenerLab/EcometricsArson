Create Data - Disorder
================
Christopher Prener, Ph.D.
(March 13, 2020)

## Introduction

This notebook creates a data set of disorder calls for the City of
St. Louis.

## Dependencies

This notebook requires the following packages:

``` r
# tidystl packages
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
library(lubridate)
```

    ## 
    ## Attaching package: 'lubridate'

    ## The following object is masked from 'package:base':
    ## 
    ##     date

``` r
library(readr)

# other packages
library(here)
```

    ## here() starts at /Users/prenercg/GitHub/PrenerLab/EcometricsArson

    ## 
    ## Attaching package: 'here'

    ## The following object is masked from 'package:lubridate':
    ## 
    ##     here

## Download Data

We’ll start by downloading all csb calls for 2013 through 2017 from the
St. Louis Open Data website via the `stlcsb` package:

``` r
# download
all_calls <- csb_get_data(years = 2009:2019)

# store number of rows
total_rows <- nrow(all_calls)
```

## Add Year

We’ll add a year variable (equivalent to `cs_year` in the crime data):

``` r
all_calls %>%
  mutate(year = ymd_hms(datetimeinit)) %>%
  mutate(year = year(year)) %>%
  select(year, everything()) -> all_calls
```

## Subset

Some of these calls were cancelled, so we’ll remove them from the data
set:

``` r
# subset
all_calls %>% 
  csb_canceled(var = "datecancelled") %>%
  csb_missingXY(varX = srx, varY = sry, newVar = missing) %>%
  filter(missing == FALSE) %>%
  select(-missing) -> all_calls

# store remaining number of rows
remaining_rows <- nrow(all_calls)
```

As an aside, we want to know how many rows were removed by this process:

``` r
remaining_rows/total_rows*100
```

    ## [1] 95.59417

## Cateogrize Data

Next, we’ll focus our analysis on particular categories of calls:

``` r
# subset
all_calls %>% 
  csb_categorize(var = problemcode, newVar = category) %>%
  select(requestid, datetimeinit, category, everything()) %>%
  filter(category %in% c("Debris", "Degrade", "Disturbance", "Law")) %>%
  select(year, datetimeinit, category, probaddress, problemcode, srx, sry) -> focal_calls

# store remaining number of rows
focal_rows <- nrow(focal_calls)
```

As an aside, we want to know how many rows were removed by this process:

``` r
focal_rows/remaining_rows*100
```

    ## [1] 28.45654

## Write Data to CSV

With these data prepared, we can write them to
`.csv`:

``` r
write_csv(focal_calls, path = here("data", "clean", "point_disorder.csv"))
```
