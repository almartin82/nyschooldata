# Clear the nyschooldata cache

Removes all cached data files.

## Usage

``` r
clear_enr_cache(years = NULL)
```

## Arguments

- years:

  Optional vector of years to clear. If NULL, clears all.

## Value

Invisibly returns the number of files removed

## Examples

``` r
if (FALSE) { # \dontrun{
# Clear all cached data
clear_enr_cache()

# Clear only 2024 data
clear_enr_cache(2024)
} # }
```
