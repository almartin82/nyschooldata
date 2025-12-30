# Download demographics enrollment data from NYSED

Downloads enrollment broken down by demographic subgroups
(race/ethnicity, economically disadvantaged, ELL, SWD).

## Usage

``` r
get_raw_enr_demographics(end_year, level = "school", category = "race")
```

## Arguments

- end_year:

  School year end

- level:

  Data level: "school" or "district"

- category:

  Demographic category: "race", "economic", "ell", "swd"

## Value

Raw data frame with demographic breakdowns
