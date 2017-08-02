#' Read in the raw assessment database from the NYSED website
#'
#' @param test_year 4 digit integer representing the end of the desired school
#' year.  eg, 2014-15 is 2015.
#' @param verbose logical, print status updates to the console? default is TRUE
#'
#' @return data frame with assessment results, by school
#' @export

get_raw_assess_db <- function(test_year, verbose = TRUE) {
  #build url
  assess_urls <- list(
    'yr2016' = 'http://data.nysed.gov/files/assessment/15-16/3-8-2015-16.zip',
    'yr2015' = 'http://data.nysed.gov/files/assessment/14-15/3-8-2014-15.zip',
    'yr2014' = 'http://data.nysed.gov/files/assessment/13-14/3-8-2013-14.zip',
    'yr2013' = 'http://data.nysed.gov/files/assessment/13-14/3-8-2013-14.zip'
  )
  assess_url <- assess_urls[[paste0('yr', test_year)]]
  if (verbose) cat('Downloading assessment file from data.nysed.gov\n')
  local_files <- zip_to_temp(assess_url)
  if (verbose) cat('Reading assessment database and converting to data.frame\n')
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
#' @param verbose logical, print status updates to the console?
#'
#' @return tbl_df
#' @export

clean_assess_db <- function(
  df,
  test_year,
  suppressed_as_NA = TRUE,
  cohort_kind = 'college_entry',
  verbose = TRUE
) {

  if (verbose) cat('Cleaning names of assessment data.frame\n')
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
    if (verbose) cat('Converting suppression flags to NA\n')
    contains_suppression_mark <- function(vector) '-' %in% vector
    dash_to_na <- function(x) ifelse(x == '-', NA, x)

    df <- df %>%
      purrrlyr::dmap_if(contains_suppression_mark, dash_to_na)

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
    if (verbose) cat('Correcting data type for numeric columns\n')
    df <- df %>% dplyr::mutate_at(cols_to_fix, percent_and_numeric)

  } else {
    stop('no other method for handling NAs currently implemented')
  }

  #make additional perf level counts
  if (verbose) cat('Creating additional detailed perf bin counts\n')

  df <- df %>%
    dplyr::mutate(
      l2_l4_count = l2_count + l3_count + l4_count,
      l3_l4_count = l3_count + l4_count
    )

  #break out columns from combined data
  if (verbose) cat('Fixing test_year and separating item_desc\n')
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
    dplyr::select(-discard) %>%
    dplyr::mutate(
      test_grade_string = paste('Grade', as.character(test_grade))
    )

  #calculate cohort
  if (verbose) cat('Calculating implicit cohort\n')
  df <- df %>%
    dplyr::mutate(
      cohort_numeric = NYSEDtools::calculate_cohort(
        test_grade, start_year, cohort_kind
      )
    )

  #bedscode
  if (verbose) cat('Decomposing BEDS code into component parts\n')
  df <- df %>%
    interpret_bedscode()

  #make unique_id and tag rows
  df <- df %>%
    dplyr::mutate(
      unique_id = paste(
        as.character(bedscode), item_desc, subgroup_code, sep = '_'
      ),
      is_multigrade_aggregate = FALSE,
      is_district = ifelse(
        !bedscode == '000000000000' & !sch_kind_desc == 'Aggregation' &
          internal_district_code == '0000',
        TRUE, FALSE
      ),
      is_school = ifelse(
        !sch_kind_desc == 'Aggregation' & !internal_district_code == '0000',
        TRUE, FALSE
      )
    )


  if (test_year == 2015) {
    df <- df %>% dplyr::select(-sum_of_scale_score)
  }

  df
}


#' Fetch NY State assessment db
#'
#' @description wrapper around get_raw_assess_db and clean_assess_db
#' @inheritParams get_raw_assess_db
#'
#' @return clean data frame with assessment data
#' @export

fetch_assess_db <- function(test_year, verbose = TRUE) {
  raw <- get_raw_assess_db(test_year, verbose)
  clean <- clean_assess_db(raw, test_year, verbose = verbose)

  if (verbose) cat('Calculating attainment percentiles for grade-level data\n')
  clean %>%
    peer_percentile_pipe()
}


peer_percentile_pipe <- . %>%
  dplyr::mutate(
    count_proficient_dummy = ifelse(is.finite(l3_l4_pct), 1, 0),
    count_scale_dummy = ifelse(is.finite(mean_scale_score), 1, 0)
  ) %>%
  dplyr::group_by(
    test_year,
    test_subject,
    test_grade,
    subgroup_code,
    is_school, is_district,
    is_multigrade_aggregate
  ) %>%
  dplyr::mutate(
    proficient_numerator_asc = dplyr::min_rank(l3_l4_pct),
    proficient_numerator_desc = dplyr::min_rank(dplyr::desc(l3_l4_pct)),
    proficient_denominator = sum(count_proficient_dummy),

    scale_numerator_asc = dplyr::min_rank(mean_scale_score),
    scale_numerator_desc = dplyr::min_rank(dplyr::desc(mean_scale_score)),
    scale_denominator = sum(count_scale_dummy),

    proficiency_percentile = proficient_numerator_asc / proficient_denominator,
    scale_score_percentile = scale_numerator_asc / scale_denominator
  ) %>%
  dplyr::select(-count_proficient_dummy, -count_scale_dummy)



#' @title Create a assess_db object
#'
#' @param test_years numeric vector of test years
#' @param sub_grade_aggregates logical, should we calculate custom combinations of grade levels to help make
#' peering more precise?  default is FALSE
#' @param verbose should assess_db print status updates as
#' it generates the object?  default is TRUE.
#'
#' @examples
#'\dontrun{
#' ex_assess_db <- assess_db(
#'   test_years = c(2014:2016)
#'  )
#'
#' is.assess_db(ex_assess_db)
#' print(ex_assess_db)
#' }
#' @export

assess_db <- function(test_years, sub_grade_aggregates = FALSE, verbose = TRUE) UseMethod("assess_db")

#' @export
assess_db.default <- function(test_years, sub_grade_aggregates = FALSE, verbose = TRUE, ...) {

  clean_dbs <- list()
  agg_dfs <- list()

  for (i in test_years) {
    if (verbose) cat(paste('creating assess_db object for', i, '\n'))

    this_clean <- fetch_assess_db(i, verbose)
    clean_dbs[[as.character(i)]] <- this_clean

    # #test, read from disk for shorter iterations
    # clean_dbs[[as.character(i)]] <- fake_fetch_assess_db(i)

    #do all the aggregation for this df
    if (verbose) cat('Calculating school-level aggregates\n')
    agg_dfs[[as.character(i)]] <- aggregate_everything(this_clean, sub_grade_aggregates, verbose)
  }

  #put all the assessment rows together
  if (verbose) cat('Combining multiple years of data into single data.frames\n')
  assess <- dplyr::bind_rows(clean_dbs)
  aggregates <- dplyr::bind_rows(agg_dfs)

  out <- list(
    'assess' = assess,
    'aggregates' = aggregates
  )

  class(out) <- c("assess_db", class(out))
  if (verbose) cat('Returning the assess_db object\n')
  out
}
