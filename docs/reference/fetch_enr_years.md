# Fetch enrollment data for multiple years

Convenience function to download enrollment data for multiple years and
combine into a single data frame.

## Usage

``` r
fetch_enr_years(years, level = "school", tidy = TRUE, use_cache = TRUE)
```

## Arguments

- years:

  Vector of end years (e.g., 2020:2024)

- level:

  Data level: "school" or "district"

- tidy:

  If TRUE, returns tidy format

- use_cache:

  If TRUE, uses cache

## Value

Combined data frame with enrollment data for all years

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 5 years of data
enr_multi <- fetch_enr_years(2020:2024)

# Get district-level data for multiple years
dist_multi <- fetch_enr_years(2020:2024, level = "district")
} # }
```
