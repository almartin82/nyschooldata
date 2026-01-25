# Extract grade from assessment name

Parses the grade level from the assessment_name column. NY State Tests
are typically named like "ELA3", "MATH5", "ELA3_8", etc.

## Usage

``` r
extract_grade(df)
```

## Arguments

- df:

  Data frame with assessment_name column

## Value

Data frame with grade column
