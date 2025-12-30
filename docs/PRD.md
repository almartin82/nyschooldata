# Product Requirements Document: nyschooldata

## Overview

`nyschooldata` is an R package for fetching and processing school data from the New York State Education Department (NYSED). It provides a standardized interface for downloading enrollment, demographics, and other school-level data, transforming it into tidy formats suitable for analysis.

## Problem Statement

New York State education data is distributed across multiple sources with varying formats:
- NYSED data portal (data.nysed.gov)
- NYC-specific data from InfoHub
- Historical archives with inconsistent schemas

Researchers and analysts need a reliable, reproducible way to access this data without manually navigating data portals and reconciling format changes.

## Regulatory Context: NYCRR 155.1

**This is a critical forcing function for the package.**

New York Codes, Rules and Regulations (NYCRR) Section 155.1 establishes comprehensive requirements for school facility planning and educational adequacy. Districts must:
- Submit long-range facility plans (5-year minimum)
- Project enrollment by grade level
- Justify capital expenditures based on demographic trends
- Report on facility utilization rates

This regulation creates strong, recurring demand for:
- Historical enrollment data by grade
- Demographic trend analysis
- Cohort survival calculations
- Enrollment forecasting

The package directly supports NYCRR 155.1 compliance by providing programmatic access to the underlying data.

## Data Sources

### Primary: NYSED Data Site
- **URL**: https://data.nysed.gov/
- **Data types**: Enrollment, demographics, assessment results, graduation rates
- **Update frequency**: Annual (typically fall)
- **Format**: Excel files, CSV downloads

### Secondary: NYC InfoHub
- **URL**: https://infohub.nyced.org/
- **Scope**: NYC DOE schools only
- **Data types**: Detailed demographic breakdowns, school-level metrics
- **Note**: May have more granular data than statewide NYSED files

## Identifier System: BEDS Codes

New York uses the Basic Educational Data System (BEDS) code as the primary school identifier.

### Structure (12 digits)
```
DDDDDDSSSSCC
│     │   └── Check digits (2)
│     └────── School code (4)
└──────────── District code (6)
```

### Key characteristics:
- **District codes**: 6 digits, unique statewide
- **School codes**: 4 digits, unique within district
- **NYC district code**: 310000 (NYC DOE is a single district)
- **Total districts**: ~1,087
- **Total schools**: ~4,500+ public schools

### NYC Special Handling

NYC presents unique challenges:
- Single district (NYC DOE, code 310000) contains ~1,800 schools
- 32 Community School Districts (CSDs) for administrative purposes
- CSDs are NOT separate BEDS districts
- Borough-level aggregations may be useful for analysis
- InfoHub may provide CSD-level breakdowns not in statewide files

## Core Features

### Phase 1: Enrollment Data
1. `fetch_enr(end_year)` - Download and process enrollment data
2. `get_raw_enr(end_year)` - Download raw data files
3. `process_enr(df)` - Standardize column names and types
4. `tidy_enr(df)` - Transform to long format with subgroup column
5. `cache_*()` - Local caching functions

### Phase 2: Demographics & Subgroups
- Race/ethnicity breakdowns
- English Language Learners (ELL)
- Students with Disabilities (SWD)
- Economically Disadvantaged
- Homeless/Foster care

### Phase 3: Assessment Data (Future)
- NYS Regents exams
- 3-8 ELA/Math assessments
- Graduation rates

## Data Schema

### Tidy enrollment output
| Column | Type | Description |
|--------|------|-------------|
| end_year | integer | School year end (2024 = 2023-24) |
| beds_code | character | 12-digit BEDS identifier |
| district_code | character | 6-digit district portion |
| school_code | character | 4-digit school portion |
| district_name | character | District name |
| school_name | character | School name (NA for district rows) |
| grade_level | character | PK, K, 01-12, or TOTAL |
| subgroup | character | Demographic subgroup or "total_enrollment" |
| n_students | numeric | Student count |
| pct | numeric | Percentage of total (0-1) |
| is_state | logical | Statewide aggregate row |
| is_district | logical | District aggregate row |
| is_school | logical | School-level row |
| is_charter | logical | Charter school flag |
| is_nyc | logical | NYC DOE school flag |

## Technical Requirements

### Dependencies
- dplyr, tidyr, purrr (data manipulation)
- readxl, readr (file parsing)
- downloader (HTTP downloads)
- rappdirs (cache directory management)

### Caching Strategy
- Cache raw downloads to avoid repeated HTTP requests
- Cache processed data for fast subsequent access
- User-configurable cache location via rappdirs
- `use_cache = FALSE` parameter to force refresh

### Error Handling
- Graceful handling of missing years
- Clear messages when data is unavailable
- Validation of BEDS code formats

## Success Metrics

1. **Coverage**: Support enrollment data from 2010-present
2. **Accuracy**: Match official NYSED totals within rounding tolerance
3. **Performance**: Full state download + process in < 60 seconds
4. **Reliability**: Automated tests catch data format changes

## Open Questions

1. How far back does consistent NYSED data go?
2. Are there API endpoints or only file downloads?
3. What is the best approach for NYC CSD-level data?
4. How to handle charter school authorizer information?

## References

- NYSED Data Site: https://data.nysed.gov/
- NYC InfoHub: https://infohub.nyced.org/
- NYCRR 155.1: https://www.p12.nysed.gov/facplan/laws_regs.html
- BEDS Code Documentation: https://www.p12.nysed.gov/irs/beds/
