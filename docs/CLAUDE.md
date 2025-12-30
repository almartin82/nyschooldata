# Claude Code Instructions for nyschooldata

## Commit and PR Guidelines

- Do NOT include “Generated with Claude Code” in commit messages
- Do NOT include “Co-Authored-By: Claude” in commit messages
- Do NOT mention Claude or AI assistance in PR descriptions
- Keep commit messages clean and professional

## Project Context

This is an R package for fetching and processing New York school
enrollment data from NYSED (New York State Education Department).

### Key Files

- `R/fetch_enrollment.R` - Main
  [`fetch_enr()`](https://almartin82.github.io/nyschooldata/reference/fetch_enr.md)
  function and convenience wrappers
- `R/get_raw_enrollment.R` - Downloads raw data from NYSED
- `R/process_enrollment.R` - Transforms raw data to standard schema
- `R/tidy_enrollment.R` - Converts to long/tidy format
- `R/cache.R` - Local caching layer
- `R/utils.R` - Utility functions (school year labels, BEDS code
  helpers)

### Key Data Concepts

- BEDS codes: 12-digit Basic Educational Data System identifiers
- ~1,087 school districts in New York
- NYC is a special case: single district (NYC DOE) with ~1,800 schools

### Data Sources

- Primary: <https://data.nysed.gov/>
- IRS Public School Enrollment data files
- NYC-specific data may come from InfoHub

### Related Package

This package follows patterns from
[ilschooldata](https://github.com/almartin82/ilschooldata) and
[njschooldata](https://github.com/almartin82/njschooldata).
