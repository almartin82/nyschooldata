# New York Graduation Rate Research

**Date:** 2026-01-08
**Status:** Implementation Complete
**Data Source:** NYSED Data Site - Graduation Rate Database

## Overview

New York State Education Department (NYSED) provides comprehensive graduation rate data through their public data portal. The data includes graduation rates, diploma types, and post-secondary outcomes for 4-year, 5-year, and 6-year cohorts.

**Years Available:** 2005-2024 (20 years)
**Format:** ZIP files containing CSV (2015-2024) or Access database files (2005-2014)
**Update Frequency:** Annual (typically January)

## Data Source

### URL Pattern

| Year Range | URL Pattern | File Type |
|------------|-------------|-----------|
| 2019-2024 | `https://data.nysed.gov/files/gradrate/YY-YY/gradrate.zip` | CSV + .mdb |
| 2015-2018 | `https://data.nysed.gov/files/gradrate/YY-YY/gradrate_YYYY.zip` | CSV + .xlsx + .mdb |
| 2005-2014 | `https://data.nysed.gov/files/gradrate/gradrate_YYYY.zip` | .xlsx + .mdb |

**Base URL:** `https://data.nysed.gov/downloads.php` (main downloads page)

### Verified File URLs

All files return HTTP 200 OK:

```r
# Recent years (CSV available)
2023-24: https://data.nysed.gov/files/gradrate/23-24/gradrate.zip
2022-23: https://data.nysed.gov/files/gradrate/22-23/gradrate.zip
2021-22: https://data.nysed.gov/files/gradrate/21-22/gradrate.zip
2020-21: https://data.nysed.gov/files/gradrate/20-21/gradrate.zip
2019-20: https://data.nysed.gov/files/gradrate/19-20/gradrate.zip
2018-19: https://data.nysed.gov/files/gradrate/18-19/gradrate_2018.zip
2017-18: https://data.nysed.gov/files/gradrate/17-18/gradrate_2018.zip
2016-17: https://data.nysed.gov/files/gradrate/16-17/gradrate_2017.zip
2015-16: https://data.nysed.gov/files/gradrate/15-16/gradrate_2016.zip
2014-15: https://data.nysed.gov/files/gradrate/14-15/gradrate_2015.zip

# Older years (Excel + Access only)
2013-14: https://data.nysed.gov/files/gradrate/gradrate_2014.zip
2012-13: https://data.nysed.gov/files/gradrate/gradrate_2013.zip
...
```

## File Contents

### Recent Years (2015-2024) ZIP Contents

For 2018-19 and newer:
```
gradrate.zip
├── GRAD_RATE_AND_OUTCOMES_20YY.csv (58 MB) - Primary data file
├── GRAD_RATE_AND_OUTCOMES_20YY.mdb (132 MB) - Access database
├── GRAD_RATE_AND_OUTCOMES_20YY.accdb (132 MB) - Access 2007+ format
└── [PDF documentation files]
```

For 2015-2018:
```
gradrate_20YY.zip
├── GRAD_RATE_AND_OUTCOMES_20YY.xlsx - Excel format
├── GRAD_RATE_AND_OUTCOMES_20YY.mdb - Access database
└── [PDF documentation files]
```

**Note:** Our implementation prefers CSV when available, falls back to Excel for 2015-2018.

## Database Schema (2023-24)

### Table: GRAD_RATE_AND_OUTCOMES_2024

