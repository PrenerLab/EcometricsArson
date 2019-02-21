Create Data - Crime
================
Christopher Prener, Ph.D.
(February 21, 2019)

## Introduction

This notebook creates the crime data sets needed for the arson analyses.

## Dependencies

This notebook requires a number of packages to working with data and
wrangling it.

``` r
# tidystl packages
library(compstatr)

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
library(purrr)
library(readr)

# other packages
library(here)
```

    ## here() starts at /Users/prenercg/Desktop/arsonSTL

``` r
library(testthat)
```

    ## 
    ## Attaching package: 'testthat'

    ## The following object is masked from 'package:purrr':
    ## 
    ##     is_null

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     matches

## Prepare Data

### Create Objects

First, we prep the raw data by converting filenames like
`January2018.CSV.html` to `january2018.csv`. This is done with the
`cs_prep_year()` function, which is combined here with `map()` to
iterate over a vector of years that correspond to the raw data
subfolders.

``` r
# create vector of years to clean
years <- as.character(2008:2018)

# clean data files
years %>%
  split(years) %>%
  map(~ cs_prep_year(here("data", "raw", .x))) -> out

# remove output
rm(years, out)
```

### Load Raw Data

Next, we load year-list objects using `cs_load_year()`:

``` r
data2018_raw <- cs_load_year(here("data", "raw", "2018"))
data2017_raw <- cs_load_year(here("data", "raw", "2017"))
data2016_raw <- cs_load_year(here("data", "raw", "2016"))
data2015_raw <- cs_load_year(here("data", "raw", "2015"))
data2014_raw <- cs_load_year(here("data", "raw", "2014"))
data2013_raw <- cs_load_year(here("data", "raw", "2013"))
data2012_raw <- cs_load_year(here("data", "raw", "2012"))
data2011_raw <- cs_load_year(here("data", "raw", "2011"))
data2010_raw <- cs_load_year(here("data", "raw", "2010"))
data2009_raw <- cs_load_year(here("data", "raw", "2009"))
data2008_raw <- cs_load_year(here("data", "raw", "2008"))
```

### 2018

We validate the data to make sure it can be collapsed using
`cs_validate_year()`:

``` r
cs_validate_year(data2018_raw, year = "2018")
```

    ## [1] TRUE

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
  cs_filter_count(var = Count) -> data2018
```

The `data2018` object now contains only crimes reported in 2018.

### 2017

We’ll repeat the validation process with the 2017 data:

``` r
cs_validate_year(data2017_raw, year = "2017")
```

    ## [1] FALSE

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate_year(data2017_raw, year = "2017", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2017 TRUE    TRUE     TRUE    
    ##  2 February   February   TRUE          2017 TRUE    TRUE     TRUE    
    ##  3 March      March      TRUE          2017 TRUE    TRUE     TRUE    
    ##  4 April      April      TRUE          2017 TRUE    TRUE     TRUE    
    ##  5 May        May        TRUE          2017 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2017 TRUE    TRUE     TRUE    
    ##  7 July       July       TRUE          2017 TRUE    TRUE     TRUE    
    ##  8 August     August     TRUE          2017 TRUE    TRUE     TRUE    
    ##  9 September  September  TRUE          2017 TRUE    TRUE     TRUE    
    ## 10 October    October    TRUE          2017 TRUE    TRUE     TRUE    
    ## 11 November   November   TRUE          2017 TRUE    TRUE     TRUE    
    ## 12 December   December   TRUE          2017 TRUE    TRUE     TRUE    
    ## # … with 1 more variable: valVars <lgl>

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
cs_validate_year(data2017_raw, year = "2017")
```

    ## [1] TRUE

We now get a `TRUE` value for `cs_validate_year()` and can move on to
collapsing the 2017 and 2018 raw data objects to create a new object,
`data2017`, that contains all known 2017 crimes including those that
were reported or upgraded in 2018.

