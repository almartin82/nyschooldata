# Get NYC enrollment data

Convenience function to get enrollment data for NYC DOE schools only.

## Usage

``` r
fetch_enr_nyc(end_year, level = "school", tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  School year end (or vector of years)

- level:

  Data level: "school" or "district"

- tidy:

  If TRUE, returns tidy format

- use_cache:

  If TRUE, uses cache

## Value

Data frame with NYC enrollment data

## Examples

``` r
if (FALSE) { # \dontrun{
# Get NYC school enrollment
nyc_enr <- fetch_enr_nyc(2024)
} # }
```
