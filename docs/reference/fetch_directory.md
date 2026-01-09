# Fetch New York school directory data

Downloads and returns school directory data from NYSED's SEDREF system.
This includes contact information for all NY public schools, districts,
charter schools, and nonpublic schools (including NYC).

## Usage

``` r
fetch_directory(end_year = NULL, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  School year end (2023-24 = 2024). Only current year data is available
  from SEDREF COGNOS reports. Defaults to current year.

- tidy:

  If TRUE (default), returns data in standardized format with consistent
  column names.

- use_cache:

  If TRUE (default), uses locally cached data when available.

## Value

A tibble with school directory information including:

- `end_year`: School year end (e.g., 2024 for 2023-24)

- `state_school_id`: BEDS code for school

- `state_district_id`: BEDS code for district

- `school_name`: School name

- `district_name`: District name

- `school_type`: School type (Elementary, Middle, High, etc.)

- `grades_served`: Grade levels served

- `address`: Street address

- `city`: City

- `state`: State (NY)

- `zip`: ZIP code

- `phone`: Phone number

- `principal_name`: Principal/CEO name

- `principal_email`: Principal/CEO email (if available)

- `superintendent_name`: Superintendent name (for districts)

- `superintendent_email`: Superintendent email (if available)

## Examples

``` r
if (FALSE) { # \dontrun{
# Get most recent directory data
dir_2024 <- fetch_directory(2024)

# Force fresh download (bypass cache)
dir_fresh <- fetch_directory(2024, use_cache = FALSE)
} # }
```
