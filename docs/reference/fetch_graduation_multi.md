# Fetch graduation rate data for multiple years

Downloads and combines graduation rate data for multiple school years.

## Usage

``` r
fetch_graduation_multi(
  end_years,
  tidy = TRUE,
  use_cache = TRUE,
  membership_code = 9
)
```

## Arguments

- end_years:

  Vector of school year ends (e.g., c(2020, 2021, 2022))

- tidy:

  If TRUE (default), returns data in long (tidy) format.

- use_cache:

  If TRUE (default), uses locally cached data when available.

- membership_code:

  Optional membership code for cohort type. Default is 9 (4-year June
  outcome).

## Value

Combined data frame with graduation rate data for all requested years

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 5 years of data
grad_multi <- fetch_graduation_multi(2020:2024)

# Track graduation rate trends
grad_multi |>
  dplyr::filter(is_state, subgroup == "all") |>
  dplyr::select(end_year, grad_rate, cohort_count)

# Compare NYC vs rest of state over time
grad_multi |>
  dplyr::filter(subgroup == "all", type %in% c("State", "NRC")) |>
  dplyr::select(end_year, type, grad_rate)
} # }
```
