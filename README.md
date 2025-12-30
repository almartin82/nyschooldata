# nyschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/nyschooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/nyschooldata/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/almartin82/nyschooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/nyschooldata/actions/workflows/pkgdown.yaml)
<!-- badges: end -->

**Documentation: <https://almartin82.github.io/nyschooldata/>**

An R package for fetching and processing New York State school enrollment data from the [NYSED IRS (Information Reporting Services)](https://data.nysed.gov/) Public School Enrollment database.

## Where Did 300,000 Students Go?

Since 2012, New York public schools have lost **295,521 students** - equivalent to emptying every school in Buffalo, Rochester, Syracuse, and Yonkers. But this headline masks a complex story: Pre-K exploded, special education expanded, and only one county in the state actually grew.

### 10 Surprising Findings

| # | Finding | Statistic |
|---|---------|-----------|
| 1 | **The Vanishing 300K** | -295,521 students (-11%) since 2012 |
| 2 | **The COVID Cliff** | -106,560 in 2021 alone (-4.2%) |
| 3 | **The Pre-K Revolution** | +463% full-day enrollment (28K → 157K) |
| 4 | **The Bronx Exodus** | -24% (worst county decline) |
| 5 | **Rochester's Collapse** | -30% (worst major district) |
| 6 | **Special Ed Surge** | NYC District 75 grew +40% |
| 7 | **Grade 1 Cratering** | -17% (the pipeline is shrinking) |
| 8 | **Charter Growth** | 181K students now (7.3% market share) |
| 9 | **One County Grew** | Only Saratoga (+0.3% of 62 counties) |
| 10 | **The Pre-K Inversion** | NYC 99% full-day vs 85% rest of state |

**The Shock**: 2024 showed the first positive year (+388 students) after a decade of decline.

Explore the data: **[Full Analysis with Charts](https://almartin82.github.io/nyschooldata/articles/district-hooks.html)**

## Installation

Install from GitHub:
```r
# install.packages("remotes")
remotes::install_github("almartin82/nyschooldata")
```

## Quick Start

```r
library(nyschooldata)
library(dplyr)

# Fetch the most recent year of enrollment data (2023-24 school year)
enr <- fetch_enr(2024)

# View statewide totals
enr %>%
  filter(is_district, grade_level == "TOTAL") %>%
  summarize(total = sum(n_students, na.rm = TRUE))
#> 2,404,319 students

# Top 10 largest districts
enr %>%
  filter(is_district, grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  select(district_name, county, n_students) %>%
  head(10)
```

### Multi-Year Trends

```r
# Fetch 5 years of data
enr_multi <- fetch_enr_years(2020:2024)

# Calculate statewide enrollment trend
enr_multi %>%
  filter(is_district, grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(total_enrollment = sum(n_students, na.rm = TRUE))
```

### NYC Schools

NYC DOE is the largest school district in the country. The package automatically identifies NYC schools:

```r
# Get NYC enrollment directly
nyc <- fetch_enr_nyc(2024)

# ~900,000 students in 33 geographic districts
nyc %>%
  filter(is_district, grade_level == "TOTAL") %>%
  summarize(total = sum(n_students, na.rm = TRUE))
```

### Working with BEDS Codes

New York uses 12-digit BEDS codes to identify schools:

```r
# Parse a BEDS code
parse_beds_code("010100010018")
#>      beds_code district_code school_code check_digits
#> 1 010100010018        010100        0001           18

# Fetch a specific school
fetch_enr_school("010100010018", 2024)
```

## Available Years

Data is available from 2012 (2011-12 school year) through 2025 (2024-25 school year):

```r
get_available_years()
#> $min_year: 2012
#> $max_year: 2025
```

## Data Schema

### Key Columns

| Column | Description |
|--------|-------------|
| `end_year` | School year end (2024 = 2023-24) |
| `county` | County name |
| `district_code` | 6-digit district identifier |
| `district_name` | District name |
| `beds_code` | 12-digit BEDS code |
| `school_name` | School name |
| `grade_level` | Grade (TOTAL, PK, K, 01-12) |
| `n_students` | Enrollment count |

### Boolean Flags

| Flag | Description |
|------|-------------|
| `is_district` | District-level aggregate |
| `is_school` | Individual school record |
| `is_nyc` | NYC DOE school/district |
| `is_charter` | Charter school |

## Documentation

- [Getting Started](https://almartin82.github.io/nyschooldata/articles/quickstart.html) - Installation and basic usage
- [10 Surprising Findings](https://almartin82.github.io/nyschooldata/articles/district-hooks.html) - Explore enrollment trends
- [Data Quality QA](https://almartin82.github.io/nyschooldata/articles/data-quality-qa.html) - Validation and anomaly detection
- [Full API Reference](https://almartin82.github.io/nyschooldata/reference/)

## Data Sources

- **Primary source**: [NYSED Information Reporting Services](https://data.nysed.gov/)
- **Data type**: Public school enrollment by grade level
- **Update frequency**: Annual (typically available by fall for prior school year)

## Related Packages

This package follows patterns from:
- [ilschooldata](https://github.com/almartin82/ilschooldata) - Illinois school data
- [njschooldata](https://github.com/almartin82/njschooldata) - New Jersey school data

## License

MIT
