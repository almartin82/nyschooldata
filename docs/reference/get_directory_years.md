# Get available years for directory data

Returns information about directory data availability. NYSED SEDREF
COGNOS reports only provide current data (refreshed nightly).

## Usage

``` r
get_directory_years()
```

## Value

A list with min_year, max_year, and description

## Examples

``` r
get_directory_years()
#> $min_year
#> [1] 2025
#> 
#> $max_year
#> [1] 2026
#> 
#> $description
#> [1] "School directory data is available from NYSED's SEDREF COGNOS reports. Only current year data is available (reports are refreshed nightly). Historical directory data is not available through this system. For archival data, contact NYSED directly."
#> 
#> $data_source
#> [1] "NYSED SEDREF COGNOS Public Reports Portal"
#> 
#> $url
#> [1] "https://eservices.nysed.gov/sedreports/"
#> 
#> $refresh_frequency
#> [1] "Nightly"
#> 
```
