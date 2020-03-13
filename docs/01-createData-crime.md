Create Data - Crime
================
Christopher Prener, Ph.D.
(March 13, 2020)

## Introduction

This notebook creates the crime data sets needed for the arson analyses.

## Dependencies

This notebook requires a number of packages to working with data and
wrangling it.

``` r
# tidystl packages
library(compstatr)     # access crime data

# tidyverse packages
library(dplyr)         # data wrangling
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
library(readr)         # write csv files

# other packages
library(here)          # file path management
```

    ## here() starts at /Users/prenercg/GitHub/PrenerLab/EcometricsArson

``` r
library(testthat)      # unit testing
```

    ## 
    ## Attaching package: 'testthat'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     matches

## Prepare Data

### Download Data

First, we’ll scrape data from the SLMPD website to create our raw data
frames. To accomplish this, we need to create a index object:

``` r
i <- cs_create_index()
```

With our index, we can create raw year-list objects:

``` r
data2018_raw <- cs_get_data(year = 2018, index = i)
data2017_raw <- cs_get_data(year = 2017, index = i)
data2016_raw <- cs_get_data(year = 2016, index = i)
data2015_raw <- cs_get_data(year = 2015, index = i)
data2014_raw <- cs_get_data(year = 2014, index = i)
data2013_raw <- cs_get_data(year = 2013, index = i)
data2012_raw <- cs_get_data(year = 2012, index = i)
data2011_raw <- cs_get_data(year = 2011, index = i)
data2010_raw <- cs_get_data(year = 2010, index = i)
data2009_raw <- cs_get_data(year = 2009, index = i)
data2008_raw <- cs_get_data(year = 2008, index = i)
```

### 2018

We validate the data to make sure it can be collapsed using
`cs_validate()`:

``` r
expect_equal(cs_validate(data2018_raw, year = "2018"), TRUE)
```

Since the validation result is a value of `TRUE`, we can proceed to
collapsing the year-list object into a single tibble with
`cs_collapse()` and then stripping out crimes reported in 2018 for
earlier years using `cs_combine()`. We also strip out unfounded crimes
that remain using `cs_filter_count()`:

``` r
# collapse into single object
data2018_raw <- cs_collapse(data2018_raw)

# combine and filter
cs_combine(type = "year", date = 2018, data2018_raw) %>%
  cs_filter_count(var = count) -> data2018
```

The `data2018` object now contains only crimes reported in 2018.

### 2017

We’ll repeat the validation process with the 2017 data:

``` r
expect_equal(cs_validate(data2017_raw, year = "2017"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2017_raw, year = "2017", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount valVars
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>    <lgl>  
    ##  1 January    January    TRUE          2017 TRUE    TRUE     TRUE     TRUE   
    ##  2 February   February   TRUE          2017 TRUE    TRUE     TRUE     TRUE   
    ##  3 March      March      TRUE          2017 TRUE    TRUE     TRUE     TRUE   
    ##  4 April      April      TRUE          2017 TRUE    TRUE     TRUE     TRUE   
    ##  5 May        May        TRUE          2017 TRUE    TRUE     FALSE    NA     
    ##  6 June       June       TRUE          2017 TRUE    TRUE     TRUE     TRUE   
    ##  7 July       July       TRUE          2017 TRUE    TRUE     TRUE     TRUE   
    ##  8 August     August     TRUE          2017 TRUE    TRUE     TRUE     TRUE   
    ##  9 September  September  TRUE          2017 TRUE    TRUE     TRUE     TRUE   
    ## 10 October    October    TRUE          2017 TRUE    TRUE     TRUE     TRUE   
    ## 11 November   November   TRUE          2017 TRUE    TRUE     TRUE     TRUE   
    ## 12 December   December   TRUE          2017 TRUE    TRUE     TRUE     TRUE

The data for May 2017 do not pass the validation checks. We can extract
this month and confirm that there are too many columns in the May 2017
release. Once we have that confirmed, we can standardize that month and
re-run our validation.

``` r
# extract data and unit test column numbers
expect_equal(ncol(cs_extract_month(data2017_raw, month = "May")), 26)

