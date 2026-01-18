# Process raw graduation data into standard schema

Transforms raw NYSED graduation data into the standardized schema used
by the package. Converts text percentages to numeric, handles suppressed
values, and standardizes column names.

## Usage

``` r
process_graduation(raw_data, end_year, membership_code = 9)
```

## Arguments

- raw_data:

  Data frame from get_raw_graduation()

- end_year:

  School year end

- membership_code:

  Optional membership code to filter (default: 9 for 4-year June)

## Value

Processed data frame with standardized columns
