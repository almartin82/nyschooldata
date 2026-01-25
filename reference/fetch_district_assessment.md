# Get assessment data for a specific district

Convenience function to fetch and filter assessment data for a single
district.

## Usage

``` r
fetch_district_assessment(
  end_year,
  district_cd,
  subject = "all",
  tidy = TRUE,
  use_cache = TRUE
)
```

## Arguments

- end_year:

  School year end

- district_cd:

  12-digit district code (e.g., "010100010000" for Albany City)

- subject:

  Subject filter: "ela", "math", "science", or "all"

- tidy:

  If TRUE (default), returns tidy format

- use_cache:

  If TRUE (default), uses cached data

## Value

Data frame filtered to specified district

## Examples

``` r
if (FALSE) { # \dontrun{
# Get Albany City School District assessment data
albany_assess <- fetch_district_assessment(2024, "010100010000")

# Get NYC district assessment data for ELA only
nyc_ela <- fetch_district_assessment(2024, "310200010000", subject = "ela")
} # }
```
