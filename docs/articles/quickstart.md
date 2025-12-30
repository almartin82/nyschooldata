# Getting Started with nyschooldata

## Installation

Install from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("almartin82/nyschooldata")
```

## Quick Example

Fetch the most recent year of New York enrollment data:

``` r
library(nyschooldata)
library(dplyr)

# Fetch 2024 enrollment data (2023-24 school year)
enr <- fetch_enr(2024)

head(enr)
```

    ##   end_year county district_beds district_code district_name    beds_code
    ## 1     2024 ALBANY  010100010000        010100        ALBANY 010100010014
    ## 2     2024 ALBANY  010100010000        010100        ALBANY 010100010016
    ## 3     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 4     2024 ALBANY  010100010000        010100        ALBANY 010100010019
    ## 5     2024 ALBANY  010100010000        010100        ALBANY 010100010023
    ## 6     2024 ALBANY  010100010000        010100        ALBANY 010100010027
    ##   school_code                    school_name school_type is_state is_district
    ## 1        0100       MONTESSORI MAGNET SCHOOL      Public    FALSE       FALSE
    ## 2        0100   PINE HILLS ELEMENTARY SCHOOL      Public    FALSE       FALSE
    ## 3        0100      DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 4        0100 NEW SCOTLAND ELEMENTARY SCHOOL      Public    FALSE       FALSE
    ## 5        0100    ALBANY SCHOOL OF HUMANITIES      Public    FALSE       FALSE
    ## 6        0100  EAGLE POINT ELEMENTARY SCHOOL      Public    FALSE       FALSE
    ##   is_school is_nyc is_charter grade_level         subgroup n_students pct
    ## 1      TRUE  FALSE      FALSE       TOTAL total_enrollment        324   1
    ## 2      TRUE  FALSE      FALSE       TOTAL total_enrollment        347   1
    ## 3      TRUE  FALSE      FALSE       TOTAL total_enrollment        311   1
    ## 4      TRUE  FALSE      FALSE       TOTAL total_enrollment        459   1
    ## 5      TRUE  FALSE      FALSE       TOTAL total_enrollment        332   1
    ## 6      TRUE  FALSE      FALSE       TOTAL total_enrollment        286   1

## Understanding the Data

The data is returned in **tidy (long) format** by default:

- Each row is one grade level for one school/district
- `grade_level` shows the grade (“TOTAL”, “PK”, “K”, “01”, “02”, etc.)
- `n_students` is the enrollment count
- `pct` is the percentage of total enrollment
- `beds_code` is the 12-digit BEDS (Basic Educational Data System)
  identifier

``` r
enr %>%
  filter(is_district) %>%
  select(end_year, district_name, grade_level, n_students) %>%
  head(10)
```

    ## [1] end_year      district_name grade_level   n_students   
    ## <0 rows> (or 0-length row.names)

## Filtering by Level

Use the aggregation flags to filter data:

``` r
# All districts
districts <- enr %>% filter(is_district, grade_level == "TOTAL")
nrow(districts)
```

    ## [1] 0

``` r
# All schools
schools <- enr %>% filter(is_school, grade_level == "TOTAL")
nrow(schools)
```

    ## [1] 4749

``` r
# NYC schools only
nyc_schools <- enr %>% filter(is_school, is_nyc, grade_level == "TOTAL")
nrow(nyc_schools)
```

    ## [1] 1864

## Simple Analysis: Top 10 Districts

``` r
enr %>%
  filter(is_district, grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  select(district_name, county, n_students) %>%
  head(10)
```

    ## [1] district_name county        n_students   
    ## <0 rows> (or 0-length row.names)

## NYC Data

NYC is a special case in New York State - it’s a single district (NYC
DOE) with nearly 1,800 schools. Use the
[`fetch_enr_nyc()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_nyc.md)
convenience function:

``` r
nyc <- fetch_enr_nyc(2024)

nyc %>%
  filter(is_school, grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  select(school_name, n_students) %>%
  head(10)
```

    ##                    school_name n_students
    ## 1        BROOKLYN TECHNICAL HS       5810
    ## 2    FRANCIS LEWIS HIGH SCHOOL       4404
    ## 3    FORT HAMILTON HIGH SCHOOL       3980
    ## 4          MIDWOOD HIGH SCHOOL       3905
    ## 5      TOTTENVILLE HIGH SCHOOL       3796
    ## 6    JAMES MADISON HIGH SCHOOL       3766
    ## 7  EDWARD R MURROW HIGH SCHOOL       3589
    ## 8     FOREST HILLS HIGH SCHOOL       3420
    ## 9      FRANKLIN D ROOSEVELT HS       3409
    ## 10      STUYVESANT HIGH SCHOOL       3258

## Wide Format

If you prefer wide format (one column per grade), set `tidy = FALSE`:

``` r
enr_wide <- fetch_enr(2024, tidy = FALSE)

enr_wide %>%
  filter(is_district) %>%
  select(district_name, row_total, grade_k, grade_01, grade_09, grade_12) %>%
  head(5)
```

    ## [1] district_name row_total     grade_k       grade_01      grade_09     
    ## [6] grade_12     
    ## <0 rows> (or 0-length row.names)

## Historical Data

Fetch multiple years to analyze trends:

``` r
# Fetch 5 years of data
enr_multi <- fetch_enr_years(2020:2024)

# District enrollment trend
enr_multi %>%
  filter(is_district, grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(total_enrollment = sum(n_students, na.rm = TRUE))
```

## Grade Level Aggregates

Create custom grade span aggregates with
[`enr_grade_aggs()`](https://almartin82.github.io/nyschooldata/reference/enr_grade_aggs.md):

``` r
# Get K-8, HS (9-12), and K-12 aggregates
aggs <- enr_grade_aggs(enr)

aggs %>%
  filter(is_district) %>%
  select(district_name, grade_level, n_students) %>%
  head(15)
```

## BEDS Codes

New York uses 12-digit BEDS (Basic Educational Data System) codes to
identify schools. Use the utility functions to work with these codes:

``` r
# Validate a BEDS code
validate_beds_code("010100010018")
```

    ## [1] TRUE

``` r
# Parse a BEDS code into components
parse_beds_code("010100010018")
```

    ##      beds_code district_code school_code check_digits
    ## 1 010100010018        010100        0100           18

## Caching

Data is cached locally by default to avoid repeated downloads. Use these
functions to manage the cache:

``` r
# View cache status
cache_status()

# Clear all cached data
clear_enr_cache()

# Clear only 2024 data
clear_enr_cache(2024)
```

## Next Steps

- Use
  [`?fetch_enr`](https://almartin82.github.io/nyschooldata/reference/fetch_enr.md)
  for full function documentation
- Explore
  [`fetch_enr_school()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_school.md)
  and
  [`fetch_enr_district()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_district.md)
  for targeted queries
- See
  [`get_available_years()`](https://almartin82.github.io/nyschooldata/reference/get_available_years.md)
  for the range of available data years
