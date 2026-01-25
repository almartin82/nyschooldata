# Get assessment data for a specific school

Convenience function to fetch and filter assessment data for a single
school.

## Usage

``` r
fetch_school_assessment(
  end_year,
  school_cd,
  subject = "all",
  tidy = TRUE,
  use_cache = TRUE
)
```

## Arguments

- end_year:

  School year end

- school_cd:

  12-digit school code

- subject:

  Subject filter: "ela", "math", "science", or "all"

- tidy:

  If TRUE (default), returns tidy format

- use_cache:

  If TRUE (default), uses cached data

## Value

Data frame filtered to specified school

## Examples

``` r
if (FALSE) { # \dontrun{
# Get a specific school's assessment data
school_assess <- fetch_school_assessment(2024, "010100010001")
} # }
```
