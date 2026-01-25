# Fetch New York State assessment data

Downloads and returns assessment data from the New York State Education
Department (NYSED). Includes NY State Tests for ELA, Math (grades 3-8),
and Science (grade 8).

## Usage

``` r
fetch_assessment(end_year, subject = "all", tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  School year end (2023-24 = 2024). Valid range: 2014-2025 (excluding
  2020).

- subject:

  Subject to fetch: "ela", "math", "science", or "all" (default)

- tidy:

  If TRUE (default), returns data in long (tidy) format with
  proficiency_level column. If FALSE, returns wide format with separate
  level columns.

- use_cache:

  If TRUE (default), uses locally cached data when available.

## Value

Data frame with assessment data

## Details

Assessment proficiency levels:

- **Level 1**: Did Not Meet Standards

- **Level 2**: Partially Met Standards

- **Level 3**: Met Standards (proficient)

- **Level 4**: Exceeded Standards (proficient)

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 2024 assessment data for all subjects
assess_2024 <- fetch_assessment(2024)

# Get only ELA data in wide format
ela_wide <- fetch_assessment(2024, subject = "ela", tidy = FALSE)

# Get math data for multiple years
math_multi <- fetch_assessment_multi(2021:2024, subject = "math")

# Filter to state-level ELA results
state_ela <- assess_2024 |>
  dplyr::filter(is_state, subject == "ELA")
} # }
```
