# Build NYSED Report Card Database URL

Constructs the download URL based on year. URL patterns changed over
time:

- 2018+: /files/essa/YY-YY/SRCYYYY.zip

- 2014-2017: /files/reportcards/YY-YY/SRCYYYY.zip

## Usage

``` r
build_src_url(end_year)
```

## Arguments

- end_year:

  School year end

## Value

Full download URL
