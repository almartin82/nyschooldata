# nyschooldata: Fetch and Process New York School Data

Downloads and processes school data from the New York State Education
Department (NYSED). Provides functions for fetching enrollment data and
transforming it into tidy format for analysis.

## Main Functions

- [`fetch_enr`](https://almartin82.github.io/nyschooldata/reference/fetch_enr.md):

  Fetch enrollment data for a school year

- [`fetch_enr_years`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_years.md):

  Fetch enrollment data for multiple years

- [`fetch_enr_school`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_school.md):

  Fetch enrollment for a specific school by BEDS code

- [`fetch_enr_district`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_district.md):

  Fetch enrollment for a specific district

- [`fetch_enr_nyc`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_nyc.md):

  Fetch NYC DOE enrollment data

- [`tidy_enr`](https://almartin82.github.io/nyschooldata/reference/tidy_enr.md):

  Transform wide enrollment data to long format

- [`id_enr_aggs`](https://almartin82.github.io/nyschooldata/reference/id_enr_aggs.md):

  Identify aggregation levels (state/district/school)

- [`enr_grade_aggs`](https://almartin82.github.io/nyschooldata/reference/enr_grade_aggs.md):

  Create grade-level aggregates (K-8, HS, K-12)

## Data Sources

Data is downloaded from the NYSED data portal at
<https://data.nysed.gov/>.

## See also

Useful links:

- <https://almartin82.github.io/nyschooldata/>

- <https://github.com/almartin82/nyschooldata>

- Report bugs at <https://github.com/almartin82/nyschooldata/issues>

## Author

**Maintainer**: Andy Martin <almartin@gmail.com>
