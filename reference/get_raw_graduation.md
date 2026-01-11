# Download raw graduation data from NYSED

Downloads graduation rate data ZIP file from NYSED, extracts the .mdb
file, converts it to CSV using mdbtools, and caches the result.

## Usage

``` r
get_raw_graduation(end_year, force_refresh = FALSE)
```

## Arguments

- end_year:

  School year end (2023-24 = 2024). Valid years: 2014-2024.

- force_refresh:

  If TRUE, bypass cache and re-download/convert

## Value

Data frame with graduation data
