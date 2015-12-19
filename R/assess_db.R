

#' Read in the raw assessment database from the NYSED website
#'
#' @param end_year
#'
#' @return
#' @export

get_raw_assess_db <- function(end_year) {
  #build url
  assess_urls <- list(
    'yr2015' = 'https://data.nysed.gov/files/assessment/3-8-2014-15.zip',
    'yr2014' = 'https://data.nysed.gov/files/assessment/3-8-2013-14.zip'
  )
  assess_url <- assess_urls[[paste0('yr', end_year)]]

  #download and unzip
  tname <- tempfile(pattern = "enr", tmpdir = tempdir(), fileext = ".zip")
  tdir <- tempdir()
  downloader::download(assess_url, dest = tname, mode = "wb")
  utils::unzip(tname, exdir = tdir)

  #read file
  assess_files <- utils::unzip(tname, exdir = ".", list = TRUE)
  tab_file <- assess_files[grepl('.tab', assess_files$Name, fixed = TRUE), ]$Name

  assess <- read.table(
    file = paste0(tdir, '/', tab_file),
    sep = "\t", header = TRUE,  quote = "\"", comment.char = ""
  )

}


