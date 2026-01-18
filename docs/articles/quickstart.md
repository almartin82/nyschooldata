# Getting Started with nyschooldata

## Introduction

The `nyschooldata` package provides easy access to New York State public
school enrollment data from the [NYSED IRS (Information Reporting
Services)](https://data.nysed.gov/) database. This vignette covers:

1.  Installation and setup
2.  Fetching enrollment data
3.  Understanding the data schema
4.  Filtering and analyzing data
5.  Working with BEDS codes
6.  Visualizing enrollment trends

## Installation

Install from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("almartin82/nyschooldata")
```

Load the package along with commonly used analysis packages:

``` r
library(nyschooldata)
library(dplyr)
library(ggplot2)
library(scales)
```

## Fetching Enrollment Data

### Basic Usage

The main function is
[`fetch_enr()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr.md),
which downloads and processes enrollment data for a given school year:

``` r
# Fetch 2024 enrollment data (2023-24 school year)
# Note: year refers to the END of the school year
enr <- fetch_enr(2024, use_cache = TRUE)

head(enr)
```

    ##   end_year county district_beds district_code district_name    beds_code
    ## 1     2024 ALBANY  010100010000        010100        ALBANY 010100010014
    ## 2     2024 ALBANY  010100010000        010100        ALBANY 010100010016
    ## 3     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 4     2024 ALBANY  010100010000        010100        ALBANY 010100010019
    ## 5     2024 ALBANY  010100010000        010100        ALBANY 010100010023
    ## 6     2024 ALBANY  010100010000        010100        ALBANY 010100010027
    ##   school_code                    school_name school_type is_state is_district
    ## 1        0100       MONTESSORI MAGNET SCHOOL      Public    FALSE       FALSE
    ## 2        0100   PINE HILLS ELEMENTARY SCHOOL      Public    FALSE       FALSE
    ## 3        0100      DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 4        0100 NEW SCOTLAND ELEMENTARY SCHOOL      Public    FALSE       FALSE
    ## 5        0100    ALBANY SCHOOL OF HUMANITIES      Public    FALSE       FALSE
    ## 6        0100  EAGLE POINT ELEMENTARY SCHOOL      Public    FALSE       FALSE
    ##   is_school is_nyc is_charter grade_level         subgroup n_students pct
    ## 1      TRUE  FALSE      FALSE       TOTAL total_enrollment        324   1
    ## 2      TRUE  FALSE      FALSE       TOTAL total_enrollment        347   1
    ## 3      TRUE  FALSE      FALSE       TOTAL total_enrollment        311   1
    ## 4      TRUE  FALSE      FALSE       TOTAL total_enrollment        459   1
    ## 5      TRUE  FALSE      FALSE       TOTAL total_enrollment        332   1
    ## 6      TRUE  FALSE      FALSE       TOTAL total_enrollment        286   1

The `end_year` parameter refers to the end of the school year. For
example: - `fetch_enr(2024)` returns data for the 2023-24 school year -
`fetch_enr(2020)` returns data for the 2019-20 school year

### Available Years

Data is available from 2012 (2011-12 school year) through 2024 (2023-24
school year):

``` r
get_available_years()
```

    ## $min_year
    ## [1] 1977
    ## 
    ## $max_year
    ## [1] 2024

### Data Levels

You can fetch school-level or district-level data:

``` r
# School-level data (default)
school_enr <- fetch_enr(2024, level = "school", use_cache = TRUE)

# District-level aggregates
district_enr <- fetch_enr(2024, level = "district", use_cache = TRUE)
```

### Wide vs. Tidy Format

By default, data is returned in **tidy (long) format** with one row per
school/grade combination:

``` r
# Tidy format (default): one row per school per grade
enr_tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

enr_tidy %>%
  filter(is_school) %>%
  select(school_name, grade_level, n_students) %>%
  head(10)
```

    ##                            school_name grade_level n_students
    ## 1             MONTESSORI MAGNET SCHOOL       TOTAL        324
    ## 2         PINE HILLS ELEMENTARY SCHOOL       TOTAL        347
    ## 3            DELAWARE COMMUNITY SCHOOL       TOTAL        311
    ## 4       NEW SCOTLAND ELEMENTARY SCHOOL       TOTAL        459
    ## 5          ALBANY SCHOOL OF HUMANITIES       TOTAL        332
    ## 6        EAGLE POINT ELEMENTARY SCHOOL       TOTAL        286
    ## 7  THOMAS S O'BRIEN ACAD OF SCI & TECH       TOTAL        263
    ## 8    GIFFEN MEMORIAL ELEMENTARY SCHOOL       TOTAL        406
    ## 9      WILLIAM S HACKETT MIDDLE SCHOOL       TOTAL        630
    ## 10                  ALBANY HIGH SCHOOL       TOTAL       2764

