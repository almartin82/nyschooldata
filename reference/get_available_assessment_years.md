# Get available assessment years for New York

Returns the years for which assessment data is available from NYSED.

## Usage

``` r
get_available_assessment_years()
```

## Value

A list with:

- years:

  Integer vector of available years

- covid_year:

  Integer year with no testing (2020)

- note:

  Character string with information about data availability

## Details

Assessment data is available from 2014-present, with the following
notes:

- 2020: No data due to COVID-19 testing waiver

- 2014-2017: NY State Tests (ELA, Math grades 3-8; Science grade 8)

- 2018-present: Same assessments with ESSA accountability framework

## Examples

``` r
get_available_assessment_years()
#> $years
#>  [1] 2014 2015 2016 2017 2018 2019 2021 2022 2023 2024 2025
#> 
#> $covid_year
#> [1] 2020
#> 
#> $note
#> [1] "New York State assessment data is available from 2013-14 through 2024-25. 2019-20 (end_year 2020) has no data due to COVID-19 testing waiver. Assessments include: NY State Tests (ELA/Math grades 3-8, Science grade 8), Regents Exams (high school), NYSESLAT (English proficiency), and NYSAA (alternate)."
#> 
```
