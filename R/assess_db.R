#' Read in the raw assessment database from the NYSED website
#'
#' @param end_year 4 digit integer representing the end of the desired school
#' year.  eg, 2014-15 is 2015.
#'
#' @return data frame with assessment results, by school
#' @export

get_raw_assess_db <- function(end_year) {
  #build url
  assess_urls <- list(
    'yr2016' = 'http://data.nysed.gov/files/assessment/15-16/3-8-2015-16.zip',
    'yr2015' = 'http://data.nysed.gov/files/assessment/14-15/3-8-2014-15.zip',
    'yr2014' = 'http://data.nysed.gov/files/assessment/13-14/3-8-2013-14.zip',
    'yr2013' = 'http://data.nysed.gov/files/assessment/13-14/3-8-2013-14.zip'
  )
  assess_url <- assess_urls[[paste0('yr', end_year)]]
  local_files <- zip_to_temp(assess_url)
  assess <- extract_mdb(local_files)

  #2014 data file included both the 2013 data and the 2014 data. process.
  if (end_year == 2013) {
    out <- assess$`3-8_ELA_AND_MATH_REPORT_FOR_RELEASE_2013`
  } else if (end_year == 2014) {
    out <- assess$`3-8_ELA_AND_MATH_REPORT_FOR_RELEASE_2014`
  } else if (end_year >= 2015) {
    out <- assess
  }

  return(out)
}
