# Filter to keep only schools (remove district-only rows)

SEDREF reports include both districts and schools. District rows
typically have school code ending in 000000.

## Usage

``` r
filter_schools_only(df)
```

## Arguments

- df:

  Data frame with school and district rows

## Value

Data frame with school rows only
