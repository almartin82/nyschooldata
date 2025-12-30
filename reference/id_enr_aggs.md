# Identify enrollment aggregation levels

Adds boolean flags to identify state, district, and school level
records. This is typically called automatically by fetch_enr, but can be
used to re-identify aggregation levels after filtering.

## Usage

``` r
id_enr_aggs(df)
```

## Arguments

- df:

  Enrollment dataframe

## Value

data.frame with boolean aggregation flags
