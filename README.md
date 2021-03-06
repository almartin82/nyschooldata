# nyschooldata
a simple interface for accessing [NYSED data](https://data.nysed.gov/index.php) in R

## Installation

nyschooldata is not on CRAN.  Install the development version from GitHub:

```{r, eval = FALSE}
install.packages("devtools")
library(devtools)
devtools::install_github("almartin82/nyschooldata")
```

nyschooldata depends on some packages that are also only on GitHub.  If RStudio doesn't do it automatically, install these packages:

```{r, eval = FALSE}
library(devtools)
devtools::install_github("almartin82/NYSEDtools")
```

## Contributing

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

Contributions are welcome!

You can:

- submit suggestions and bug-reports at: https://github.com/almartin82/nyschooldata/issues
- send a pull request on: https://github.com/almartin82/nyschooldata
- compose a friendly e-mail to almartin@gmail.com
