# NY School Data Expansion Research

**Last Updated:** 2026-01-04 **Theme Researched:** Graduation Rates

## Data Sources Found

### Source 1: NYSED Data Site - Graduation Rate Database Downloads

- **URL (base):** `https://data.nysed.gov/files/gradrate/`
- **Main downloads page:** <https://data.nysed.gov/downloads.php>
- **HTTP Status:** 200 OK (all tested files)
- **Format:** ZIP archives containing Microsoft Access (.mdb) and
  sometimes CSV or Excel files
- **Years:** 2004-05 through 2023-24 (20 years of data)
- **Access:** Direct download, no authentication required
- **Update Frequency:** Annual (typically January after school year
  ends)

### URL Patterns by Year

| Year Range | URL Pattern                               | File Contents                               |
|------------|-------------------------------------------|---------------------------------------------|
| 2019-2024  | `/files/gradrate/YY-YY/gradrate.zip`      | .mdb only (2023-24) or .mdb + .accdb + .csv |
| 2015-2018  | `/files/gradrate/YY-YY/gradrate_YYYY.zip` | .mdb + .accdb + .xlsx                       |
| 2014       | `/files/gradrate/gradrate_2014.zip`       | .xlsx only                                  |
| 2005-2013  | `/files/gradrate/gradrate_YYYY.zip`       | .mdb + .accdb + .xlsx                       |

### Verified File URLs with HTTP Status

| Year    | URL                                                             | Status | Size     |
|---------|-----------------------------------------------------------------|--------|----------|
| 2023-24 | `https://data.nysed.gov/files/gradrate/23-24/gradrate.zip`      | 200    | 7.81 MB  |
| 2022-23 | `https://data.nysed.gov/files/gradrate/22-23/gradrate.zip`      | 200    | 12.3 MB  |
| 2021-22 | `https://data.nysed.gov/files/gradrate/21-22/gradrate.zip`      | 200    | 14.81 MB |
| 2020-21 | `https://data.nysed.gov/files/gradrate/20-21/gradrate.zip`      | 200    | 14.85 MB |
| 2019-20 | `https://data.nysed.gov/files/gradrate/19-20/gradrate.zip`      | 200    | 15.33 MB |
| 2018-19 | `https://data.nysed.gov/files/gradrate/18-19/gradrate.zip`      | 200    | 14.37 MB |
| 2017-18 | `https://data.nysed.gov/files/gradrate/17-18/gradrate_2018.zip` | 200    | 8.74 MB  |
| 2016-17 | `https://data.nysed.gov/files/gradrate/16-17/gradrate_2017.zip` | 200    | 8.38 MB  |
| 2015-16 | `https://data.nysed.gov/files/gradrate/15-16/gradrate_2016.zip` | 200    | 8.21 MB  |
| 2014-15 | `https://data.nysed.gov/files/gradrate/14-15/gradrate_2015.zip` | 200    | 8.78 MB  |
| 2013-14 | `https://data.nysed.gov/files/gradrate/gradrate_2014.zip`       | 200    | 14.72 MB |
| 2012-13 | `https://data.nysed.gov/files/gradrate/gradrate_2013.zip`       | 200    | 59.67 MB |
| 2011-12 | `https://data.nysed.gov/files/gradrate/gradrate_2012.zip`       | 200    | 13.74 MB |
| 2010-11 | `https://data.nysed.gov/files/gradrate/gradrate_2011.zip`       | 200    | 13.6 MB  |
| 2009-10 | `https://data.nysed.gov/files/gradrate/gradrate_2010.zip`       | 200    | 10.78 MB |
| 2008-09 | `https://data.nysed.gov/files/gradrate/gradrate_2009.zip`       | 200    | 44.02 MB |
| 2007-08 | `https://data.nysed.gov/files/gradrate/gradrate_2008.zip`       | 200    | 28.38 MB |
| 2006-07 | `https://data.nysed.gov/files/gradrate/gradrate_2007.zip`       | 200    | 6.28 MB  |
| 2005-06 | `https://data.nysed.gov/files/gradrate/gradrate_2006.zip`       | 200    | 12.28 MB |
| 2004-05 | `https://data.nysed.gov/files/gradrate/gradrate_2005.zip`       | 200    | 5.96 MB  |