``` r
# collapse into single object
data2017_raw <- cs_collapse(data2017_raw)

# combine and filter
cs_combine(type = "year", date = 2017, data2018_raw, data2017_raw) %>%
  cs_filter_count(var = Count) -> data2017
```

### 2016

We’ll repeat the validation process with the 2016 data:

``` r
cs_validate_year(data2016_raw, year = "2016")
```

    ## [1] TRUE

Since the validation process passes, we can immediately move on to
creating our 2016 data object:

``` r
# collapse into single object
data2016_raw <- cs_collapse(data2016_raw)

# combine and filter
cs_combine(type = "year", date = 2016, data2018_raw, data2017_raw, data2016_raw) %>%
  cs_filter_count(var = Count) -> data2016
```

### 2015

We’ll repeat the validation process with the 2015 data:

``` r
cs_validate_year(data2015_raw, year = "2015")
```

    ## [1] TRUE

Since the validation process passes, we can immediately move on to
creating our 2015 data object:

``` r
# collapse into single object
data2015_raw <- cs_collapse(data2015_raw)

# combine and filter
cs_combine(type = "year", date = 2015, data2018_raw, data2017_raw, data2016_raw, data2015_raw) %>%
  cs_filter_count(var = Count) -> data2015
```

### 2014

We’ll repeat the validation process with the 2014 data:

``` r
cs_validate_year(data2014_raw, year = "2014")
```

    ## [1] TRUE

Since the validation process passes, we should be able to immediately
move on to creating our 2014 data object. However, we get an error when
we go to collapse our data because `ILEADSAddrress` is character in a
particular month:

``` r
# extract data
jan2014 <- cs_extract_month(data2014_raw, month = "January")

# unit test column number
expect_equal(class(jan2014$ILEADSAddress), "character")

# fix ILEADSAddress
jan2014 <- mutate(jan2014, ILEADSAddress = as.numeric(ILEADSAddress))
```

    ## Warning: NAs introduced by coercion

``` r
# replace data
data2014_raw <- cs_replace_month(data2014_raw, month = "January", jan2014)

# remove object
rm(jan2014)

# validate data
cs_validate_year(data2014_raw, year = "2014")
```

    ## [1] TRUE

After double-checking our validation, we can now collapse our data:

``` r
# collapse into single object
data2014_raw <- cs_collapse(data2014_raw)

# combine and filter
cs_combine(type = "year", date = 2014, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw) %>%
  cs_filter_count(var = Count) -> data2014
```

### 2013

We’ll repeat the validation process with the 2013 data:

``` r
cs_validate_year(data2013_raw, year = "2013")
```

    ## [1] FALSE

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate_year(data2013_raw, year = "2013", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2013 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2013 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2013 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2013 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2013 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2013 TRUE    TRUE     TRUE    
    ##  7 July       July       TRUE          2013 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2013 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2013 TRUE    TRUE     TRUE    
    ## 10 October    October    TRUE          2013 TRUE    TRUE     TRUE    
    ## 11 November   November   TRUE          2013 TRUE    TRUE     TRUE    
    ## 12 December   December   TRUE          2013 TRUE    TRUE     TRUE    
    ## # … with 1 more variable: valVars <lgl>

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
cs_validate_year(data2013_raw, year = "2013")
```

    ## [1] TRUE

We now get a `TRUE` value for `cs_validate_year()` and can move on to
collapsing our raw data objects to create a new object, `data2013`, that
contains all known 2013 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2013_raw <- cs_collapse(data2013_raw)

# combine and filter
cs_combine(type = "year", date = 2013, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw) %>%
  cs_filter_count(var = Count) -> data2013
```

### 2012

We’ll repeat the validation process with the 2012 data:

``` r
cs_validate_year(data2012_raw, year = "2012")
```

    ## [1] FALSE

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate_year(data2012_raw, year = "2012", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2012 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2012 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2012 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2012 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2012 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2012 TRUE    TRUE     FALSE   
    ##  7 July       July       TRUE          2012 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2012 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2012 TRUE    TRUE     FALSE   
    ## 10 October    October    TRUE          2012 TRUE    TRUE     FALSE   
    ## 11 November   November   TRUE          2012 TRUE    TRUE     FALSE   
    ## 12 December   December   TRUE          2012 TRUE    TRUE     FALSE   
    ## # … with 1 more variable: valVars <lgl>

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "January")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "January", config = 18)

