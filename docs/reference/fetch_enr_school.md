# Get enrollment for a specific school by BEDS code

Convenience function to filter enrollment data to a single school.

## Usage

``` r
fetch_enr_school(beds_code, end_year, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- beds_code:

  12-digit BEDS code for the school

- end_year:

  School year end (or vector of years)

- tidy:

  If TRUE, returns tidy format

- use_cache:

  If TRUE, uses cache

## Value

Data frame with enrollment for the specified school

## Examples

``` r
if (FALSE) { # \dontrun{
# Get enrollment for a specific school
school_enr <- fetch_enr_school("010100010018", 2024)

# Get multiple years for a school
school_history <- fetch_enr_school("010100010018", 2020:2024)
} # }
```