### Source 2: NYSED Archive - Historical Graduation Data (Pre-2014)

- **URL:** <https://www.p12.nysed.gov/irs/cohort/archive-grad.html>
- **Format:** Links to press releases with data files
- **Years:** 2004-05 through 2014-15
- **Note:** Overlaps with main source but contains historical press
  releases

### Source 3: NYSED Business Rules

- **URL:** <https://data.nysed.gov/businessrules.php?type=gradrate>
- **Content:** Official definitions for cohorts, graduation rates, and
  data suppression rules

## Schema Analysis

### File Contents by Year

**2023-24 ZIP Contents:** - `2024_GRADUATION_RATE.mdb` (134 MB) -
`High School Graduation Rate Business Rules.pdf` -
`High School Graduation Rate Glossary of Terms.pdf` -
`HighSchoolGraduationRateDatabaseReadMe.pdf` -
`How to Open an Access File Using Excel.pdf`

**2018-19 ZIP Contents:** - `GRAD_RATE_AND_OUTCOMES_2019.csv` (58 MB) -
**CSV directly available!** - `GRAD_RATE_AND_OUTCOMES_2019.mdb` (132
MB) - `GRAD_RATE_AND_OUTCOMES_2019.accdb` (132 MB)

**2004-05 ZIP Contents:** -
`2001Cohort 2005 GradRateRelease Database.accdb` (15 MB) -
`2001Cohort 2005 GradRateRelease Database.mdb` (15 MB) -
`2000and2001Cohorts_Outcomes_Suppressed.xlsx` (2 MB)

### Database Schema (2023-24)

**Table:** `GRAD_RATE_AND_OUTCOMES_2024`

| Column                     | Type       | Description                                                           |
|----------------------------|------------|-----------------------------------------------------------------------|
| report_school_year         | Text (7)   | e.g., “2023-24”                                                       |
| aggregation_index          | Double     | Sort order (0=State, 1=NRC, 2=County, 3=District, 4=School)           |
| aggregation_type           | Text (25)  | “Statewide”, “County”, “District”, “School”, “Need/Resource Category” |
| INSTITUTION_ID             | Text (20)  | Unique ID (may be empty for districts)                                |
| aggregation_code           | Text (15)  | 12-digit BEDS code for schools, 12-digit for districts ending in 0000 |
| aggregation_name           | Text (60)  | Entity name                                                           |
| lea_beds                   | Text (12)  | LEA BEDS code (12 digits, ending in 0000)                             |
| lea_name                   | Text (60)  | LEA name                                                              |
| nrc_code                   | Text (1)   | Need/Resource Category code (1-6)                                     |
| nrc_desc                   | Text (60)  | NRC description                                                       |
| county_code                | Text (2)   | 2-digit county code                                                   |
| county_name                | Text (14)  | County name                                                           |
| nyc_ind                    | Text (2)   | NYC indicator (“0” or “1”)                                            |
| boces_code                 | Text (4)   | BOCES code                                                            |
| boces_name                 | Text (60)  | BOCES name                                                            |
| membership_code            | Double     | Cohort type code                                                      |
| membership_desc            | Text (60)  | Cohort description                                                    |
| subgroup_code              | Text (3)   | Student subgroup code                                                 |
| subgroup_name              | Text (100) | Student subgroup name                                                 |
| enroll_cnt                 | Text (8)   | Cohort enrollment count                                               |
| grad_cnt                   | Text (8)   | Graduate count                                                        |
| grad_pct                   | Text (8)   | Graduation rate percentage                                            |
| local_cnt                  | Text (8)   | Local diploma count                                                   |
| local_pct                  | Text (8)   | Local diploma percentage                                              |
| reg_cnt                    | Text (8)   | Regents diploma count                                                 |
| reg_pct                    | Text (8)   | Regents diploma percentage                                            |
| reg_adv_cnt                | Text (8)   | Advanced Regents diploma count                                        |
| reg_adv_pct                | Text (8)   | Advanced Regents diploma percentage                                   |
| non_diploma_credential_cnt | Text (8)   | Non-diploma credential count                                          |
| non_diploma_credential_pct | Text (8)   | Non-diploma credential percentage                                     |
| still_enr_cnt              | Text (8)   | Still enrolled count                                                  |
| still_enr_pct              | Text (8)   | Still enrolled percentage                                             |
| ged_cnt                    | Text (8)   | GED count                                                             |
| ged_pct                    | Text (8)   | GED percentage                                                        |
| dropout_cnt                | Text (8)   | Dropout count                                                         |
| dropout_pct                | Text (8)   | Dropout percentage                                                    |