# February - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "February")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "February", config = 18)

# March - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "March")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "March", config = 18)

# April - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "April")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "April", config = 18)

# May - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "May")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "May", config = 18)

# June - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "June")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "June", config = 18)

# July - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "July")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "July", config = 18)

# August - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "August")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "August", config = 18)

# September - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "September")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "September", config = 18)

# October - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "October")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "October", config = 18)

# November - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "November")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "November", config = 18)

# December - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2012_raw, month = "December")), 18)
data2012_raw <- cs_standardize(data2012_raw, month = "December", config = 18)

# validate data
cs_validate_year(data2012_raw, year = "2012")
```

    ## [1] TRUE

We now get a `TRUE` value for `cs_validate_year()` and can move on to
collapsing our raw data objects to create a new object, `data2012`, that
contains all known 2012 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2012_raw <- cs_collapse(data2012_raw)

# combine and filter
cs_combine(type = "year", date = 2012, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw, data2012_raw) %>%
  cs_filter_count(var = Count) -> data2012
```

### 2011

We’ll repeat the validation process with the 2011 data:

``` r
cs_validate_year(data2011_raw, year = "2011")
```

    ## [1] FALSE

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate_year(data2011_raw, year = "2011", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2011 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2011 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2011 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2011 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2011 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2011 TRUE    TRUE     FALSE   
    ##  7 July       July       TRUE          2011 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2011 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2011 TRUE    TRUE     FALSE   
    ## 10 October    October    TRUE          2011 TRUE    TRUE     FALSE   
    ## 11 November   November   TRUE          2011 TRUE    TRUE     FALSE   
    ## 12 December   December   TRUE          2011 TRUE    TRUE     FALSE   
    ## # … with 1 more variable: valVars <lgl>

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "January")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "January", config = 18)

# February - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "February")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "February", config = 18)

# March - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "March")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "March", config = 18)

# April - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "April")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "April", config = 18)

# May - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "May")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "May", config = 18)

# June - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "June")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "June", config = 18)

# July - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "July")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "July", config = 18)

# August - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "August")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "August", config = 18)

# September - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "September")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "September", config = 18)

# October - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "October")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "October", config = 18)

# November - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "November")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "November", config = 18)

# December - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2011_raw, month = "December")), 18)
data2011_raw <- cs_standardize(data2011_raw, month = "December", config = 18)

# validate data
cs_validate_year(data2011_raw, year = "2011")
```

    ## [1] TRUE

We now get a `TRUE` value for `cs_validate_year()` and can move on to
collapsing our raw data objects to create a new object, `data2011`, that
contains all known 2011 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2011_raw <- cs_collapse(data2011_raw)

# combine and filter
cs_combine(type = "year", date = 2011, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw, data2012_raw, data2011_raw) %>%
  cs_filter_count(var = Count) -> data2011
```

### 2010

We’ll repeat the validation process with the 2010 data:

``` r
cs_validate_year(data2010_raw, year = "2010")
```

    ## [1] FALSE

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate_year(data2010_raw, year = "2010", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2010 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2010 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2010 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2010 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2010 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2010 TRUE    TRUE     FALSE   
    ##  7 July       July       TRUE          2010 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2010 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2010 TRUE    TRUE     FALSE   
    ## 10 October    October    TRUE          2010 TRUE    TRUE     FALSE   
    ## 11 November   November   TRUE          2010 TRUE    TRUE     FALSE   
    ## 12 December   December   TRUE          2010 TRUE    TRUE     FALSE   
    ## # … with 1 more variable: valVars <lgl>

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "January")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "January", config = 18)

# February - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "February")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "February", config = 18)

# March - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "March")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "March", config = 18)

# April - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "April")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "April", config = 18)

