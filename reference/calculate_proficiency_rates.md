# Calculate proficiency rates from tidy assessment data

Summarizes tidy assessment data to calculate overall proficiency rates
(percentage at Level 3 or above).

## Usage

``` r
calculate_proficiency_rates(df)
```

## Arguments

- df:

  Tidy data frame from tidy_assessment()

## Value

Data frame with proficiency rates

## Examples

``` r
if (FALSE) { # \dontrun{
# Get tidy assessment data
assess <- fetch_assessment(2024, tidy = TRUE)

# Calculate proficiency rates
prof_rates <- calculate_proficiency_rates(assess)
} # }
```