# standardize months
data2017_raw <- cs_standardize(data2017_raw, month = "May", config = 26)

# validate data
expect_equal(cs_validate(data2017_raw, year = "2017"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing the 2017 and 2018 raw data objects to create a new object,
`data2017`, that contains all known 2017 crimes including those that
were reported or upgraded in 2018.

``` r
# collapse into single object
data2017_raw <- cs_collapse(data2017_raw)

# combine and filter
cs_combine(type = "year", date = 2017, data2018_raw, data2017_raw) %>%
  cs_filter_count(var = count) -> data2017
```

### 2016

We’ll repeat the validation process with the 2016 data:

``` r
expect_equal(cs_validate(data2016_raw, year = "2016"), TRUE)
```

Since the validation process passes, we can immediately move on to
creating our 2016 data object:

``` r
# collapse into single object
data2016_raw <- cs_collapse(data2016_raw)

# combine and filter
cs_combine(type = "year", date = 2016, data2018_raw, data2017_raw, data2016_raw) %>%
  cs_filter_count(var = count) -> data2016
```

### 2015

We’ll repeat the validation process with the 2015 data:

``` r
expect_equal(cs_validate(data2015_raw, year = "2015"), TRUE)
```

Since the validation process passes, we can immediately move on to
creating our 2015 data object:

``` r
# collapse into single object
data2015_raw <- cs_collapse(data2015_raw)

# combine and filter
cs_combine(type = "year", date = 2015, data2018_raw, data2017_raw, data2016_raw, data2015_raw) %>%
  cs_filter_count(var = count) -> data2015
```

### 2014

We’ll repeat the validation process with the 2014 data:

``` r
expect_equal(cs_validate(data2014_raw, year = "2014"), TRUE)
```

Since the validation process passes, we can immediately move on to
creating our 2015 data object:

``` r
# collapse into single object
data2014_raw <- cs_collapse(data2014_raw)

# combine and filter
cs_combine(type = "year", date = 2014, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw) %>%
  cs_filter_count(var = count) -> data2014
```

### 2013

We’ll repeat the validation process with the 2013 data:

``` r
expect_equal(cs_validate(data2013_raw, year = "2013"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2013_raw, year = "2013", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount valVars
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>    <lgl>  
    ##  1 January    January    TRUE          2013 TRUE    TRUE     FALSE    NA     
    ##  2 February   February   TRUE          2013 TRUE    TRUE     FALSE    NA     
    ##  3 March      March      TRUE          2013 TRUE    TRUE     FALSE    NA     
    ##  4 April      April      TRUE          2013 TRUE    TRUE     FALSE    NA     
    ##  5 May        May        TRUE          2013 TRUE    TRUE     FALSE    NA     
    ##  6 June       June       TRUE          2013 TRUE    TRUE     TRUE     TRUE   
    ##  7 July       July       TRUE          2013 TRUE    TRUE     FALSE    NA     
    ##  8 August     August     TRUE          2013 TRUE    TRUE     FALSE    NA     
    ##  9 September  September  TRUE          2013 TRUE    TRUE     TRUE     TRUE   
    ## 10 October    October    TRUE          2013 TRUE    TRUE     TRUE     TRUE   
    ## 11 November   November   TRUE          2013 TRUE    TRUE     TRUE     TRUE   
    ## 12 December   December   TRUE          2013 TRUE    TRUE     TRUE     TRUE

The data for January through May, July, and August do not pass the
validation checks. We can extract these and confirm that there are not
enough columns in each of these releases Once we have that confirmed, we
can standardize that month and re-run our validation.

``` r
# January - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "January")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "January", config = 18)

# February - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "February")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "February", config = 18)

# March - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "March")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "March", config = 18)

# April - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "April")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "April", config = 18)

# May - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "May")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "May", config = 18)

# July - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "July")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "July", config = 18)

# August - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2013_raw, month = "August")), 18)
data2013_raw <- cs_standardize(data2013_raw, month = "August", config = 18)
# remove object
rm(month13)
```

    ## Warning in rm(month13): object 'month13' not found

``` r
# validate data
expect_equal(cs_validate(data2013_raw, year = "2013"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `data2013`, that
contains all known 2013 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2013_raw <- cs_collapse(data2013_raw)

# combine and filter
cs_combine(type = "year", date = 2013, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, 
           data2013_raw) %>%
  cs_filter_count(var = count) -> data2013
```

### 2012

We’ll repeat the validation process with the 2012 data:

``` r
expect_equal(cs_validate(data2012_raw, year = "2012"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2012_raw, year = "2012", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount valVars
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>    <lgl>  
    ##  1 January    January    TRUE          2012 TRUE    TRUE     FALSE    NA     
    ##  2 February   February   TRUE          2012 TRUE    TRUE     FALSE    NA     
    ##  3 March      March      TRUE          2012 TRUE    TRUE     FALSE    NA     
    ##  4 April      April      TRUE          2012 TRUE    TRUE     FALSE    NA     
    ##  5 May        May        TRUE          2012 TRUE    TRUE     FALSE    NA     
    ##  6 June       June       TRUE          2012 TRUE    TRUE     FALSE    NA     
    ##  7 July       July       TRUE          2012 TRUE    TRUE     FALSE    NA     
    ##  8 August     August     TRUE          2012 TRUE    TRUE     FALSE    NA     
    ##  9 September  September  TRUE          2012 TRUE    TRUE     FALSE    NA     
    ## 10 October    October    TRUE          2012 TRUE    TRUE     FALSE    NA     
    ## 11 November   November   TRUE          2012 TRUE    TRUE     FALSE    NA     
    ## 12 December   December   TRUE          2012 TRUE    TRUE     FALSE    NA

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test
expect_equal(ncol(cs_extract_month(data2012_raw, month = "January")), 18)

# standardize
data2012_raw <- cs_standardize(data2012_raw, month = "all", config = 18)

# validate data
expect_equal(cs_validate(data2012_raw, year = "2012"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `data2012`, that
contains all known 2012 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2012_raw <- cs_collapse(data2012_raw)

# combine and filter
cs_combine(type = "year", date = 2012, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, 
           data2013_raw, data2012_raw) %>%
  cs_filter_count(var = count) -> data2012
```

### 2011

We’ll repeat the validation process with the 2011 data:

``` r
expect_equal(cs_validate(data2011_raw, year = "2011"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2011_raw, year = "2011", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount valVars
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>    <lgl>  
    ##  1 January    January    TRUE          2011 TRUE    TRUE     FALSE    NA     
    ##  2 February   February   TRUE          2011 TRUE    TRUE     FALSE    NA     
    ##  3 March      March      TRUE          2011 TRUE    TRUE     FALSE    NA     
    ##  4 April      April      TRUE          2011 TRUE    TRUE     FALSE    NA     
    ##  5 May        May        TRUE          2011 TRUE    TRUE     FALSE    NA     
    ##  6 June       June       TRUE          2011 TRUE    TRUE     FALSE    NA     
    ##  7 July       July       TRUE          2011 TRUE    TRUE     FALSE    NA     
    ##  8 August     August     TRUE          2011 TRUE    TRUE     FALSE    NA     
    ##  9 September  September  TRUE          2011 TRUE    TRUE     FALSE    NA     
    ## 10 October    October    TRUE          2011 TRUE    TRUE     FALSE    NA     
    ## 11 November   November   TRUE          2011 TRUE    TRUE     FALSE    NA     
    ## 12 December   December   TRUE          2011 TRUE    TRUE     FALSE    NA

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test
expect_equal(ncol(cs_extract_month(data2011_raw, month = "January")), 18)

# standardize
data2011_raw <- cs_standardize(data2011_raw, month = "all", config = 18)

# validate data
expect_equal(cs_validate(data2011_raw, year = "2011"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `data2011`, that
contains all known 2011 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2011_raw <- cs_collapse(data2011_raw)

# combine and filter
cs_combine(type = "year", date = 2011, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, 
           data2013_raw, data2012_raw, data2011_raw) %>%
  cs_filter_count(var = count) -> data2011
```

### 2010

We’ll repeat the validation process with the 2010 data:

``` r
expect_equal(cs_validate(data2010_raw, year = "2010"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2010_raw, year = "2010", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount valVars
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>    <lgl>  
    ##  1 January    January    TRUE          2010 TRUE    TRUE     FALSE    NA     
    ##  2 February   February   TRUE          2010 TRUE    TRUE     FALSE    NA     
    ##  3 March      March      TRUE          2010 TRUE    TRUE     FALSE    NA     
    ##  4 April      April      TRUE          2010 TRUE    TRUE     FALSE    NA     
    ##  5 May        May        TRUE          2010 TRUE    TRUE     FALSE    NA     
    ##  6 June       June       TRUE          2010 TRUE    TRUE     FALSE    NA     
    ##  7 July       July       TRUE          2010 TRUE    TRUE     FALSE    NA     
    ##  8 August     August     TRUE          2010 TRUE    TRUE     FALSE    NA     
    ##  9 September  September  TRUE          2010 TRUE    TRUE     FALSE    NA     
    ## 10 October    October    TRUE          2010 TRUE    TRUE     FALSE    NA     
    ## 11 November   November   TRUE          2010 TRUE    TRUE     FALSE    NA     
    ## 12 December   December   TRUE          2010 TRUE    TRUE     FALSE    NA

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test
expect_equal(ncol(cs_extract_month(data2010_raw, month = "January")), 18)

# standardize all months
data2010_raw <- cs_standardize(data2010_raw, month = "all", config = 18)

# validate data
expect_equal(cs_validate(data2010_raw, year = "2010"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `data2010`, that
contains all known 2010 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2010_raw <- cs_collapse(data2010_raw)

# combine and filter
cs_combine(type = "year", date = 2010, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, 
           data2013_raw, data2012_raw, data2011_raw, data2010_raw) %>%
  cs_filter_count(var = count) -> data2010
```

### 2009

We’ll repeat the validation process with the 2009 data:

``` r
expect_equal(cs_validate(data2009_raw, year = "2009"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2009_raw, year = "2009", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount valVars
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>    <lgl>  
    ##  1 January    January    TRUE          2009 TRUE    TRUE     FALSE    NA     
    ##  2 February   February   TRUE          2009 TRUE    TRUE     FALSE    NA     
    ##  3 March      March      TRUE          2009 TRUE    TRUE     FALSE    NA     
    ##  4 April      April      TRUE          2009 TRUE    TRUE     FALSE    NA     
    ##  5 May        May        TRUE          2009 TRUE    TRUE     FALSE    NA     
    ##  6 June       June       TRUE          2009 TRUE    TRUE     FALSE    NA     
    ##  7 July       July       TRUE          2009 TRUE    TRUE     FALSE    NA     
    ##  8 August     August     TRUE          2009 TRUE    TRUE     FALSE    NA     
    ##  9 September  September  TRUE          2009 TRUE    TRUE     FALSE    NA     
    ## 10 October    October    TRUE          2009 TRUE    TRUE     FALSE    NA     
    ## 11 November   November   TRUE          2009 TRUE    TRUE     FALSE    NA     
    ## 12 December   December   TRUE          2009 TRUE    TRUE     FALSE    NA

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test
expect_equal(ncol(cs_extract_month(data2009_raw, month = "January")), 18)

# standardize all months
data2009_raw <- cs_standardize(data2009_raw, month = "all", config = 18)

# validate data
expect_equal(cs_validate(data2009_raw, year = "2009"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `data2009`, that
contains all known 2009 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2009_raw <- cs_collapse(data2009_raw)

# combine and filter
cs_combine(type = "year", date = 2009, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, 
           data2013_raw, data2012_raw, data2011_raw, data2010_raw, data2009_raw) %>%
  cs_filter_count(var = count) -> data2009
```

### 2008

We’ll repeat the validation process with the 2008 data:

``` r
expect_equal(cs_validate(data2008_raw, year = "2008"), FALSE)
```

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate(data2008_raw, year = "2008", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount valVars
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>    <lgl>  
    ##  1 January    January    TRUE          2008 TRUE    TRUE     FALSE    NA     
    ##  2 February   February   TRUE          2008 TRUE    TRUE     FALSE    NA     
    ##  3 March      March      TRUE          2008 TRUE    TRUE     FALSE    NA     
    ##  4 April      April      TRUE          2008 TRUE    TRUE     FALSE    NA     
    ##  5 May        May        TRUE          2008 TRUE    TRUE     FALSE    NA     
    ##  6 June       June       TRUE          2008 TRUE    TRUE     FALSE    NA     
    ##  7 July       July       TRUE          2008 TRUE    TRUE     FALSE    NA     
    ##  8 August     August     TRUE          2008 TRUE    TRUE     FALSE    NA     
    ##  9 September  September  TRUE          2008 TRUE    TRUE     FALSE    NA     
    ## 10 October    October    TRUE          2008 TRUE    TRUE     FALSE    NA     
    ## 11 November   November   TRUE          2008 TRUE    TRUE     FALSE    NA     
    ## 12 December   December   TRUE          2008 TRUE    TRUE     FALSE    NA

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test,
expect_equal(ncol(cs_extract_month(data2008_raw, month = "January")), 18)

# standardize all months
data2008_raw <- cs_standardize(data2008_raw, month = "all", config = 18)

# validate data
expect_equal(cs_validate(data2008_raw, year = "2008"), TRUE)
```

We now get a `TRUE` value for `cs_validate()` and can move on to
collapsing our raw data objects to create a new object, `data2008`, that
contains all known 2008 crimes including those that were reported or
upgraded in subsequent years:

## Clean-up Enviornment

We can remove the `_raw` objects at this point as well as the
index:

``` r
rm(data2008_raw, data2009_raw, data2010_raw, data2011_raw, data2012_raw, data2013_raw, data2014_raw, data2015_raw, data2016_raw, data2017_raw, data2018_raw, i)
```

## Create Single Table

Next, we’ll create a single table before we remove individual years. We
also subset columns to reduce the footprint of the
table.

``` r
bind_rows(data2008, data2009, data2010, data2011, data2012, data2013, data2014, data2015, data2016, data2017, data2018) %>%
  select(cs_year, date_occur, crime, description, ileads_address, ileads_street, x_coord, y_coord) -> allCrimes
```

### Clean-up Enviornment

We’ll remove excess objects
again:

``` r
rm(data2008, data2009, data2010, data2011, data2012, data2013, data2014, data2015, data2016, data2017, data2018)
```

## Categorize Crimes and Subset

Next, we’ll pull out arsons and then write them to a `.csv` file:

``` r
allCrimes %>%
  cs_filter_crime(var = crime, crime = "arson") %>%
  write_csv(here("data", "clean", "point_arson.csv"))
```

Next, we’ll create a subset that is only violent crimes:

``` r
allCrimes %>%
  cs_filter_crime(var = crime, crime = "violent") %>%
  write_csv(here("data", "clean", "point_violent.csv"))
```

### Property Crimes

Next, we’ll create a subset that is only non-arson property crimes:

``` r
allCrimes %>%
  cs_filter_crime(var = crime, crime = "property") %>%
  cs_crime_cat(var = crime, newVar = cat, output = "numeric") %>%
  filter(cat %in% c(5:7)) %>%
  select(-cat) %>%
  write_csv(here("data", "clean", "point_property.csv"))
```

### Other Crimes

Finally, we’ll create a subset with a few key Part 2 crimes:

  - Vandalism
  - Weapons
  - Drug Abuse Violations
  - Vagrancy

<!-- end list -->

``` r
allCrimes %>%
  cs_crime_cat(var = crime, newVar = cat, output = "numeric") %>%
  filter(cat %in% c(14, 15, 18, 24)) %>%
  select(-cat) %>%
  write_csv(here("data", "clean", "point_otherCrimes.csv"))
```