### 2018-19 Schema Differences

The 2018-19 CSV has additional columns: - `membership_key` - Additional
identifier for cohort - `entity_inactive_date` - Date entity became
inactive (if applicable)

### Aggregation Types

| aggregation_index | aggregation_type       | Description        |
|-------------------|------------------------|--------------------|
| 0                 | Statewide              | State totals       |
| 1                 | Need/Resource Category | NRC groupings      |
| 2                 | County                 | County totals      |
| 3                 | District               | District totals    |
| 4                 | School                 | Individual schools |

### Membership Codes (Cohort Types)

| Code | Description             |
|------|-------------------------|
| 6    | 6 Year Outcome (June)   |
| 8    | 5 Year Outcome (June)   |
| 9    | 4 Year Outcome (June)   |
| 10   | 5 Year Outcome (August) |
| 11   | 4 Year Outcome (August) |
| 18   | 6 Year Outcome (August) |

**Note:** Cohort year is derived from membership_desc. For 2023-24
file: - 4-year cohort: 2020 (entered 9th grade 2020-21, graduated by
2023-24) - 5-year cohort: 2019 (entered 9th grade 2019-20, graduated by
2023-24) - 6-year cohort: 2018 (entered 9th grade 2018-19, graduated by
2023-24)

### Subgroup Codes

| Code | Subgroup Name                                   |
|------|-------------------------------------------------|
| 01   | All Students                                    |
| 02   | Female                                          |
| 03   | Male                                            |
| 04   | American Indian or Alaska Native                |
| 05   | Black or African American                       |
| 06   | Hispanic or Latino                              |
| 07   | Asian or Native Hawaiian/Other Pacific Islander |
| 08   | White                                           |
| 09   | Multiracial                                     |
| 10   | General Education Students                      |
| 11   | Students with Disabilities                      |
| 12   | Non-English Language Learner                    |
| 13   | English Language Learner                        |
| 15   | Economically Disadvantaged                      |
| 16   | Not Economically Disadvantaged                  |
| 17   | Migrant                                         |
| 18   | Not Migrant                                     |
| 20   | Homeless                                        |
| 21   | Not Homeless                                    |
| 22   | In Foster Care                                  |
| 23   | Not in Foster Care                              |
| 24   | Parent in Armed Forces                          |
| 25   | Parent Not in Armed Forces                      |
| 29   | Nonbinary (new in recent years)                 |

### Schema Changes Over Time

| Year     | Notable Changes                                  |
|----------|--------------------------------------------------|
| 2023-24  | Added subgroup 29 (Nonbinary)                    |
| 2018-19+ | CSV files included in ZIP                        |
| 2017-18  | File naming convention changed                   |
| 2013-14  | Only Excel file provided                         |
| Pre-2014 | Different column names, older cohort definitions |

### ID System

- **School BEDS Code:** 12 digits (e.g., `010100010034`)
  - First 6 digits: District code
  - Digits 7-8: School type
  - Digits 9-12: School number
- **District BEDS Code:** 12 digits ending in `0000` (e.g.,
  `010100010000`)
- **County Code:** 2 digits
- **NRC Code:** 1 digit (1-6)

### Known Data Issues

