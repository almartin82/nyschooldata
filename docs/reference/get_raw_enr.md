# Download raw enrollment data from NYSED

Downloads raw enrollment data files from the NYSED IRS archive. These
files contain grade-level enrollment by school or district for all
students.

## Usage

``` r
get_raw_enr(end_year, level = "school")
```

## Arguments

- end_year:

  School year end (2023-24 = 2024). Valid years: 1977-2025.

- level:

  Data level: "school" (default) or "district"

## Value

Raw data frame from NYSED
