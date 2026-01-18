# Clear graduation rate cache

Removes all cached graduation rate data files from both the

## Usage

``` r
clear_grad_cache(years = NULL, clear_data_cache = TRUE)
```

## Arguments

- years:

  Optional vector of years to clear. If NULL, clears all years.

- clear_data_cache:

  If TRUE (default), also clears /data-cache CSV files.

## Value

Invisibly returns the number of files removed

## Examples

``` r
if (FALSE) { # \dontrun{
# Clear all graduation cache (both processed and data-cache)
clear_grad_cache()

# Clear only 2024 data
clear_grad_cache(2024)

# Clear multiple years
clear_grad_cache(2020:2024)

# Clear only processed cache, keep /data-cache
clear_grad_cache(clear_data_cache = FALSE)
} # }
```
