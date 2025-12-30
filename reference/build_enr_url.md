# Build NYSED IRS enrollment file URL

Constructs the download URL based on year and naming conventions. URL
patterns changed in 2022.

## Usage

``` r
build_enr_url(end_year, level = "school", category = "all-students")
```

## Arguments

- end_year:

  School year end

- level:

  Data level

- category:

  Data category (e.g., "all-students", "race-and-ethnic-origin")

## Value

Full download URL
