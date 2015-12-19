#' Read in the raw report card database from the NYSED website
#'
#' @param end_year 4 digit integer representing the end of the desired school
#' year.  eg, 2014-15 is 2015.
#'
#' @return list of data frames for all the tables in the report card db.
#' @export

get_raw_rc_db <- function(end_year) {
  #build url
  rc_urls <- list(
    'yr2015' = 'http://data.nysed.gov/files/reportcards/SRC2015.zip',
    'yr2014' = 'http://data.nysed.gov/files/reportcards/SRC2014.zip',
    'yr2013' = 'http://data.nysed.gov/files/reportcards/SRC2013.zip',
    'yr2012' = 'http://reportcards.nysed.gov/zip/SRC2012.zip',
    'yr2011' = 'http://reportcards.nysed.gov/zip/SRC2011.zip',
    'yr2010' = 'http://reportcards.nysed.gov/zip/SRC2010.zip',
    'yr2009' = 'http://reportcards.nysed.gov/zip/SRC2009.zip',
    'yr2008' = 'http://reportcards.nysed.gov/zip/SRC2008.zip',
    'yr2007' = 'http://reportcards.nysed.gov/zip/SRC2007.zip',
    'yr2006' = 'http://reportcards.nysed.gov/zip/SRC2006.zip'
  )
  rc_url <- rc_urls[[paste0('yr', end_year)]]
  local_files <- zip_to_temp(rc_url)
}