| Column | Type | Description |
|--------|------|-------------|
| `report_school_year` | Text | e.g., "2023-24" |
| `aggregation_index` | Integer | 0=State, 1=NRC, 2=County, 3=District, 4=School |
| `aggregation_type` | Text | "Statewide", "County", "District", "School", "Need/Resource Category" |
| `aggregation_code` | Text | 12-digit BEDS code |
| `aggregation_name` | Text | Entity name |
| `county_code` | Text | 2-digit county code |
| `county_name` | Text | County name |
| `nrc_code` | Text | Need/Resource Category code (1-6) |
| `nrc_desc` | Text | NRC description |
| `lea_beds` | Text | District BEDS code (12 digits, ends in 0000) |
| `lea_name` | Text | District name |
| `nyc_ind` | Text | NYC indicator ("0" or "1") |
| `boces_code` | Text | BOCES code |
| `boces_name` | Text | BOCES name |
| `membership_code` | Integer | Cohort type (see codes below) |
| `membership_desc` | Text | Cohort description |
| `subgroup_code` | Text | 3-digit subgroup code |
| `subgroup_name` | Text | Subgroup name |
| `enroll_cnt` | Text | Cohort enrollment count |
| `grad_cnt` | Text | Graduate count |
| `grad_pct` | Text | Graduation rate % (e.g., "84.3%") |
| `local_cnt` | Text | Local diploma count |
| `local_pct` | Text | Local diploma % |
| `reg_cnt` | Text | Regents diploma count |
| `reg_pct` | Text | Regents diploma % |
| `reg_adv_cnt` | Text | Advanced Regents diploma count |
| `reg_adv_pct` | Text | Advanced Regents diploma % |
| `non_diploma_credential_cnt` | Text | Non-diploma credential count |
| `non_diploma_credential_pct` | Text | Non-diploma credential % |
| `still_enr_cnt` | Text | Still enrolled count |
| `still_enr_pct` | Text | Still enrolled % |
| `ged_cnt` | Text | GED count |
| `ged_pct` | Text | GED % |
| `dropout_cnt` | Text | Dropout count |
| `dropout_pct` | Text | Dropout % |

**Total Columns:** 35 columns

## Aggregation Types

| Index | Type | Description |
|-------|------|-------------|
| 0 | Statewide | State totals |
| 1 | Need/Resource Category | NRC groupings (NYC, other cities, suburbs, rural) |
| 2 | County | County-level totals |
| 3 | District | District-level totals |
| 4 | School | Individual school totals |

## Membership Codes (Cohort Types)

| Code | Description | Example for 2023-24 |
|------|-------------|---------------------|
| 6 | 6-Year Outcome (June) | 2018 cohort graduating by 2024 |
| 8 | 5-Year Outcome (June) | 2019 cohort graduating by 2024 |
| 9 | 4-Year Outcome (June) | 2020 cohort graduating by 2024 |
| 10 | 5-Year Outcome (August) | 2019 cohort graduating by Aug 2024 |
| 11 | 4-Year Outcome (August) | 2020 cohort graduating by Aug 2024 |
| 18 | 6-Year Outcome (August) | 2018 cohort graduating by Aug 2024 |

**Primary metric:** 4-Year June Outcome (code 9) - standard federal graduation rate

## Subgroup Codes

| Code | Subgroup Name |
|------|---------------|
| 01 | All Students |
| 02 | Female |
| 03 | Male |
| 04 | American Indian or Alaska Native |
| 05 | Black or African American |
| 06 | Hispanic or Latino |
| 07 | Asian or Native Hawaiian/Other Pacific Islander |
| 08 | White |
| 09 | Multiracial |
| 10 | General Education Students |
| 11 | Students with Disabilities |
| 12 | Non-English Language Learner |
| 13 | English Language Learner |
| 15 | Economically Disadvantaged |
| 16 | Not Economically Disadvantaged |
| 17 | Migrant |
| 18 | Not Migrant |
| 20 | Homeless |
| 21 | Not Homeless |
| 22 | In Foster Care |
| 23 | Not in Foster Care |
| 24 | Parent in Armed Forces |
| 25 | Parent Not in Armed Forces |
| 29 | Nonbinary (new in recent years) |

## ID System

### BEDS Codes (Basic Education Data System)

**Format:** 12-digit codes

- **School BEDS:** `XXXXXX` + `XX` + `XXXX`
  - First 6 digits: District code
  - Digits 7-8: School type
  - Digits 9-12: School number
  - Example: `010100010034` (Albany High School)

- **District BEDS:** `XXXXXX` + `XX` + `0000`
  - Ends in `0000`
  - Example: `010100010000` (Albany City School District)

