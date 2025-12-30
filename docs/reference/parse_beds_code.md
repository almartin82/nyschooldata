# Parse BEDS code into components

BEDS codes are 12 digits: DDDDDDSSSSCC

- DDDDDD: District code (6 digits)

- SSSS: School code (4 digits)

- CC: Check digits (2 digits)

## Usage

``` r
parse_beds_code(beds_code)
```

## Arguments

- beds_code:

  Character vector of BEDS codes

## Value

Data frame with parsed components

## Examples

``` r
parse_beds_code("010100010018")
#>      beds_code district_code school_code check_digits
#> 1 010100010018        010100        0100           18
# Returns: district_code = "010100", school_code = "0001", check_digits = "18"
```
