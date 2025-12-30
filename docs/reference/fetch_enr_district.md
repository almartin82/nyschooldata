# Get enrollment for a specific district

Convenience function to filter enrollment data to a single district.

## Usage

``` r
fetch_enr_district(
  district_code,
  end_year,
  level = "school",
  tidy = TRUE,
  use_cache = TRUE
)
```

## Arguments

- district_code:

  6-digit district code (or 12-digit district BEDS code)

- end_year:

  School year end (or vector of years)

- level:

  Data level: "school" to get all schools in district, "district" for
  district totals only

- tidy:

  If TRUE, returns tidy format

- use_cache:

  If TRUE, uses cache

## Value

Data frame with enrollment for the specified district

## Examples

``` r
if (FALSE) { # \dontrun{
# Get all schools in a district
district_schools <- fetch_enr_district("010100", 2024)

# Get district totals only
district_total <- fetch_enr_district("010100", 2024, level = "district")
} # }
```
