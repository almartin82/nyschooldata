# Tidy assessment data to long format

Converts wide-format assessment data (with level1_count, level2_count,
etc.) into long format with proficiency_level and count/pct columns.

## Usage

``` r
tidy_assessment(df)
```

## Arguments

- df:

  Processed data frame from process_assessment()

## Value

Tidy data frame with proficiency_level, n_students, and pct columns

## Details

NY State Tests use 4 proficiency levels:

- Level 1: Did Not Meet Standards

- Level 2: Partially Met Standards

- Level 3: Met Standards

- Level 4: Exceeded Standards
