#' Read in the raw assessment database from the NYSED website
#'
#' @param test_year 4 digit integer representing the end of the desired school
#' year.  eg, 2014-15 is 2015.
#'
#' @return data frame with assessment results, by school
#' @export

get_raw_assess_db <- function(test_year) {
  #build url
  assess_urls <- list(
    'yr2016' = 'http://data.nysed.gov/files/assessment/15-16/3-8-2015-16.zip',
    'yr2015' = 'http://data.nysed.gov/files/assessment/14-15/3-8-2014-15.zip',
    'yr2014' = 'http://data.nysed.gov/files/assessment/13-14/3-8-2013-14.zip',
    'yr2013' = 'http://data.nysed.gov/files/assessment/13-14/3-8-2013-14.zip'
  )
  assess_url <- assess_urls[[paste0('yr', test_year)]]
  local_files <- zip_to_temp(assess_url)
  assess <- extract_mdb(local_files)

  #2014 data file included both the 2013 data and the 2014 data. process.
  if (test_year == 2013) {
    out <- assess$`3-8_ELA_AND_MATH_REPORT_FOR_RELEASE_2013`
  } else if (test_year == 2014) {
    out <- assess$`3-8_ELA_AND_MATH_REPORT_FOR_RELEASE_2014`
  } else if (test_year >= 2015) {
    out <- assess
  }

  return(out)
}


#' Clean an assessment database file
#'
#' @param df data.frame (output of `get_raw_assess_db`)
#' @param test_year testing year
#' @param suppressed_as_NA should records supressed for small n
#' (recorded as '-' in the raw file) be converted to NA?  default is TRUE
#' @param cohort_kind should we name cohorts by their college entry
#' or college graduation year?  default is college_entry.
#'
#' @return tbl_df
#' @export

clean_assess_db <- function(
  df, test_year, suppressed_as_NA = TRUE, cohort_kind = 'college_entry') {

  df <- janitor::clean_names(df)

  #bad names on 2016 file
  if (test_year == 2016) {
    df <- df %>%
      dplyr::rename(
        school_year = sy_end_date
      )
  }

  #http://stackoverflow.com/a/24070958/561698
  clear_labels <- function(x) {
    if (is.list(x)) {
      for(i in 1 : length(x)) class(x[[i]]) <- setdiff(class(x[[i]]), 'labelled')
      for(i in 1 : length(x)) attr(x[[i]],"label") <- NULL
    }
    else {
      class(x) <- setdiff(class(x), "labelled")
      attr(x, "label") <- NULL
    }
    return(x)
  }

  df <- clear_labels(df)

  #suppressed to NA?
  if (suppressed_as_NA) {
    contains_suppression_mark <- function(vector) '-' %in% vector
    dash_to_na <- function(x) ifelse(x == '-', NA, x)

    df <- df %>%
      purrr::dmap_if(contains_suppression_mark, dash_to_na)

    #make previously suppressed cols numeric
    cols_to_fix <- c(
      "total_tested", "l1_count", "l1_pct", "l2_count", "l2_pct",
      "l3_count", "l3_pct", "l4_count", "l4_pct", "l2_l4_pct",
      "l3_l4_pct", "mean_scale_score"
    )

    percent_and_numeric <- function(vector) {
      vector <- gsub('%', '', vector, fixed = TRUE)
      as.numeric(vector)
    }
    df <- df %>% dplyr::mutate_at(cols_to_fix, percent_and_numeric)

  } else {
    stop('no other method for handling NAs currently implemented')
  }

  #make additional perf level counts
  df <- df %>%
    dplyr::mutate(
      l2_l4_count = l2_count + l3_count + l4_count,
      l3_l4_count = l3_count + l4_count
    )

  #break out columns from combined data
  df <- df %>%
    dplyr::mutate(
      school_year = lubridate::mdy(school_year),
      test_year = lubridate::year(school_year),
      start_year = test_year - 1
    ) %>%
    tidyr::separate(
      col = item_desc,
      into = c('discard', 'test_grade', 'test_subject'),
      sep = ' ',
      remove = FALSE,
      convert = TRUE
    ) %>%
    dplyr::select(-discard)

  #calculate cohort
  df <- df %>%
    dplyr::mutate(
      cohort_numeric = NYSEDtools::calculate_cohort(
        test_grade, start_year, cohort_kind
      )
    )

  #make unique_id
  df <- df %>%
    dplyr::mutate(
      unique_id = paste(
        as.character(bedscode), item_desc, subgroup_code, sep = '_'
      )
    )


  if (test_year == 2015) {
    df <- df %>% dplyr::select(-sum_of_scale_score)
  }

  df
}


#' fetch NY State assessment db
#'
#' @description wrapper around get_raw_assess_db and clean_assess_db
#' @inheritParams get_raw_assess_db
#'
#' @return clean data frame with assessment data
#' @export

fetch_assess_db <- function(test_year) {
  raw <- get_raw_assess_db(test_year)
  clean <- clean_assess_db(raw, test_year)

  clean
}