# May - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "May")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "May", config = 18)

# June - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "June")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "June", config = 18)

# July - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "July")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "July", config = 18)

# August - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "August")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "August", config = 18)

# September - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "September")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "September", config = 18)

# October - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "October")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "October", config = 18)

# November - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "November")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "November", config = 18)

# December - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2010_raw, month = "December")), 18)
data2010_raw <- cs_standardize(data2010_raw, month = "December", config = 18)

# validate data
cs_validate_year(data2010_raw, year = "2010")
```

    ## [1] TRUE

We now get a `TRUE` value for `cs_validate_year()` and can move on to
collapsing our raw data objects to create a new object, `data2010`, that
contains all known 2010 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2010_raw <- cs_collapse(data2010_raw)

# combine and filter
cs_combine(type = "year", date = 2010, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw, data2012_raw, data2011_raw, data2010_raw) %>%
  cs_filter_count(var = Count) -> data2010
```

### 2009

We’ll repeat the validation process with the 2009 data:

``` r
cs_validate_year(data2009_raw, year = "2009")
```

    ## [1] FALSE

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate_year(data2009_raw, year = "2009", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2009 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2009 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2009 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2009 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2009 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2009 TRUE    TRUE     FALSE   
    ##  7 July       July       TRUE          2009 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2009 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2009 TRUE    TRUE     FALSE   
    ## 10 October    October    TRUE          2009 TRUE    TRUE     FALSE   
    ## 11 November   November   TRUE          2009 TRUE    TRUE     FALSE   
    ## 12 December   December   TRUE          2009 TRUE    TRUE     FALSE   
    ## # … with 1 more variable: valVars <lgl>

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "January")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "January", config = 18)

# February - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "February")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "February", config = 18)

# March - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "March")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "March", config = 18)

# April - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "April")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "April", config = 18)

# May - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "May")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "May", config = 18)

# June - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "June")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "June", config = 18)

# July - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "July")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "July", config = 18)

# August - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "August")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "August", config = 18)

# September - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "September")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "September", config = 18)

# October - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "October")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "October", config = 18)

# November - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "November")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "November", config = 18)

# December - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2009_raw, month = "December")), 18)
data2009_raw <- cs_standardize(data2009_raw, month = "December", config = 18)

# validate data
cs_validate_year(data2009_raw, year = "2009")
```

    ## [1] TRUE

We now get a `TRUE` value for `cs_validate_year()` and can move on to
collapsing our raw data objects to create a new object, `data2009`, that
contains all known 2009 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2009_raw <- cs_collapse(data2009_raw)

# combine and filter
cs_combine(type = "year", date = 2009, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw, data2012_raw, data2011_raw, data2010_raw, data2009_raw) %>%
  cs_filter_count(var = Count) -> data2009
```

### 2008

We’ll repeat the validation process with the 2009 data:

``` r
cs_validate_year(data2008_raw, year = "2008")
```

    ## [1] FALSE

Since we fail the validation, we can use the `verbose = TRUE` option to
get a summary of where validation issues are occuring.

``` r
cs_validate_year(data2008_raw, year = "2008", verbose = TRUE)
```

    ## # A tibble: 12 x 8
    ##    namedMonth codedMonth valMonth codedYear valYear oneMonth varCount
    ##    <chr>      <chr>      <lgl>        <int> <lgl>   <lgl>    <lgl>   
    ##  1 January    January    TRUE          2008 TRUE    TRUE     FALSE   
    ##  2 February   February   TRUE          2008 TRUE    TRUE     FALSE   
    ##  3 March      March      TRUE          2008 TRUE    TRUE     FALSE   
    ##  4 April      April      TRUE          2008 TRUE    TRUE     FALSE   
    ##  5 May        May        TRUE          2008 TRUE    TRUE     FALSE   
    ##  6 June       June       TRUE          2008 TRUE    TRUE     FALSE   
    ##  7 July       July       TRUE          2008 TRUE    TRUE     FALSE   
    ##  8 August     August     TRUE          2008 TRUE    TRUE     FALSE   
    ##  9 September  September  TRUE          2008 TRUE    TRUE     FALSE   
    ## 10 October    October    TRUE          2008 TRUE    TRUE     FALSE   
    ## 11 November   November   TRUE          2008 TRUE    TRUE     FALSE   
    ## 12 December   December   TRUE          2008 TRUE    TRUE     FALSE   
    ## # … with 1 more variable: valVars <lgl>

