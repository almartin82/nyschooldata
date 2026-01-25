# Fetch assessment data for multiple years

Downloads and combines assessment data for multiple school years. Note:
2020 is automatically excluded (COVID-19 testing waiver).

## Usage

``` r
fetch_assessment_multi(
  end_years,
  subject = "all",
  tidy = TRUE,
  use_cache = TRUE
)
```

## Arguments

- end_years:

  Vector of school year ends (e.g., c(2022, 2023, 2024))

- subject:

  Subject to fetch: "ela", "math", "science", or "all" (default)

- tidy:

  If TRUE (default), returns data in long (tidy) format.

- use_cache:

  If TRUE (default), uses locally cached data when available.

## Value

Combined data frame with assessment data for all requested years

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 3 years of data
assess_multi <- fetch_assessment_multi(2022:2024)

# Track ELA proficiency trends at state level
assess_multi |>
  dplyr::filter(is_state, subject == "ELA", grade == "3-8",
                subgroup_name == "All Students", is_proficient) |>
  dplyr::group_by(end_year) |>
  dplyr::summarize(pct_proficient = sum(pct, na.rm = TRUE))
} # }
```
