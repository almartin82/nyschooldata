# Validate BEDS code format

Checks if a BEDS code has the expected 12-digit format.

## Usage

``` r
validate_beds_code(beds_code)
```

## Arguments

- beds_code:

  Character vector of BEDS codes

## Value

Logical vector indicating valid codes

## Examples

``` r
validate_beds_code(c("010100010018", "31000001023", "invalid"))
#> [1]  TRUE FALSE FALSE
```
