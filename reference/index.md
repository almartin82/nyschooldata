# Package index

## Fetch Data

Download enrollment and graduation data from NYSED

- [`fetch_enr()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr.md)
  : Fetch New York enrollment data
- [`fetch_enr_multi()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_multi.md)
  : Fetch enrollment data for multiple years
- [`fetch_enr_years()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_years.md)
  : Fetch enrollment data for multiple years (legacy)
- [`fetch_enr_school()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_school.md)
  : Get enrollment for a specific school by BEDS code
- [`fetch_enr_district()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_district.md)
  : Get enrollment for a specific district
- [`fetch_enr_nyc()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_nyc.md)
  : Get NYC enrollment data
- [`fetch_directory()`](https://almartin82.github.io/nyschooldata/reference/fetch_directory.md)
  : Fetch New York school directory data
- [`get_directory_years()`](https://almartin82.github.io/nyschooldata/reference/get_directory_years.md)
  : Get available years for directory data
- [`fetch_graduation()`](https://almartin82.github.io/nyschooldata/reference/fetch_graduation.md)
  : Fetch New York graduation rate data
- [`fetch_graduation_multi()`](https://almartin82.github.io/nyschooldata/reference/fetch_graduation_multi.md)
  : Fetch graduation rate data for multiple years
- [`get_available_grad_years()`](https://almartin82.github.io/nyschooldata/reference/get_available_grad_years.md)
  : Get available graduation years

## Process & Tidy

Transform data into analysis-ready formats

- [`tidy_enr()`](https://almartin82.github.io/nyschooldata/reference/tidy_enr.md)
  : Tidy enrollment data
- [`id_enr_aggs()`](https://almartin82.github.io/nyschooldata/reference/id_enr_aggs.md)
  : Identify enrollment aggregation levels
- [`enr_grade_aggs()`](https://almartin82.github.io/nyschooldata/reference/enr_grade_aggs.md)
  : Custom Enrollment Grade Level Aggregates
- [`filter_grade_span()`](https://almartin82.github.io/nyschooldata/reference/filter_grade_span.md)
  : Filter enrollment data by grade span

## Cache Management

Manage locally cached data

- [`cache_status()`](https://almartin82.github.io/nyschooldata/reference/cache_status.md)
  : Show cache status
- [`clear_enr_cache()`](https://almartin82.github.io/nyschooldata/reference/clear_enr_cache.md)
  : Clear the nyschooldata cache
- [`clear_grad_cache()`](https://almartin82.github.io/nyschooldata/reference/clear_grad_cache.md)
  : Clear graduation rate cache

## Utilities

Helper functions for working with NY school data

- [`school_year_label()`](https://almartin82.github.io/nyschooldata/reference/school_year_label.md)
  : School Year Label
- [`parse_school_year()`](https://almartin82.github.io/nyschooldata/reference/parse_school_year.md)
  : Parse School Year Label
- [`get_available_years()`](https://almartin82.github.io/nyschooldata/reference/get_available_years.md)
  : Get Available Years
- [`validate_beds_code()`](https://almartin82.github.io/nyschooldata/reference/validate_beds_code.md)
  : Validate BEDS code format
- [`parse_beds_code()`](https://almartin82.github.io/nyschooldata/reference/parse_beds_code.md)
  : Parse BEDS code into components
- [`clean_column_names()`](https://almartin82.github.io/nyschooldata/reference/clean_column_names.md)
  : Clean column names
- [`extract_column()`](https://almartin82.github.io/nyschooldata/reference/extract_column.md)
  : Extract column from data frame with multiple possible names
- [`extract_district_id()`](https://almartin82.github.io/nyschooldata/reference/extract_district_id.md)
  : Extract district ID from school data
- [`extract_district_name()`](https://almartin82.github.io/nyschooldata/reference/extract_district_name.md)
  : Extract district name from data
- [`filter_schools_only()`](https://almartin82.github.io/nyschooldata/reference/filter_schools_only.md)
  : Filter to keep only schools (remove district-only rows)
- [`format_beds_code()`](https://almartin82.github.io/nyschooldata/reference/format_beds_code.md)
  : Format BEDS code with leading zeros
