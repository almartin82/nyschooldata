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
    'yr2012' = 'http://data.nysed.gov/files/reportcards/archive/2011-12/SRC2012.zip',
    'yr2011' = 'http://data.nysed.gov/files/reportcards/archive/2010-11/SRC2011.zip',
    'yr2010' = 'http://data.nysed.gov/files/reportcards/archive/2009-10/SRC2010.zip',
    'yr2009' = 'http://data.nysed.gov/files/reportcards/archive/2008-09/SRC2009.zip',
    'yr2008' = 'http://data.nysed.gov/files/reportcards/archive/2007-08/SRC2008.zip',
    'yr2007' = 'http://data.nysed.gov/files/reportcards/archive/2006-07/SRC2007.zip',
    'yr2006' = 'http://data.nysed.gov/files/reportcards/archive/2005-06/SRC2006.zip'
  )
  rc_url <- rc_urls[[paste0('yr', end_year)]]
  local_files <- zip_to_temp(rc_url)
  rc <- extract_mdb(local_files)

  rc
}


#' Reads in all the raw report card databases
#'
#' @return list of report card db lists
#' @export

get_all_raw_rc <- function() {

  years <- c(2006:2015)
  raw_rc <- list()
  for(i in seq_along(years)) {
    print(years[i])
    raw_rc[[i]] <- get_raw_rc_db(years[i])
  }

  raw_rc
}
