# Parse entity codes to identify entity type

NYSED entity codes follow patterns that indicate the type of entity:

- State: "000000000000" or starts with "0000000000"

- County: "000XXX000000" (XXX = county code)

- Need/Resource Category: "0000000000XX"

- District: "XXXXXXXXXXXX" (12 digits, ends in 0000)

- School: "XXXXXXXXXXXX" (12 digits, doesn't end in 0000)

## Usage

``` r
parse_entity_codes(df)
```

## Arguments

- df:

  Data frame with entity_cd column

## Value

Data frame with parsed entity information
