# Extract district ID from school data

NY BEDS codes: 12-digit format

- First 6 digits: District code

- Last 6 digits: School code (000000 for districts themselves)

## Usage

``` r
extract_district_id(school_ids, raw)
```

## Arguments

- school_ids:

  Vector of school BEDS codes

- raw:

  Raw data frame (for fallback)

## Value

District BEDS codes