For **wide format** with one column per grade level:

``` r
# Wide format: one row per school, columns for each grade
enr_wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

enr_wide %>%
  filter(is_school) %>%
  select(school_name, row_total, grade_pk, grade_k, grade_01, grade_09, grade_12) %>%
  head(5)
```

    ##                      school_name row_total grade_pk grade_k grade_01 grade_09
    ## 1       MONTESSORI MAGNET SCHOOL       324       32      51       48        0
    ## 2   PINE HILLS ELEMENTARY SCHOOL       347        0      55       68        0
    ## 3      DELAWARE COMMUNITY SCHOOL       311       20      51       49        0
    ## 4 NEW SCOTLAND ELEMENTARY SCHOOL       459        0      72       87        0
    ## 5    ALBANY SCHOOL OF HUMANITIES       332        0      41       58        0
    ##   grade_12
    ## 1        0
    ## 2        0
    ## 3        0
    ## 4        0
    ## 5        0

## Understanding the Data Schema

### Key Columns

The tidy format includes these important columns:

| Column          | Description                              |
|-----------------|------------------------------------------|
| `end_year`      | School year end (e.g., 2024 for 2023-24) |
| `county`        | County name                              |
| `district_code` | 6-digit district identifier              |
| `district_name` | District name                            |
| `beds_code`     | 12-digit BEDS code (school identifier)   |
| `school_name`   | School name                              |
| `grade_level`   | Grade level (TOTAL, PK, K, 01-12)        |
| `n_students`    | Enrollment count                         |
| `pct`           | Percentage of school’s total enrollment  |

### Aggregation Flags

Boolean flags help filter to the right level of data:

| Flag          | Description                                |
|---------------|--------------------------------------------|
| `is_state`    | State-level aggregate (currently not used) |
| `is_district` | District-level aggregate row               |
| `is_school`   | Individual school record                   |
| `is_nyc`      | NYC DOE school/district                    |
| `is_charter`  | Charter school                             |

``` r
# All districts
districts <- enr %>% filter(is_district, grade_level == "TOTAL")
nrow(districts)
```

    ## [1] 0

``` r
# All schools
schools <- enr %>% filter(is_school, grade_level == "TOTAL")
nrow(schools)
```

    ## [1] 4749

``` r
# Only NYC schools
nyc_schools <- enr %>% filter(is_school, is_nyc, grade_level == "TOTAL")
nrow(nyc_schools)
```

    ## [1] 1864

``` r
# Only charter schools
charters <- enr %>% filter(is_school, is_charter, grade_level == "TOTAL")
nrow(charters)
```

    ## [1] 343

### Grade Level Values

In tidy format, the `grade_level` column contains:

- `TOTAL` - Total enrollment
- `PK` - Pre-Kindergarten (combined half and full day)
- `PK_HALF` - Pre-K half day
- `PK_FULL` - Pre-K full day
- `K` - Kindergarten (combined)
- `K_HALF` - Kindergarten half day
- `K_FULL` - Kindergarten full day
- `01` through `12` - Grades 1-12
- `UG_ELEM` - Ungraded elementary
- `UG_SEC` - Ungraded secondary

## Working with BEDS Codes

### What is a BEDS Code?

New York uses 12-digit BEDS (Basic Educational Data System) codes to
uniquely identify schools and districts:

    DDDDDDSSSSCC
    │     │   │
    │     │   └── Check digits (2)
    │     └────── School code (4)
    └──────────── District code (6)

### Parsing BEDS Codes

