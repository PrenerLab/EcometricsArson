Create Data - Longitudinal Demographics
================
Christopher Prener, Ph.D.
(December 13, 2019)

## Introduction

This notebook calculates relevant demographic metrics for the
longitudinal analysis, including population change and percent change in
manufacturing jobs at both the MSA and city level.

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
library(tidyr)

# database access
library(DBI)
library(RSQLite)

# other packages
library(here)
```

    ## here() starts at /Users/prenercg/GitHub/PrenerLab/EcometricsArson

## Define Custom Function for SQL Queries

Since all of the database tables are structured identically, we can
query them in a uniform fashion. To make the code easier to read, we’ll
create a function that identifies observations beginning with the given
year, collects the records, and returns them as a tibble:

``` r
query <- function(db_con, firstYear){
  
  # query
  db_con %>%
    filter(name == "St. Louis") %>%
    filter(year >= firstYear) %>%
    select(year, count) %>%
    collect() -> out
  
  # return output
  return(out)
  
}
```

## Connect to MO\_CRIME\_Database.sqlite

In order to pull total population from the crime database, we need to
establish a connection to
it:

``` r
con <- dbConnect(SQLite(), here("data" , "MO_CRIME_Database", "data", "MO_CRIME_Database.sqlite"))
```

## Construct

### Total Population

There are a number of database tables that we need. For all of the
crimes, we’ll need the population for each year. The two `filter()`
calls and `select()` execute SQL queries under the hood, and `collect()`
brings the data into the global enviornment:

``` r
# establish connection
pop_db <- tbl(con, "population")

# query and collect
pop_db %>%
  query(firstYear = 1979) %>%
  rename(pop = count) -> pop
```

    ## Warning: `overscope_eval_next()` is deprecated as of rlang 0.2.0.
    ## Please use `eval_tidy()` with a data mask instead.
    ## This warning is displayed once per session.

    ## Warning: `overscope_clean()` is deprecated as of rlang 0.2.0.
    ## This warning is displayed once per session.

``` r
# remove connection
rm(pop_db)
```

### Calculate Population Change

In addition to the crime rates, we also want to add a measure of how
population numbers changed from year to year (i.e. lagged population).

``` r
pop %>%
  mutate(pop_delta = pop-lag(pop, n = 1, order_by = year)) %>%
  mutate(pop_delta_pct = pop_delta/lag(pop, n = 1, order_by = year)*100) %>%
  select(year, pop, pop_delta, pop_delta_pct, everything()) -> pop
```

### Manufacturing Jobs

The city job manufacturing data come from the [U.S. Bureau of Economic
Analysis](https://www.bea.gov/data/employment/employment-county-metro-and-other-areas).
They are in two tables because, of as 2001, the reporting scheme
changed. We therefore need to read both in, clean them up, and then join
them together. First, we’ll wrangle the pre-2001 data:

``` r
# read
city_pre00 <- read_csv(file = here("data", "raw", "employment", "city-1969_to_2000.csv"),
                       skip = 4)
```

    ## Parsed with column specification:
    ## cols(
    ##   .default = col_double(),
    ##   GeoFips = col_character(),
    ##   GeoName = col_character(),
    ##   Description = col_character(),
    ##   `1969` = col_character(),
    ##   `1970` = col_character(),
    ##   `1971` = col_character(),
    ##   `1972` = col_character(),
    ##   `1973` = col_character(),
    ##   `1974` = col_character(),
    ##   `1975` = col_character(),
    ##   `1976` = col_character(),
    ##   `1977` = col_character(),
    ##   `1978` = col_character(),
    ##   `1998` = col_character(),
    ##   `1999` = col_character(),
    ##   `2000` = col_character()
    ## )

    ## See spec(...) for full column specifications.

    ## Warning: 7 parsing failures.
    ## row col   expected    actual                                                                                         file
    ##  27  -- 36 columns 1 columns '/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/employment/city-1969_to_2000.csv'
    ##  28  -- 36 columns 1 columns '/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/employment/city-1969_to_2000.csv'
    ##  29  -- 36 columns 1 columns '/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/employment/city-1969_to_2000.csv'
    ##  30  -- 36 columns 1 columns '/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/employment/city-1969_to_2000.csv'
    ##  31  -- 36 columns 1 columns '/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/employment/city-1969_to_2000.csv'
    ## ... ... .......... ......... ............................................................................................
    ## See problems(...) for more details.

``` r
# define variables to reformat
prob_years <- as.character(c(1969:2000))