1.  **Data suppression:** Counts \< 5 are suppressed (shown as blank or
    special character)
2.  **Percentages stored as text:** All percentage columns include “%”
    character
3.  **Counts stored as text:** All count columns are text, not numeric
4.  **File format variation:** 2023-24 only has .mdb; older years have
    CSV/Excel options
5.  **Table naming:** Table names include year (e.g.,
    `GRAD_RATE_AND_OUTCOMES_2024`)

## Time Series Heuristics

Based on 2023-24 statewide data:

| Metric                 | Value               | Expected Range    |
|------------------------|---------------------|-------------------|
| State 4-year cohort    | ~199,000 students   | 195,000 - 210,000 |
| State 4-year grad rate | 84-86%              | 80% - 90%         |
| State 5-year grad rate | 88-89%              | 85% - 92%         |
| State 6-year grad rate | 90%                 | 88% - 93%         |
| NYC 4-year cohort      | ~69,000 students    | 65,000 - 75,000   |
| NYC 4-year grad rate   | 80-83%              | 75% - 88%         |
| Total schools          | ~1,300 high schools | 1,200 - 1,500     |
| Total districts        | ~700 districts      | 650 - 750         |

### Red Flags

- State total graduation rate \< 80% or \> 95%
- YoY change in cohort size \> 5%
- YoY change in graduation rate \> 5%
- Major districts missing from data

### Major Entities to Verify

| Entity    | BEDS Code    | Expected 4-yr Rate |
|-----------|--------------|--------------------|
| NYC DOE   | NRC Code = 1 | ~80-85%            |
| Buffalo   | 140600010000 | ~75-85%            |
| Rochester | 261600010000 | ~70-80%            |
| Syracuse  | 421800010000 | ~75-85%            |
| Yonkers   | 662300010000 | ~80-88%            |

## Recommended Implementation

### Priority: HIGH

### Complexity: MEDIUM-HARD

### Estimated Files to Create/Modify: 6-8

### Implementation Steps

1.  **Add dependency for Access database reading**

    - Option A: Use `mdbr` package (requires mdbtools on system)
    - Option B: Use `Hmisc::mdb.get()` (also requires mdbtools)
    - Option C: Export to CSV using mdbtools CLI before reading
    - **Recommended:** Export to CSV via mdbtools since some years
      already have CSV

2.  **Create URL builder function**

    ``` r
    build_grad_url <- function(end_year) {
      # Handle 3 different URL patterns based on year
    }
    ```

3.  **Create `get_raw_grad()` function**

    - Download ZIP file
    - Extract appropriate file (prefer CSV if available, else use mdb)
    - Read data into R
    - Standardize column names across years

4.  **Create `process_grad()` function**

    - Convert text percentages to numeric
    - Convert text counts to numeric
    - Handle suppressed values
    - Add cohort_year column (derived from membership_desc)
    - Standardize entity identifiers

5.  **Create `tidy_grad()` function**

    - Pivot outcome columns (grad, local, reg, reg_adv, non_diploma,
      still_enr, ged, dropout)
    - Create consistent subgroup column
    - Match enrollment package structure where possible

