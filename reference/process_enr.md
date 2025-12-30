# Process raw NYSED enrollment data

Transforms raw data from get_raw_enr into a standardized format with
consistent column names and proper data types.

## Usage

``` r
process_enr(df, end_year)
```

## Arguments

- df:

  Raw data frame from get_raw_enr

- end_year:

  School year end

## Value

Processed data frame with standardized columns