Every month contains the incorrect number of variables. We’ll address
each of these:

``` r
# January - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "January")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "January", config = 18)

# February - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "February")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "February", config = 18)

# March - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "March")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "March", config = 18)

# April - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "April")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "April", config = 18)

# May - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "May")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "May", config = 18)

# June - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "June")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "June", config = 18)

# July - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "July")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "July", config = 18)

# August - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "August")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "August", config = 18)

# September - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "September")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "September", config = 18)

# October - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "October")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "October", config = 18)

# November - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "November")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "November", config = 18)

# December - extract data, unit test, and standardize
expect_equal(ncol(cs_extract_month(data2008_raw, month = "December")), 18)
data2008_raw <- cs_standardize(data2008_raw, month = "December", config = 18)

# validate data
cs_validate_year(data2008_raw, year = "2008")
```

    ## [1] TRUE

We now get a `TRUE` value for `cs_validate_year()` and can move on to
collapsing our raw data objects to create a new object, `data2008`, that
contains all known 2008 crimes including those that were reported or
upgraded in subsequent years:

``` r
# collapse into single object
data2008_raw <- cs_collapse(data2008_raw)

# combine and filter
cs_combine(type = "year", date = 2008, data2018_raw, data2017_raw, data2016_raw, data2015_raw, data2014_raw, data2013_raw, data2012_raw, data2011_raw, data2010_raw, data2009_raw, data2008_raw) %>%
  cs_filter_count(var = Count) -> data2008
```

## Clean-up Enviornment

We can remove the `_raw` objects at this
point:

``` r
rm(data2008_raw, data2009_raw, data2010_raw, data2011_raw, data2012_raw, data2013_raw, data2014_raw, data2015_raw, data2016_raw, data2017_raw, data2018_raw)
```

## Create Single Table

Next, we’ll create a single table before we remove individual years. We
also subset columns to reduce the footprint of the
table.

``` r
bind_rows(data2008, data2009, data2010, data2011, data2012, data2013, data2014, data2015, data2016, data2017, data2018) %>%
  select(cs_year, DateOccur, Crime, Description, ILEADSAddress, ILEADSStreet, XCoord, YCoord) -> allCrimes
```

### Clean-up Enviornment

We’ll remove excess objects
again:

``` r
rm(data2008, data2009, data2010, data2011, data2012, data2013, data2014, data2015, data2016, data2017, data2018)
```

## Categorize Crimes and Subset

Now that we have a slimmed down data set, we’ll add crime categories:

``` r
allCrimes %>%  
  cs_crime_cat(var = Crime, newVar = category, output = "numeric") %>%
  select(cs_year, DateOccur, Crime, category, everything()) -> allCrimes
```

### Create Arson Data

First, we’ll subset out arson incidents and write these to a `.csv`:

``` r
allCrimes %>%
  filter(category == 8) %>%
  filter(Crime %in% c(81100, 82100, 83100) == FALSE) %>%
  write_csv(here("data", "clean", "arson.csv"))
```

### Violent Crimes

Next, we’ll create a subset that is only violent crimes:

``` r
allCrimes %>%
  filter(category <= 4) %>%
  write_csv(here("data", "clean", "violent.csv"))
```

### Property Crimes

Next, we’ll create a subset that is only non-arson property crimes:

``` r
allCrimes %>%
  filter(category > 4 & category < 8) %>%
  write_csv(here("data", "clean", "property.csv"))
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
  filter(category %in% c(14, 15, 18, 24)) %>%
  write_csv(here("data", "clean", "otherCrimes.csv"))
```
