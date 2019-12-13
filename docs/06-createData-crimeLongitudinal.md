Create Data - Longitudinal Crime Data
================
Christopher Prener, Ph.D.
(December 13, 2019)

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
  query(firstYear = 1980) %>%
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

### Arson Rate

Next, we’ll query the database again to obtain counts of arson fires.
Then we’ll join it with the population data and calculate an arson rate:

``` r
# establish connection
arson_db <- tbl(con, "arson")

# query, collect, join, and calculate rate
arson_db %>%
  query(firstYear = 1980) %>%
  rename(arson = count) %>%
  left_join(pop, ., by = "year") %>%
  mutate(arson_rate = (arson/pop)*100000) -> crime

# remove connection
rm(arson_db, pop)
```

Now, we can continue to add to the `crime` object, using the existing
`pop` column to calculate rates.

### Violent Crime Rate

Next, we’ll calculate a violent crime rate for each year. This involves
querying records from four tables, collecting them, and then summing
their columns to get a total number of violent crimes before a rate is
calculated.

``` r
# establish connections
homicide_db <- tbl(con, "homicide")
agAssault_db <- tbl(con, "agAssault")
rape_db <- tbl(con, "rape")
robbery_db <- tbl(con, "robbery")

# homicide - query and collect
homicide_db %>%
  query(firstYear = 1980) %>%
  rename(homicide = count) -> homicide

# aggrevated assault - query and collect
agAssault_db %>%
  query(firstYear = 1980) %>%
  rename(agAssault = count) -> agAssault

# rape - query and collect
rape_db %>%
  query(firstYear = 1980) %>%
  rename(rape = count) -> rape

# robbery - query and collect
robbery_db %>%
  query(firstYear = 1980) %>%
  rename(robbery = count) -> robbery

# jobin and calculate rates
crime %>%
  left_join(., homicide, by = "year") %>%
  left_join(., agAssault, by = "year") %>%
  left_join(., rape, by = "year") %>%
  left_join(., robbery, by = "year") %>%
  mutate(violent = homicide+agAssault+rape+robbery) %>%
  select(-homicide, -agAssault, -rape, -robbery) %>%
  mutate(violent_rate = (violent/pop)*100000) -> crime

# remove connections
rm(homicide_db, agAssault_db, rape_db, robbery_db,
   homicide, agAssault, rape, robbery)
```

## Larceny Rate

Next, we’ll calculate a larceny rate for each year that includes
burglaries, larcenies, and motor vehicle thefts. This is the same as the
“crimes against property” concept but leaves arsons out, since they are
the dependent variable.

``` r
# establish connections
robbery_db <- tbl(con, "robbery")
larceny_db <- tbl(con, "larceny")
autoTheft_db <- tbl(con, "autoTheft")

# robbery - query and collect
robbery_db %>%
  query(firstYear = 1980) %>%
  rename(robbery = count) -> robbery

# larceny - query and collect
larceny_db %>%
  query(firstYear = 1980) %>%
  rename(larceny = count) -> larceny

# auto theft - query and collect
autoTheft_db %>%
  query(firstYear = 1980) %>%
  rename(autoTheft = count) -> autoTheft

# jobin and calculate rates
crime %>%
  left_join(., robbery, by = "year") %>%
  left_join(., larceny, by = "year") %>%
  left_join(., autoTheft, by = "year") %>%
  mutate(larceny_count = robbery+larceny+autoTheft) %>%
  select(-robbery, -larceny, -autoTheft) %>%
  rename(larceny = larceny_count) %>%
  mutate(larceny_rate = (larceny/pop)*100000) -> crime

# remove connections
rm(robbery_db, larceny_db, autoTheft_db,
   robbery, larceny, autoTheft)
```

## Remove Population

Finally, we’ll remove population since that would otherwise be
duplicated in the next notebook:

``` r
crime <- select(crime, -pop)
```

## Write Data

Finally, we’ll write our crime rate data to `.csv`:

``` r
write_csv(crime, path = here("data", "clean", "longitudinal_crime.csv"))
```
