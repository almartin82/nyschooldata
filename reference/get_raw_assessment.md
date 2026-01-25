# Download raw assessment data from NYSED

Downloads and extracts assessment data from the NYSED Report Card
Database. Requires mdbtools to be installed on the system.

## Usage

``` r
get_raw_assessment(end_year, subject = "all")
```

## Arguments

- end_year:

  School year end (2023-24 = 2024). Valid years: 2014-2025.

- subject:

  Assessment subject: "ela", "math", "science", or "all" (default)

## Value

Data frame with raw assessment data
