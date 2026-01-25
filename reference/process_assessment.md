# Process raw NYSED assessment data

Cleans and standardizes raw assessment data from the NYSED Report Card
Database. Adds entity type identification, converts numeric columns, and
standardizes column names.

## Usage

``` r
process_assessment(raw_data, end_year)
```

## Arguments

- raw_data:

  Data frame from get_raw_assessment()

- end_year:

  School year end (for metadata)

## Value

Processed data frame with standardized columns
