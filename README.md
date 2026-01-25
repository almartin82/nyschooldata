# nyschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/nyschooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/nyschooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/nyschooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/nyschooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/nyschooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/nyschooldata/actions/workflows/pkgdown.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**Docs: <https://almartin82.github.io/nyschooldata/>**

## Why This Package Exists

New York public schools have lost **295,521 students** since 2012 - that's the equivalent of emptying Buffalo, Rochester, Syracuse, and Yonkers combined. But this headline number hides a complex story of urban decline, Pre-K revolution, COVID disruption, and surprising pockets of growth.

This package provides direct, automated access to enrollment data from [NYSED](https://data.nysed.gov/), making it easy to explore **47 years of data** (1977-2024) across 4,700+ schools and 700+ districts.

**Part of the [State Schooldata Project](https://github.com/almartin82/njschooldata)** - a family of R/Python packages providing consistent access to state-published school data. Started with [njschooldata](https://github.com/almartin82/njschooldata), now covering all 50 states.

---

## 10 Surprising Findings in NY School Enrollment

These stories come from the [full analysis vignette](https://almartin82.github.io/nyschooldata/articles/district-hooks.html).

```r
library(nyschooldata)
library(dplyr)
library(ggplot2)
library(scales)
library(tidyr)
```

```r
# Fetch district-level data for all available years
enr <- fetch_enr_years(2012:2024, level = "district", tidy = TRUE, use_cache = TRUE)
```

---

### 1. The Vanishing 300,000

**New York lost 295,521 students (11%) from 2012 to 2024** - equivalent to losing every student in Buffalo, Rochester, Syracuse, and Yonkers combined.

```r
state_trend <- enr %>%
  filter(grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop")

# Calculate loss
loss <- state_trend$total[state_trend$end_year == 2012] -
        state_trend$total[state_trend$end_year == 2024]
#> 295521
```

![Statewide enrollment decline](https://almartin82.github.io/nyschooldata/articles/district-hooks_files/figure-html/statewide-trend-1.png)

---

### 2. The COVID Cliff

**2021 saw an unprecedented 4.2% single-year drop** (106,560 students) - by far the largest decline in recorded data. But 2024 shows the first positive year (+0.02%), suggesting possible stabilization.

```r
state_yoy <- state_trend %>%
  mutate(
    change = total - lag(total),
    pct_change = round(change / lag(total) * 100, 2)
  )
#> 2021: -106560 (-4.16%)
#> 2024: +388 (+0.02%) <- first positive year
```

![Year-over-year changes](https://almartin82.github.io/nyschooldata/articles/district-hooks_files/figure-html/covid-impact-1.png)

---

### 3. The Pre-K Revolution

**Full-day Pre-K exploded from 28K to 157K** - a 463% increase. NYC's Universal Pre-K program drove a stunning 115% jump in 2015 alone.

```r
pk_trend <- enr %>%
  filter(grade_level == "PK_FULL") %>%
  group_by(end_year) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop") %>%
  mutate(
    yoy_pct = round((total - lag(total)) / lag(total) * 100, 1)
  )
#> 2012: 27,885 students
#> 2015: 87,629 students (+115% from 2014)
#> 2024: 157,116 students (+463% from 2012)
```

![Pre-K growth](https://almartin82.github.io/nyschooldata/articles/district-hooks_files/figure-html/prek-growth-1.png)

---

### 4. The Bronx Exodus

**The Bronx lost 23.7% of its students** - the worst percentage decline among major counties, losing nearly 50,000 students.

```r
county_2012 <- enr %>% filter(end_year == 2012, grade_level == "TOTAL") %>%
  group_by(county) %>% summarize(enr_2012 = sum(n_students, na.rm = TRUE), .groups = "drop")
county_2024 <- enr %>% filter(end_year == 2024, grade_level == "TOTAL") %>%
  group_by(county) %>% summarize(enr_2024 = sum(n_students, na.rm = TRUE), .groups = "drop")

county_change <- county_2012 %>%
  inner_join(county_2024, by = "county") %>%
  filter(enr_2012 > 10000) %>%  # Major counties only
  mutate(
    change = enr_2024 - enr_2012,
    pct_change = round((enr_2024 - enr_2012) / enr_2012 * 100, 1)
  ) %>%
  arrange(pct_change)
#> BRONX:       -23.7%
#> SCHENECTADY: -18.7%
#> CHEMUNG:     -17.5%
```

![County changes](https://almartin82.github.io/nyschooldata/articles/district-hooks_files/figure-html/county-change-1.png)

---

### 5. Rochester's Collapse

**Rochester City SD lost 30% of enrollment** (32K to 23K) - the steepest decline among major urban districts.

```r
# Calculate 2012-2024 change by district
dist_2012 <- enr %>% filter(end_year == 2012, grade_level == "TOTAL") %>%
  select(district_name, county, enr_2012 = n_students)
dist_2024 <- enr %>% filter(end_year == 2024, grade_level == "TOTAL") %>%
  select(district_name, enr_2024 = n_students)

change <- dist_2012 %>%
  inner_join(dist_2024, by = "district_name") %>%
  filter(!is.na(enr_2012), !is.na(enr_2024), enr_2012 >= 10000) %>%
  mutate(
    change = enr_2024 - enr_2012,
    pct_change = round((enr_2024 - enr_2012) / enr_2012 * 100, 1)
  )
#> Rochester City SD: -29.8%
#> Buffalo City SD: -20.0%
#> Syracuse City SD: -19.9%
```

![Major district declines](https://almartin82.github.io/nyschooldata/articles/district-hooks_files/figure-html/major-districts-1.png)

---

### 6. NYC's Special Ed Surge

**District 75 grew 40% while nearly every other NYC district shrank.** NYC's citywide special education district is one of very few that gained students.

```r
# Find NYC District 75
nyc_districts <- change %>%
  filter(grepl("NYC", district_name)) %>%
  mutate(
    is_d75 = grepl("DIST 75", district_name)
  ) %>%
  arrange(pct_change)
#> NYC SPEC SCHOOLS - DIST 75: +40.1%
#> NYC GEOG DIST 7: -30.0%
#> NYC GEOG DIST 9: -28.0%
```

![District 75 growth](https://almartin82.github.io/nyschooldata/articles/district-hooks_files/figure-html/district75-1.png)

---

### 7. First Grade Cratering

**Grade 1 enrollment fell 17.4%** - the steepest decline by grade level, reflecting birth rate drops and family out-migration.

```r
grade_totals <- enr %>%
  filter(grade_level %in% c("K", "01", "05", "08", "09", "12")) %>%
  group_by(end_year, grade_level) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop")

g_2012 <- grade_totals %>% filter(end_year == 2012) %>% rename(n_2012 = total)
g_2024 <- grade_totals %>% filter(end_year == 2024) %>% rename(n_2024 = total) %>%
  select(grade_level, n_2024)

grade_change <- g_2012 %>%
  inner_join(g_2024, by = "grade_level") %>%
  mutate(
    pct_change = round((n_2024 - n_2012) / n_2012 * 100, 1),
    grade_label = case_when(
      grade_level == "01" ~ "Grade 1",
      grade_level == "05" ~ "Grade 5",
      grade_level == "08" ~ "Grade 8",
      grade_level == "09" ~ "Grade 9",
      grade_level == "12" ~ "Grade 12",
      grade_level == "K" ~ "Kindergarten"
    )
  )
#> Grade 1: -17.4%
#> Grade 9: -15.4%
#> Grade 5: -14.3%
```

![Grade-level changes](https://almartin82.github.io/nyschooldata/articles/district-hooks_files/figure-html/grade-change-1.png)

---

### 8. Charter Schools' Rising Market Share

**Charter schools now enroll ~181K students (7.5% of total)** across 343 schools, growing even as traditional public school enrollment declines.

```r
# Need school-level data for charter information
enr_schools <- fetch_enr_years(2023:2024, level = "school", tidy = TRUE, use_cache = TRUE)

charter_summary <- enr_schools %>%
  filter(grade_level == "TOTAL", is_school == TRUE) %>%
  group_by(end_year, is_charter) %>%
  summarize(
    total = sum(n_students, na.rm = TRUE),
    n_schools = n(),
    .groups = "drop"
  ) %>%
  mutate(
    type = ifelse(is_charter, "Charter", "Traditional"),
    avg_size = round(total / n_schools)
  )
#> 2024 Charter: 181,334 students across 343 schools
#> 2024 Traditional: 2,307,920 students across 4,406 schools
```

---

### 9. Only One County Grew

**Saratoga County is the only county that GREW (+0.3%).** Suburban counties held steady while urban and rural areas declined sharply.

```r
county_all <- county_2012 %>%
  inner_join(county_2024, by = "county") %>%
  mutate(
    pct_change = round((enr_2024 - enr_2012) / enr_2012 * 100, 1),
    grew = pct_change > 0
  )

# Summary stats
n_grew <- sum(county_all$grew)
n_declined <- sum(!county_all$grew)
#> Counties that grew: 1
#> Counties that declined: 61
#> The one growing county: SARATOGA (+0.3%)
```

---

### 10. The Pre-K Inversion

**NYC Pre-K is now 99% full-day (103K of 104K), while rest of state is only 85% full-day.** This represents a fundamental policy shift in early childhood education.

```r
enr_2024 <- fetch_enr(2024, level = "district", tidy = TRUE, use_cache = TRUE)

pk_comparison <- enr_2024 %>%
  filter(grade_level %in% c("PK_FULL", "PK_HALF")) %>%
  group_by(is_nyc, grade_level) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = grade_level, values_from = total) %>%
  mutate(
    region = ifelse(is_nyc, "NYC", "Rest of NY"),
    total_pk = PK_FULL + PK_HALF,
    pct_full_day = round(PK_FULL / total_pk * 100, 1)
  )
#> NYC: 99.2% full-day Pre-K
#> Rest of NY: 85.1% full-day Pre-K
```

![Pre-K full-day comparison](https://almartin82.github.io/nyschooldata/articles/district-hooks_files/figure-html/prek-fullday-1.png)

---

## Installation

```r
# install.packages("remotes")
remotes::install_github("almartin82/nyschooldata")
```

## Quick Start

### R

```r
library(nyschooldata)
library(dplyr)

# Fetch 2024 data (2023-24 school year)
enr <- fetch_enr(2024, use_cache = TRUE)

# Statewide total
enr %>%
  filter(is_district, grade_level == "TOTAL") %>%
  summarize(total = sum(n_students, na.rm = TRUE))
#> 2,404,319 students
```

### Python

```python
import pynyschooldata as ny

# Fetch 2024 data (2023-24 school year)
enr = ny.fetch_enr(2024)

# Statewide total
total = enr[enr['is_district'] & (enr['grade_level'] == 'TOTAL')]['n_students'].sum()
print(f"{total:,} students")
#> 2,404,319 students

# Get multiple years
enr_multi = ny.fetch_enr_multi([2020, 2021, 2022, 2023, 2024])

# Check available years
years = ny.get_available_years()
print(f"Data available: {years['min_year']}-{years['max_year']}")
#> Data available: 1977-2024
```

---

## Data Notes

### Data Source

All data comes directly from [NYSED Information Reporting Services](https://www.p12.nysed.gov/irs/statistics/enroll-n-staff/home.html). Files are downloaded, cached locally, and standardized into a consistent schema.

### Census Date

Enrollment counts are collected on **BEDS Day** (Basic Educational Data System Day), which falls in early October each year. This is the official enrollment census date for New York State public schools.

### Coverage by Era

| Era | Years | What's Available |
|-----|-------|------------------|
| **Archive I** | 1977-1993 | K-12 enrollment by grade, district & school level |
| **Archive II** | 1994-2011 | + Pre-K, + Gender breakdowns |
| **Modern** | 2012-2021 | + Econ Disadvantaged, ELL, Students w/ Disabilities |
| **Current** | 2022-2024 | Same as Modern, updated file format |

### Suppression Rules

Small cell sizes may be suppressed to protect student privacy and shown as NA in the data.

### Known Caveats

- **Charter schools**: Charter flag requires school-level data (2012+)
- **Historical comparisons**: Pre-K wasn't tracked before 1995; use K-12 totals for long-term trends
- **NYC structure**: NYC has 32 geographic districts + District 75 (special ed) + District 79 (alternative)

### Identifiers

- **BEDS Code**: 12-digit unique school identifier (e.g., `010100010023`)
  - Digits 1-6: District code
  - Digits 7-10: School code
  - Digits 11-12: Check digits
- **District Code**: 6-digit district identifier (e.g., `010100` = Albany City SD)

### Flags

| Flag | Description |
|------|-------------|
| `is_district` | District-level aggregate row |
| `is_school` | Individual school record |
| `is_nyc` | NYC DOE school/district (codes 30xxxx-35xxxx) |
| `is_charter` | Charter school |

---

## Key Functions

### Enrollment Data

| Function | Description |
|----------|-------------|
| `fetch_enr(year)` | Get enrollment for one year |
| `fetch_enr_years(years)` | Get multiple years |
| `fetch_enr_school(beds, year)` | Get specific school |
| `fetch_enr_district(code, year)` | Get specific district |
| `fetch_enr_nyc(year)` | Get NYC schools only |
| `get_available_years()` | Check year range |

### Assessment Data

| Function | Description |
|----------|-------------|
| `fetch_assessment(year)` | Get NY State Tests (ELA, Math, Science) |
| `fetch_assessment_multi(years)` | Get multiple years of assessment data |
| `fetch_district_assessment(year, district_cd)` | Get specific district |
| `get_available_assessment_years()` | Check assessment year range |
| `calculate_proficiency_rates(data)` | Summarize proficiency from tidy data |

**Note:** Assessment data requires [mdbtools](https://github.com/mdbtools/mdbtools) to read NYSED Access databases.

## Assessment Data Quick Start

```r
library(nyschooldata)
library(dplyr)

# Get 2024 ELA assessment data
assess <- fetch_assessment(2024, subject = "ela", use_cache = TRUE)

# Check proficiency by grade
assess |>
  filter(grepl("^ELA[3-8]$", assessment_name),
         subgroup_name == "All Students",
         grepl("New York City", entity_name)) |>
  select(assessment_name, per_prof)
```

See the [NY Assessment Data vignette](https://almartin82.github.io/nyschooldata/articles/newyork-assessment.html) for detailed analysis.

## Documentation

- [10 Surprising Findings](https://almartin82.github.io/nyschooldata/articles/district-hooks.html) - Full analysis with charts
- [NY Assessment Data](https://almartin82.github.io/nyschooldata/articles/newyork-assessment.html) - Assessment analysis
- [Getting Started Guide](https://almartin82.github.io/nyschooldata/articles/quickstart.html)
- [Data Quality QA](https://almartin82.github.io/nyschooldata/articles/data-quality-qa.html)
- [API Reference](https://almartin82.github.io/nyschooldata/reference/)

## Author

[Andy Martin](https://github.com/almartin82) (almartin@gmail.com)
