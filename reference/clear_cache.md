# Clear the nyschooldata cache

Removes all cached data files.

## Usage

``` r
clear_cache(years = NULL, data_type = NULL)

clear_enr_cache(years = NULL, data_type = NULL)
```

## Arguments

- years:

  Optional vector of years to clear. If NULL, clears all.

- data_type:

  Type of cache to clear: "enr" (enrollment), "grad" (graduation),
  "assess" (assessment), or NULL (all).

## Value

Invisibly returns the number of files removed

## Examples

``` r
if (FALSE) { # \dontrun{
# Clear all cached data
clear_cache()

# Clear only 2024 data
clear_cache(2024)

# Clear only graduation cache
clear_cache(data_type = "grad")

# Clear only assessment cache
clear_cache(data_type = "assess")
} # }
```