Use
[`parse_beds_code()`](https://almartin82.github.io/nyschooldata/reference/parse_beds_code.md)
to extract components:

``` r
# Parse a BEDS code
parse_beds_code("010100010018")
```

    ##      beds_code district_code school_code check_digits
    ## 1 010100010018        010100        0100           18

``` r
# Returns:
#      beds_code district_code school_code check_digits
# 1 010100010018        010100        0001           18

# Parse multiple codes
beds_codes <- c("010100010018", "310200010001", "261600010001")
parse_beds_code(beds_codes)
```

    ##      beds_code district_code school_code check_digits
    ## 1 010100010018        010100        0100           18
    ## 2 310200010001        310200        0100           01
    ## 3 261600010001        261600        0100           01

### Validating BEDS Codes

Check if codes are properly formatted:

``` r
# Validate BEDS codes
validate_beds_code("010100010018")    # TRUE - valid
```

    ## [1] TRUE

``` r
validate_beds_code("31000001023")     # FALSE - only 11 digits
```

    ## [1] FALSE

``` r
validate_beds_code("invalid")          # FALSE - not numeric
```

    ## [1] FALSE

### Looking Up Specific Schools

Use
[`fetch_enr_school()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_school.md)
to get data for a single school:

``` r
# Get enrollment for a specific school by BEDS code
school_enr <- fetch_enr_school("010100010018", 2024, use_cache = TRUE)
school_enr
```

    ##    end_year county district_beds district_code district_name    beds_code
    ## 1      2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 2      2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 3      2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 4      2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 5      2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 6      2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 7      2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 8      2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 9      2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 10     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 11     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 12     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 13     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 14     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 15     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 16     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 17     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 18     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 19     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 20     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ## 21     2024 ALBANY  010100010000        010100        ALBANY 010100010018
    ##    school_code               school_name school_type is_state is_district
    ## 1         0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 2         0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 3         0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 4         0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 5         0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 6         0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 7         0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 8         0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 9         0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 10        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 11        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 12        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 13        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 14        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 15        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 16        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 17        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 18        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 19        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 20        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ## 21        0100 DELAWARE COMMUNITY SCHOOL      Public    FALSE       FALSE
    ##    is_school is_nyc is_charter grade_level         subgroup n_students
    ## 1       TRUE  FALSE      FALSE       TOTAL total_enrollment        311
    ## 2       TRUE  FALSE      FALSE          PK total_enrollment         20
    ## 3       TRUE  FALSE      FALSE     PK_HALF total_enrollment          0
    ## 4       TRUE  FALSE      FALSE     PK_FULL total_enrollment         20
    ## 5       TRUE  FALSE      FALSE           K total_enrollment         51
    ## 6       TRUE  FALSE      FALSE      K_HALF total_enrollment          0
    ## 7       TRUE  FALSE      FALSE      K_FULL total_enrollment         51
    ## 8       TRUE  FALSE      FALSE          01 total_enrollment         49
    ## 9       TRUE  FALSE      FALSE          02 total_enrollment         52
    ## 10      TRUE  FALSE      FALSE          03 total_enrollment         52
    ## 11      TRUE  FALSE      FALSE          04 total_enrollment         45
    ## 12      TRUE  FALSE      FALSE          05 total_enrollment         42
    ## 13      TRUE  FALSE      FALSE          06 total_enrollment          0
    ## 14      TRUE  FALSE      FALSE          07 total_enrollment          0
    ## 15      TRUE  FALSE      FALSE          08 total_enrollment          0
    ## 16      TRUE  FALSE      FALSE          09 total_enrollment          0
    ## 17      TRUE  FALSE      FALSE          10 total_enrollment          0
    ## 18      TRUE  FALSE      FALSE          11 total_enrollment          0
    ## 19      TRUE  FALSE      FALSE          12 total_enrollment          0
    ## 20      TRUE  FALSE      FALSE     UG_ELEM total_enrollment          0
    ## 21      TRUE  FALSE      FALSE      UG_SEC total_enrollment          0
    ##           pct
    ## 1  1.00000000
    ## 2  0.06430868
    ## 3  0.00000000
    ## 4  0.06430868
    ## 5  0.16398714
    ## 6  0.00000000
    ## 7  0.16398714
    ## 8  0.15755627
    ## 9  0.16720257
    ## 10 0.16720257
    ## 11 0.14469453
    ## 12 0.13504823
    ## 13 0.00000000
    ## 14 0.00000000
    ## 15 0.00000000
    ## 16 0.00000000
    ## 17 0.00000000
    ## 18 0.00000000
    ## 19 0.00000000
    ## 20 0.00000000
    ## 21 0.00000000

``` r
# Get multiple years for a school
school_history <- fetch_enr_school("010100010018", 2020:2024, use_cache = TRUE)
```

### Looking Up Districts

Use
[`fetch_enr_district()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr_district.md)
for district-level queries:

``` r
# Get all schools in a district
albany_schools <- fetch_enr_district("010100", 2024, level = "school", use_cache = TRUE)

# Get district aggregates only
albany_district <- fetch_enr_district("010100", 2024, level = "district", use_cache = TRUE)
```

## Filtering and Analysis

### Top Districts by Enrollment

``` r
enr %>%
  filter(is_district, grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  select(district_name, county, n_students) %>%
  head(10)
```

    ## [1] district_name county        n_students   
    ## <0 rows> (or 0-length row.names)

### Enrollment by County

``` r
enr %>%
  filter(is_district, grade_level == "TOTAL") %>%
  group_by(county) %>%
  summarize(
    n_districts = n(),
    total_enrollment = sum(n_students, na.rm = TRUE)
  ) %>%
  arrange(desc(total_enrollment)) %>%
  head(10)
```

    ## # A tibble: 0 × 3
    ## # ℹ 3 variables: county <chr>, n_districts <int>, total_enrollment <dbl>

### Grade-Level Distribution

``` r
# Statewide grade distribution
enr %>%
  filter(is_district, grade_level != "TOTAL") %>%
  group_by(grade_level) %>%
  summarize(total = sum(n_students, na.rm = TRUE)) %>%
  arrange(factor(grade_level, levels = c("PK", "K", sprintf("%02d", 1:12))))
```

    ## # A tibble: 0 × 2
    ## # ℹ 2 variables: grade_level <chr>, total <dbl>

### Filtering by Grade Span

Use
[`filter_grade_span()`](https://almartin82.github.io/nyschooldata/reference/filter_grade_span.md)
for common grade groupings:

``` r
# Get only elementary grades (K-5)
elem_enr <- filter_grade_span(enr, "elem")

# Get only high school grades (9-12)
hs_enr <- filter_grade_span(enr, "hs")

# Available spans: "pk12", "k12", "k8", "hs", "elem" (K-5), "middle" (6-8)
```

### Custom Grade Aggregates

Create K-8, HS, and K-12 aggregates with
[`enr_grade_aggs()`](https://almartin82.github.io/nyschooldata/reference/enr_grade_aggs.md):

``` r
# Get grade span aggregates
aggs <- enr_grade_aggs(enr)

aggs %>%
  filter(is_district) %>%
  select(district_name, grade_level, n_students) %>%
  head(15)
```

    ## # A tibble: 0 × 3
    ## # ℹ 3 variables: district_name <chr>, grade_level <chr>, n_students <dbl>

## NYC Schools

NYC is unique in New York - it’s organized as 32 geographic Community
School Districts plus District 75 (special education) and District 79
(alternative schools). Use the convenience function:

``` r
# Get NYC enrollment directly
nyc <- fetch_enr_nyc(2024, use_cache = TRUE)

# Largest NYC schools
nyc %>%
  filter(is_school, grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  select(school_name, district_name, n_students) %>%
  head(10)
```

    ##                    school_name                 district_name n_students
    ## 1        BROOKLYN TECHNICAL HS  NYC GEOG DIST #13 - BROOKLYN       5810
    ## 2    FRANCIS LEWIS HIGH SCHOOL    NYC GEOG DIST #26 - QUEENS       4404
    ## 3    FORT HAMILTON HIGH SCHOOL  NYC GEOG DIST #20 - BROOKLYN       3980
    ## 4          MIDWOOD HIGH SCHOOL  NYC GEOG DIST #22 - BROOKLYN       3905
    ## 5      TOTTENVILLE HIGH SCHOOL        NYC GEOG DIST #31 - SI       3796
    ## 6    JAMES MADISON HIGH SCHOOL  NYC GEOG DIST #22 - BROOKLYN       3766
    ## 7  EDWARD R MURROW HIGH SCHOOL  NYC GEOG DIST #21 - BROOKLYN       3589
    ## 8     FOREST HILLS HIGH SCHOOL    NYC GEOG DIST #28 - QUEENS       3420
    ## 9      FRANKLIN D ROOSEVELT HS  NYC GEOG DIST #20 - BROOKLYN       3409
    ## 10      STUYVESANT HIGH SCHOOL NYC GEOG DIST # 2 - MANHATTAN       3258

NYC district codes follow this pattern: - `30xxxx` - District 75
(citywide special education) - `31xxxx` - Manhattan districts -
`32xxxx` - Bronx districts - `33xxxx` - Brooklyn districts - `34xxxx` -
Queens districts - `35xxxx` - Staten Island district

## Multi-Year Analysis

### Fetching Multiple Years

``` r
# Fetch 5 years of data
enr_multi <- fetch_enr_years(2020:2024, use_cache = TRUE)

# Check years retrieved
unique(enr_multi$end_year)
```

    ## [1] 2020 2021 2022 2023 2024

### Enrollment Trends

``` r
# Statewide enrollment trend
state_trend <- enr_multi %>%
  filter(is_district, grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(total_enrollment = sum(n_students, na.rm = TRUE))

state_trend
```

    ## # A tibble: 3 × 2
    ##   end_year total_enrollment
    ##      <int>            <dbl>
    ## 1     2020          2638949
    ## 2     2021          2559164
    ## 3     2022          2505517

## Visualization Examples

### Statewide Enrollment Trend

``` r
library(ggplot2)
library(scales)

ggplot(state_trend, aes(x = end_year, y = total_enrollment)) +
  geom_line(linewidth = 1, color = "steelblue") +
  geom_point(size = 3, color = "steelblue") +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(
    title = "New York State Public School Enrollment",
    x = "School Year (End Year)",
    y = "Total Enrollment",
    caption = "Source: NYSED IRS"
  ) +
  theme_minimal()
```

### Grade-Level Distribution

``` r
grade_dist <- enr %>%
  filter(is_district, !grade_level %in% c("TOTAL", "PK_HALF", "PK_FULL", "K_HALF", "K_FULL", "UG_ELEM", "UG_SEC")) %>%
  group_by(grade_level) %>%
  summarize(total = sum(n_students, na.rm = TRUE)) %>%
  mutate(grade_level = factor(grade_level, levels = c("PK", "K", sprintf("%02d", 1:12))))

ggplot(grade_dist, aes(x = grade_level, y = total)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = comma) +
  labs(
    title = "NY State Enrollment by Grade Level",
    x = "Grade",
    y = "Enrollment"
  ) +
  theme_minimal()
```

### Comparing Districts

``` r
# Compare top 5 districts over time
top_districts <- enr_multi %>%
  filter(is_district, grade_level == "TOTAL", end_year == max(end_year)) %>%
  slice_max(n_students, n = 5) %>%
  pull(district_code)

district_trends <- enr_multi %>%
  filter(district_code %in% top_districts, is_district, grade_level == "TOTAL")

ggplot(district_trends, aes(x = end_year, y = n_students, color = district_name)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Enrollment Trends: Top 5 NY Districts",
    x = "School Year",
    y = "Enrollment",
    color = "District"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))
```

## Caching

Data is cached locally by default to avoid repeated downloads. Manage
the cache with:

``` r
# View cache status
cache_status()
```

    ##    year data_type          type size_mb age_days
    ## 1  2012       enr district_tidy    0.10        0
    ## 2  2013       enr district_tidy    0.10        0
    ## 3  2014       enr district_tidy    0.10        0
    ## 4  2015       enr district_tidy    0.10        0
    ## 5  2016       enr district_tidy    0.10        0
    ## 6  2017       enr district_tidy    0.10        0
    ## 7  2018       enr district_tidy    0.10        0
    ## 8  2019       enr district_tidy    0.10        0
    ## 9  2020       enr district_tidy    0.10        0
    ## 10 2020       enr   school_tidy    1.07        0
    ## 11 2021       enr district_tidy    0.09        0
    ## 12 2021       enr   school_tidy    1.07        0
    ## 13 2022       enr district_tidy    0.09        0
    ## 14 2022       enr   school_tidy    0.91        0
    ## 15 2023       enr district_tidy    0.12        0
    ## 16 2023       enr   school_tidy    1.82        0
    ## 17 2024       enr district_tidy    0.12        0
    ## 18 2024       enr   school_tidy    1.83        0
    ## 19 2024       enr   school_wide    0.17        0

``` r
# Clear all cached data
clear_enr_cache()

# Clear only 2024 data
clear_enr_cache(2024)

# Force fresh download (bypass cache)
enr_fresh <- fetch_enr(2024, use_cache = FALSE)
```

## School Year Labels

Convert between year integers and label strings:

``` r
# Convert end year to label
school_year_label(2024)
```

    ## [1] "2023-24"

``` r
# [1] "2023-24"

# Parse label back to end year
parse_school_year("2023-24")
```

    ## [1] 2024

``` r
# [1] 2024

# Works with "2023-2024" format too
parse_school_year("2023-2024")
```

    ## [1] 2024

``` r
# [1] 2024
```

## Next Steps

- See
  [`?fetch_enr`](https://almartin82.github.io/nyschooldata/reference/fetch_enr.md)
  for complete function documentation
- Explore the [Data Quality
  QA](https://almartin82.github.io/nyschooldata/articles/data-quality-qa.md)
  vignette for validation examples
- Check
  [`get_available_years()`](https://almartin82.github.io/nyschooldata/reference/get_available_years.md)
  for the current range of available data
- Visit the [pkgdown site](https://almartin82.github.io/nyschooldata/)
  for full API reference
