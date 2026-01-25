# Extract assessment tables from Access database

Uses mdbtools to export assessment tables from the Access database.

## Usage

``` r
extract_assessment_tables(db_path, end_year, subject = "all")
```

## Arguments

- db_path:

  Path to the .mdb file

- end_year:

  School year end (for metadata)

- subject:

  Subject filter: "ela", "math", "science", or "all"

## Value

Data frame with assessment data
