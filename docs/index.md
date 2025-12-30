# nyschooldata

An R package for fetching and processing New York State school
enrollment data from the [NYSED IRS (Information Reporting
Services)](https://data.nysed.gov/) Public School Enrollment database.

## Overview

`nyschooldata` provides a simple interface to download, cache, and
analyze enrollment data for all public schools and districts in New York
State. The package handles:

- Downloading data directly from NYSED’s public data portal
- Converting between wide and tidy (long) data formats
- Local caching to avoid repeated downloads
- Identifying NYC schools, charter schools, and district/school
  aggregation levels
- Working with BEDS (Basic Educational Data System) codes

## Installation

Install from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("almartin82/nyschooldata")
```

## Quick Start

``` r
library(nyschooldata)
library(dplyr)

# Fetch the most recent year of enrollment data (2023-24 school year)
enr <- fetch_enr(2024)

# View the data structure
head(enr)
#>   end_year county district_beds district_code district_name   beds_code
#> 1     2024 Albany        010100        010100 Albany City SD 010100010001
#> ...

# Filter to district totals
enr %>%
  filter(is_district, grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(10)
```

### Converting to Tidy Format

By default,
[`fetch_enr()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr.md)
returns data in tidy (long) format with one row per school/grade
combination. For wide format (one column per grade), set `tidy = FALSE`:

``` r
# Wide format: one column per grade level
enr_wide <- fetch_enr(2024, tidy = FALSE)

enr_wide %>%
  select(school_name, row_total, grade_k, grade_01, grade_09, grade_12)
```

### Multi-Year Analysis

Fetch multiple years of data at once:

``` r
# Fetch 5 years of data
enr_multi <- fetch_enr_years(2020:2024)

# Calculate statewide enrollment trend
enr_multi %>%
  filter(is_district, grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(total_enrollment = sum(n_students, na.rm = TRUE))
```

### NYC Data

NYC DOE is the largest school district in the country, with
approximately 1,800 schools across 32 geographic districts. The package
automatically identifies NYC schools with the `is_nyc` flag:

``` r
# Get NYC enrollment data directly
nyc_enr <- fetch_enr_nyc(2024)

# Or filter from statewide data
enr %>%
  filter(is_nyc, is_school, grade_level == "TOTAL") %>%
  nrow()
#> [1] ~1800 NYC schools
```

### Working with BEDS Codes

New York uses 12-digit BEDS codes to identify schools and districts:

``` r
# Validate a BEDS code
validate_beds_code("010100010018")
#> [1] TRUE

# Parse into components
parse_beds_code("010100010018")
#>      beds_code district_code school_code check_digits
#> 1 010100010018        010100        0001           18
```

## Available Years

Data is available for school years 2011-12 through 2024-25:

| Parameter | School Year |
|-----------|-------------|
| 2012      | 2011-12     |
| 2013      | 2012-13     |
| …         | …           |
| 2024      | 2023-24     |
| 2025      | 2024-25     |

``` r
get_available_years()
#> $min_year
#> [1] 2012
#>
#> $max_year
#> [1] 2025
```

## Data Schema

### Tidy Format Columns

| Column          | Description                              |
|-----------------|------------------------------------------|
| `end_year`      | School year end (e.g., 2024 for 2023-24) |
| `county`        | County name                              |
| `district_beds` | 12-digit district BEDS code              |
| `district_code` | 6-digit district code                    |
| `district_name` | District name                            |
| `beds_code`     | 12-digit school BEDS code                |
| `school_code`   | 4-digit school code                      |
| `school_name`   | School name                              |
| `grade_level`   | Grade level (TOTAL, PK, K, 01-12, etc.)  |
| `n_students`    | Enrollment count                         |
| `pct`           | Percentage of school total               |
| `is_state`      | State-level aggregate flag               |
| `is_district`   | District-level aggregate flag            |
| `is_school`     | School-level record flag                 |
| `is_nyc`        | NYC DOE school flag                      |
| `is_charter`    | Charter school flag                      |

## Data Sources

- **Primary source**: [NYSED Information Reporting
  Services](https://data.nysed.gov/)
- **Data type**: Public school enrollment by grade level
- **Update frequency**: Annual (typically available by fall for prior
  school year)

## Documentation

Full documentation is available at the [pkgdown
site](https://almartin82.github.io/nyschooldata/).

## Related Packages

This package follows patterns from: -
[ilschooldata](https://github.com/almartin82/ilschooldata) - Illinois
school data -
[njschooldata](https://github.com/almartin82/njschooldata) - New Jersey
school data

## License

MIT
