

#' Read in the raw assessment database from the NYSED website
#'
#' @param end_year
#'
#' @return data frame with assessment results, by school
#' @export

get_raw_assess_db <- function(end_year) {
  #build url
  assess_urls <- list(
    'yr2015' = 'http://data.nysed.gov/files/assessment/3-8-2014-15.zip',
    'yr2014' = 'http://data.nysed.gov/files/assessment/3-8-2013-14.zip',
    'yr2013' = 'http://data.nysed.gov/files/assessment/3-8-2013-14.zip'
  )
  assess_url <- assess_urls[[paste0('yr', end_year)]]

  #download and unzip
  tname <- tempfile(pattern = "enr", tmpdir = tempdir(), fileext = ".zip")
  tdir <- tempdir()
  downloader::download(assess_url, dest = tname, mode = "wb")
  utils::unzip(tname, exdir = tdir)

  #read file
  assess_files <- utils::unzip(tname, exdir = ".", list = TRUE)
  mdb_file <- assess_files[grepl('.mdb', assess_files$Name, fixed = TRUE), ]$Name
  mdb_file <- file.path(tdir, mdb_file)
  file.rename(mdb_file, file.path(tdir, 'assess_data.mdb'))

  assess <- Hmisc::mdb.get(file = file.path(tdir, 'assess_data.mdb'))

  if (end_year == 2013) {
    out <- assess$`3-8_ELA_AND_MATH_REPORT_FOR_RELEASE_2013`
  } else if (end_year == 2014) {
    out <- assess$`3-8_ELA_AND_MATH_REPORT_FOR_RELEASE_2014`
  } else if (end_year == 2015) {
    out <- assess
  }

  return(out)
}