6.  **Create `fetch_grad()` main function**

    - Similar interface to
      [`fetch_enr()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr.md)
    - Parameters: end_year, level, cohort_type, tidy, use_cache

7.  **Add helper functions**

    - `get_available_grad_years()` - return 2005:2024
    - `validate_cohort_type()` - check for valid cohort codes
    - `extract_cohort_year()` - parse membership_desc

8.  **Write comprehensive tests**

    - URL availability tests for all years
    - File download/extraction tests
    - Schema validation tests
    - Raw data fidelity tests
    - Data quality tests

### Challenges

1.  **mdbtools dependency:** Users need mdbtools installed on their
    system
    - Solution: Document installation; fallback to CSV for years that
      have it
    - Alternative: Include pre-converted CSV files for years without CSV
2.  **Large file sizes:** ZIP files range 6-60 MB
    - Solution: Cache extracted data locally
3.  **Schema variations:** Column names and table names change by year
    - Solution: Create year-specific parsers or mapping functions
4.  **Suppressed data:** Many cells are suppressed for privacy
    - Solution: Convert to NA and document

## Test Requirements

### Raw Data Fidelity Tests Needed

``` r
# 2024 State totals (2020 cohort, 4-year June outcome)
test_that("2024 state graduation rate matches raw data", {
  data <- fetch_grad(2024, level = "state", cohort = "4year_june")
  all_students <- data |> filter(subgroup_code == "01")

  # Values from GRAD_RATE_AND_OUTCOMES_2024 table
  expect_equal(all_students$cohort_count, 199129)
  expect_equal(all_students$grad_count, 168034)
  expect_equal(all_students$grad_rate, 0.84, tolerance = 0.01)
})

# 2024 NYC totals
test_that("2024 NYC graduation rate matches raw data", {
  data <- fetch_grad(2024, level = "nrc", cohort = "4year_june")
  nyc <- data |> filter(nrc_code == "1", subgroup_code == "01")

  expect_equal(nyc$cohort_count, 68882)
  expect_equal(nyc$grad_count, 55435)
  expect_equal(nyc$grad_rate, 0.80, tolerance = 0.01)
})

# 2024 Albany High School
test_that("2024 Albany High School matches raw data", {
  data <- fetch_grad(2024, level = "school", cohort = "4year_june")
  albany <- data |> filter(beds_code == "010100010034", subgroup_code == "01")

  expect_equal(albany$cohort_count, 714)
  expect_equal(albany$grad_count, 504)
  expect_equal(albany$grad_rate, 0.71, tolerance = 0.01)
})
```

### Data Quality Checks

``` r
test_that("graduation rates are in valid range", {
  data <- fetch_grad(2024, level = "state")
  expect_true(all(data$grad_rate >= 0 & data$grad_rate <= 1, na.rm = TRUE))
})

test_that("dropout + grad + still_enrolled + other sums to 100%", {
  data <- fetch_grad(2024, level = "state", cohort = "4year_june", tidy = FALSE)
  all_students <- data |> filter(subgroup_code == "01")

  # Sum of outcomes should equal cohort count
  total <- all_students$grad_cnt + all_students$still_enr_cnt +
           all_students$ged_cnt + all_students$dropout_cnt +
           all_students$non_diploma_credential_cnt
  expect_equal(total, all_students$enroll_cnt, tolerance = 100)
})

test_that("no negative counts", {
  data <- fetch_grad(2024, tidy = FALSE)
  numeric_cols <- grep("_cnt$", names(data), value = TRUE)
  for (col in numeric_cols) {
    expect_true(all(data[[col]] >= 0, na.rm = TRUE), info = col)
  }
})
```

### Cross-Year Tests

``` r
test_that("state totals are consistent across years", {
  for (year in 2020:2024) {
    data <- fetch_grad(year, level = "state", cohort = "4year_june")
    total <- data |> filter(subgroup_code == "01") |> pull(cohort_count)
    expect_gt(total, 190000, info = paste("Year:", year))
    expect_lt(total, 220000, info = paste("Year:", year))
  }
})
```

## Additional Resources

- Business Rules:
  <https://data.nysed.gov/businessrules.php?type=gradrate>
- SIRS Manual (cohort definitions):
  [http://www.p12.nysed.gov/irs/sirs/home.html](http://www.p12.nysed.gov/irs/sirs/home.md)
- Historical archive:
  <https://www.p12.nysed.gov/irs/cohort/archive-grad.html>
- Downloads page: <https://data.nysed.gov/downloads.php>

## Notes on R Package Dependencies

If using mdbtools approach, need to document: - macOS:
`brew install mdbtools` - Debian/Ubuntu: `apt install mdbtools` -
Windows: Manual installation or use different approach

Alternative approach: Use `DBI` + `odbc` with Access ODBC drivers (more
complex setup).

Simplest approach for cross-platform: Pre-process .mdb files to CSV
during package build and distribute CSV data, or provide utility to
convert.
