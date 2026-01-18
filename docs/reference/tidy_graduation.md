# Tidy graduation data

Transforms processed graduation data to ensure consistent long format.
The processed data is already in long format, so this function primarily
validates and ensures schema consistency.

## Usage

``` r
tidy_graduation(df)
```

## Arguments

- df:

  A processed graduation data frame from process_graduation()

## Value

A long data frame of tidied graduation data