- **County Code:** 2 digits
  - Example: `01` (Albany County)

- **NRC Code:** 1 digit (1-6)
  - 1: NYC
  - 2-6: Other NRC categories

**All BEDS codes must be character type to preserve leading zeros.**

## Data Quality Notes

### Known Issues

1. **Data stored as text:** All counts and percentages are text type, require conversion
2. **Percentage formatting:** Percentages include "%" character (e.g., "84.3%")
3. **Suppressed values:** Counts < 5 are suppressed (blank or special characters)
4. **Division by zero:** Some percentage columns may show "/0" or "#DIV/0!"
5. **Large files:** ZIP files range 6-60 MB, CSV files 45-60 MB

### Data Validation

**State-level 4-year graduation rates (All Students):**
- 2024: 84.4% (cohort: 199,129)
- 2023: 87.3% (cohort: 198,492)
- 2022: 87.0% (cohort: 195,471)

**Expected ranges:**
- State graduation rate: 80-90%
- State cohort size: 190,000-220,000
- NYC graduation rate: 75-88%
- NYC cohort size: 65,000-75,000

## Implementation Strategy

### File Format Handling

1. **2015-2024:** Extract and read CSV file from ZIP
2. **2005-2014:** Extract and read Excel file from ZIP
3. **Cache aggressively:** Large files (6-60 MB), cache after extraction

### Data Processing Steps

1. **Download ZIP** from NYSED data site
2. **Extract** CSV or Excel file
3. **Parse** with readr (CSV) or readxl (Excel)
4. **Convert** text percentages to numeric
5. **Convert** text counts to numeric
6. **Handle** suppressed values (blank → NA)
7. **Filter** to 4-year June cohort by default
8. **Standardize** subgroup names
9. **Add** aggregation level flags

### 14-Column Standard Schema

After processing, output includes:

```
end_year, type, district_id, district_name, school_id, school_name,
subgroup, metric, grad_rate, cohort_count, graduate_count,
is_state, is_district, is_school
```

**Metric types:** "grad_rate" (primary), plus extended metrics for diploma types

## Test Values for Validation

### 2024 State Totals (4-year June cohort, All Students)

```r
# Expected values from raw CSV
end_year: 2024
cohort_count: 199129
graduate_count: 168034
grad_rate: 0.844 (84.4%)
```

### 2024 NYC (NRC code 1, All Students)

```r
cohort_count: 68882
graduate_count: 55435
grad_rate: 0.805 (80.5%)
```

### 2024 Albany High School (BEDS 010100010034, All Students)

```r
cohort_count: 714
graduate_count: 504
grad_rate: 0.706 (70.6%)
```

## Additional Resources

- **Business Rules:** https://data.nysed.gov/businessrules.php?type=gradrate
- **Downloads:** https://data.nysed.gov/downloads.php
- **Historical Archive:** https://www.p12.nysed.gov/irs/cohort/archive-grad.html
- **SIRS Manual:** http://www.p12.nysed.gov/irs/sirs/home.html

## Implementation Notes

### Complexity: MEDIUM-HIGH

**Challenges:**
1. Large file sizes (6-60 MB ZIP, 45-60 MB CSV)
2. Text-to-numeric conversion required
3. Multiple cohort types (need to filter appropriately)
4. Multiple outcome types (graduation, dropout, still enrolled, GED, etc.)
5. Suppressed data handling

**Advantages:**
1. Public URL, no authentication
2. CSV available for recent years
3. Consistent schema 2015-2024
4. Comprehensive documentation
5. 20 years of historical data

### Dependencies

No new dependencies required beyond existing package imports:
- `httr` - HTTP downloads
- `readr` - CSV parsing
- `readxl` - Excel parsing (older years)
- `dplyr` - Data manipulation
- `tidyr` - Pivoting

### Future Enhancements

- Add extended metrics (local diploma, regents diploma, dropout rate, etc.)
- Support for 5-year and 6-year cohort rates
- NRC-level aggregation
- County-level aggregation
