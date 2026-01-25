# Safely convert to numeric, handling suppression markers

NYSED uses "s" and other markers for suppressed data.

## Usage

``` r
safe_numeric_assessment(x)
```

## Arguments

- x:

  Vector to convert

## Value

Numeric vector with NA for non-numeric values
