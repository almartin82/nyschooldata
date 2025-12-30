# Parse School Year Label

Converts a school year label string to an end year integer.

## Usage

``` r
parse_school_year(label)
```

## Arguments

- label:

  Character school year label (e.g., "2023-24")

## Value

Integer end year (e.g., 2024)

## Examples

``` r
parse_school_year("2023-24")  # Returns 2024
#> [1] 2024
parse_school_year("2020-21")  # Returns 2021
#> [1] 2021
```
