# Filter enrollment data by grade span

Convenience function to filter to common grade spans.

## Usage

``` r
filter_grade_span(df, span = "k12")
```

## Arguments

- df:

  Tidy enrollment data frame

- span:

  Grade span: "pk12", "k12", "k8", "hs", "elem" (K-5), "middle" (6-8)

## Value

Filtered data frame
