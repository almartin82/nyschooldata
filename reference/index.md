# Package index

## Fetch Data

Download enrollment data from NYSED

- [`fetch_enr()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr.md)
  : Fetch New York enrollment data
- [`fetch_enr_years()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_years.md)
  : Fetch enrollment data for multiple years
- [`fetch_enr_school()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_school.md)
  : Get enrollment for a specific school by BEDS code
- [`fetch_enr_district()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_district.md)
  : Get enrollment for a specific district
- [`fetch_enr_nyc()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_nyc.md)
  : Get NYC enrollment data

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