# subset and convert to long, total
city_pre00 %>%
  filter(Description == "Total employment (number of jobs)" | Description == "Manufacturing") %>%
  mutate(Description = case_when(
    Description == "Total employment (number of jobs)" ~ "total_jobs",
    Description == "Manufacturing" ~ "manu_jobs"
  )) %>%
  select(Description, `1969`:`2000`) %>%
  mutate_at(prob_years, as.numeric) %>%
  pivot_longer(-Description, names_to = "year", values_to = "count") -> city_pre00
```

We’ll repeat the exercise with the post-2000 data:

``` r
# read
city_post00 <- read_csv(file = here("data", "raw", "employment", "city-2001_to_2018.csv"),
                       skip = 4)
```

    ## Parsed with column specification:
    ## cols(
    ##   .default = col_character(),
    ##   LineCode = col_double()
    ## )

    ## See spec(...) for full column specifications.

    ## Warning: 6 parsing failures.
    ## row col   expected    actual                                                                                         file
    ##  37  -- 22 columns 1 columns '/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/employment/city-2001_to_2018.csv'
    ##  38  -- 22 columns 1 columns '/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/employment/city-2001_to_2018.csv'
    ##  39  -- 22 columns 1 columns '/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/employment/city-2001_to_2018.csv'
    ##  40  -- 22 columns 1 columns '/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/employment/city-2001_to_2018.csv'
    ##  41  -- 22 columns 1 columns '/Users/prenercg/GitHub/PrenerLab/EcometricsArson/data/raw/employment/city-2001_to_2018.csv'
    ## ... ... .......... ......... ............................................................................................
    ## See problems(...) for more details.

``` r
# define variables to reformat
prob_years <- as.character(c(2001:2018))

# subset and convert to long, total
city_post00 %>%
  filter(Description == "Total employment (number of jobs)" | Description == "Manufacturing") %>%
  mutate(Description = case_when(
    Description == "Total employment (number of jobs)" ~ "total_jobs",
    Description == "Manufacturing" ~ "manu_jobs"
  )) %>%
  select(Description, `2001`:`2018`) %>%
  mutate_at(prob_years, as.numeric) %>%
  pivot_longer(-Description, names_to = "year", values_to = "count") -> city_post00
```

With these wrangled into long data, we can bind them together, and then
pivot our numbers into two columns so that this matches the format of
the `pop` object (one row per year) and then job them to `pop`:

``` r
bind_rows(city_pre00, city_post00) %>%
  arrange(desc(Description), year) %>%
  pivot_wider(names_from = Description, values_from = count) %>%
  mutate(year = as.numeric(year)) %>%
  full_join(pop, ., by = "year") %>%
  arrange(year) -> demos
```

We can then remove our two intermediary objects:

``` r
rm(city_pre00, city_post00, pop)
```

### Manufacturing Jobs, Calculations

Finally, we’ll add a ratio of the number of manufacturing jobs to total
jobs, and also calculate year to year change:

``` r
demos %>%
  mutate(manu_delta = manu_jobs-lag(manu_jobs, n = 1, order_by = year)) %>%
  mutate(manu_delta_pct = manu_delta/lag(manu_jobs, n = 1, order_by = year)*100) %>%
  mutate(manu_delta5 = manu_jobs-lag(manu_jobs, n = 5, order_by = year)) %>%
  mutate(manu_delta_pct5 = manu_delta5/lag(manu_jobs, n = 5, order_by = year)*100) -> demos
```

## Write Data

Finally, we’ll write our demographic data to `.csv`:

``` r
write_csv(demos, path = here("data", "clean", "longitudinal_demos.csv"))
```
