Create Data - Demographics
================
Christopher Prener, Ph.D.
(December 06, 2019)

## Introduction

This notebook creates a data set of demographic data for the City of
St. Louis at the census tract level.

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

# other packages
library(here)
```

    ## here() starts at /Users/chris/GitHub/PrenerLab/EcometricsArson

``` r
library(tidycensus)
```

## Download Census Data

The majority of the demographic variables are available from the U.S.
Census Bureau’s API, which I’ll access using `tidycensus`.

### Total Population

We’ll start with total population per census tract, which comes from
table `B01003`.

``` r
get_acs(geography = "tract", variables = "B01003_001", year = 2017, state = 29, county = 510) %>%
  select(-NAME, -variable) %>%
  rename(
    totalPop = estimate,
    totalPop_moe = moe
  ) -> total_pop
```

    ## Getting data from the 2013-2017 5-year ACS

### Race

Next, we’ll calculate the proportion of each tract’s residents that are
African American. The underlying race data come from table `B02001`.

``` r
get_acs(geography = "tract", table = "B02001", year = 2017, state = 29, county = 510, output = "wide") %>%
  select(GEOID, B02001_001E, B02001_001M, B02001_003E, B02001_003M) %>%
  rename(
    raceTotal = B02001_001E,
    raceTotal_moe = B02001_001M,
    black = B02001_003E,
    black_moe = B02001_003M
  ) %>%
  mutate(black_prop = black/raceTotal) -> race
```

    ## Getting data from the 2013-2017 5-year ACS

We’ll also preserve the total and black counts, along with their
associated margins of error, for the intermediary data set.

### Median Income

Next, we’ll get the median household income per census tract, which
comes from table `B19013`.

``` r
get_acs(geography = "tract", variables = "B19013_001", year = 2017, state = 29, county = 510) %>%
  select(-NAME, -variable) %>%
  rename(
    medianInc = estimate,
    medianInc_moe = moe
  ) -> medianInc
```

    ## Getting data from the 2013-2017 5-year ACS

### Poverty

Next, we’ll calculate the proportion of each tract’s residents that are
living below 100% of the poverty line. The underlying poverty data come
from table `B06012`.

``` r
get_acs(geography = "tract", table = "B06012", year = 2017, state = 29, county = 510, output = "wide") %>%
  select(GEOID, B06012_001E, B06012_001M, B06012_002E, B06012_002M) %>%
  rename(
    pvtyTotal = B06012_001E,
    pvtyTotal_moe = B06012_001M,
    pvty = B06012_002E,
    pvty_moe = B06012_002M
  ) %>%
  mutate(pvty_prop = pvty/pvtyTotal) -> poverty
```

    ## Getting data from the 2013-2017 5-year ACS

As with the race data, the original columns the calculation is based on
are preserved here.

### Unemployment

Finally, we’ll calculate the proportion of each tract’s residents that
are unemployed. The underlying employment data come from table `B23025`.

``` r
get_acs(geography = "tract", table = "B23025", year = 2017, state = 29, county = 510, output = "wide") %>%
  select(GEOID, B23025_001E, B23025_001M, B23025_007E, B23025_007M) %>%
  rename(
    emplyTotal = B23025_001E,
    emplyTotal_moe = B23025_001M,
    unemply = B23025_007E,
    unemply_moe = B23025_007M
  ) %>%
  mutate(unemply_prop = unemply/emplyTotal) -> employ
```

    ## Getting data from the 2013-2017 5-year ACS

## Owner Occupied

We’ll also calculate the proportion of each tract’s residents that are
living in owner occupied housing. The underlying residence data come
from table `B25026`.

``` r
get_acs(geography = "tract", table = "B25026", year = 2017, state = 29, county = 510, output = "wide") %>%
  select(GEOID, B25026_001E, B25026_001M, B25026_002E, B25026_002M) %>%
  rename(
    ownTotal = B25026_001E,
    ownTotal_moe = B25026_001M,
    ownOcc = B25026_002E,
    ownOcc_moe = B25026_002M
  ) %>%
  mutate(ownOcc_prop = ownOcc/ownTotal) -> owner
```

    ## Getting data from the 2013-2017 5-year ACS

## Combine

With our data downloaded, we’ll combine the tables:

``` r
left_join(total_pop, race, by = "GEOID") %>%
  left_join(., medianInc, by = "GEOID") %>%
  left_join(., owner, by = "GEOID") %>%
  left_join(., poverty, by = "GEOID") %>%
  left_join(., employ, by = "GEOID") -> demos
```

We can now clean-up the global enviornment:

``` r
rm(total_pop, race, medianInc, poverty, employ, owner)
```

## Write to CSV

Finally, we’ll write the data to a `.csv` file:

``` r
write_csv(x = demos, path = here("data", "clean", "demographics.csv"))
```
