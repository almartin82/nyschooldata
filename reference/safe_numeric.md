# Convert to numeric, handling suppression markers

NYSED uses various markers for suppressed data (\*, s, etc.) and uses
commas in large numbers.

## Usage

``` r
safe_numeric(x)
```

## Arguments

- x:

  Vector to convert

## Value

Numeric vector with NA for non-numeric values
