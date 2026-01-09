# Fetch New York enrollment data

Downloads and processes enrollment data from the New York State
Education Department (NYSED) IRS Public School Enrollment archive.

## Usage

``` r
fetch_enr(end_year, level = "school", tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  A school year. Year is the end of the academic year - eg 2023-24
  school year is year '2024'. Valid values are 2012-2024.

- level:

  Data level: "school" (default) or "district"

- tidy:

  If TRUE (default), returns data in long (tidy) format with grade_level
  column. If FALSE, returns wide format.

- use_cache:

  If TRUE (default), uses locally cached data when available. Set to
  FALSE to force re-download from NYSED.

## Value

Data frame with enrollment data

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 2024 enrollment data (2023-24 school year)
enr_2024 <- fetch_enr(2024)

# Get wide format
enr_wide <- fetch_enr(2024, tidy = FALSE)

# Get district-level data
enr_district <- fetch_enr(2024, level = "district")

# Force fresh download (ignore cache)
enr_fresh <- fetch_enr(2024, use_cache = FALSE)
} # }
```
