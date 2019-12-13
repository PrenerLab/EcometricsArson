Create Data - Longitudinal Analysis Data
================
Christopher Prener, Ph.D.
(December 13, 2019)

## Introduction

This notebook combines the demographic and crime data to make the
analytical data set for the longitudinal data.

## Dependencies

The following packages are needed:

``` r
# tidyverse
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

# other packages
library(here)
```

    ## here() starts at /Users/prenercg/GitHub/PrenerLab/EcometricsArson

## Load Data

There are two tables to be combined:

``` r
crime <- read_csv(here("data", "clean", "longitudinal_crime.csv"))
```

    ## Parsed with column specification:
    ## cols(
    ##   year = col_double(),
    ##   arson = col_double(),
    ##   arson_rate = col_double(),
    ##   violent = col_double(),
    ##   violent_rate = col_double(),
    ##   larceny = col_double(),
    ##   larceny_rate = col_double()
    ## )

``` r
demos <- read_csv(here("data", "clean", "longitudinal_demos.csv"))
```

    ## Parsed with column specification:
    ## cols(
    ##   year = col_double(),
    ##   pop = col_double(),
    ##   pop_delta = col_double(),
    ##   pop_delta_pct = col_double(),
    ##   total_jobs = col_double(),
    ##   manu_jobs = col_double(),
    ##   manu_delta = col_double(),
    ##   manu_delta_pct = col_double(),
    ##   manu_delta5 = col_double(),
    ##   manu_delta_pct5 = col_double()
    ## )

## Subset Years

There are extra rows in the demographic data set leftover from
calculating lags. We’ll subset those out before joining them:

``` r
demos <- filter(demos, year >= 1980)
```

## Join

Next, we’ll join the two data sets together:

``` r
longi <- left_join(crime, demos, by = "year")
```

## Write Data

Finally, we’ll write our demographic data to
`.csv`:

``` r
write_csv(longi, path = here("data", "analysis", "longitudinal_analysis.csv"))
```
