# Fetch New York graduation rate data

Downloads and processes graduation rate data from the New York State
Education Department (NYSED) Data Site.

## Usage

``` r
fetch_graduation(end_year, tidy = TRUE, use_cache = TRUE, membership_code = 9)
```

## Arguments

- end_year:

  A school year. Year is the end of the academic year - eg 2023-24
  school year is year '2024'. Valid values are 2014-2024.

- tidy:

  If TRUE (default), returns data in long (tidy) format with subgroup
  column. If FALSE, returns wide format.

- use_cache:

  If TRUE (default), uses locally cached data when available. Set to
  FALSE to force re-download and re-conversion from NYSED.

- membership_code:

  Optional membership code for cohort type. Default is 9 (4-year June
  outcome). Other options: 6 (6-year June), 8 (5-year June), 10 (5-year
  August), 11 (4-year August).

## Value

Data frame with graduation rate data. Includes columns for end_year,
type, district_id, district_name, school_id, school_name, subgroup,
metric, grad_rate, cohort_count, graduate_count, is_state, is_district,
is_school.

## Details

Note: This function requires mdbtools to be installed on your system.
See https://github.com/mdbtools/mdbtools for installation instructions.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 2024 graduation data (2023-24 school year)
grad_2024 <- fetch_graduation(2024)

# Get historical data from 2018
grad_2018 <- fetch_graduation(2018)

# Get wide format
grad_wide <- fetch_graduation(2024, tidy = FALSE)

# Force fresh download (ignore /data-cache)
grad_fresh <- fetch_graduation(2024, use_cache = FALSE)

# Get 5-year cohort rate instead of 4-year
grad_5year <- fetch_graduation(2024, membership_code = 8)

# Compare district rates
grad_2024 |>
  dplyr::filter(is_district, subgroup == "all") |>
  dplyr::select(district_name, grad_rate, cohort_count) |>
  dplyr::arrange(dplyr::desc(grad_rate))
} # }
```
