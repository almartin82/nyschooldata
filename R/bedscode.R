split_bedscode <- . %>%
  tidyr::separate(
    col = bedscode,
    into = c('location_county_code', 'location_city_code',
             'district_number', 'sch_kind_code',
             'internal_district_code'),
    sep = c(2, 4, 6, 8),
    remove = FALSE
  )


interpret_school_kind <- . %>%
  dplyr::mutate(
    sch_kind_desc = ifelse(sch_kind_code == '01', 'City', NA),
    sch_kind_desc = ifelse(sch_kind_code == '02', 'Union Free', sch_kind_desc),
    sch_kind_desc = ifelse(sch_kind_code == '03', 'Independent Union Free', sch_kind_desc),
    sch_kind_desc = ifelse(sch_kind_code == '04', 'Central', sch_kind_desc),
    sch_kind_desc = ifelse(sch_kind_code == '05', 'City Central', sch_kind_desc),
    sch_kind_desc = ifelse(sch_kind_code == '06', 'Independent Central', sch_kind_desc),
    sch_kind_desc = ifelse(sch_kind_code == '07', 'Central High School', sch_kind_desc),
    sch_kind_desc = ifelse(sch_kind_code == '08', 'Common', sch_kind_desc),
    sch_kind_desc = ifelse(sch_kind_code == '86', 'Charter', sch_kind_desc)
  )


#' Interpret bedscode (complete)
#'
#' @description Interpret the bedscode, and return everything
#' @param df data frame containing the column 'bedscode'
#' ie, output of clean_assess_db
#'
#' @return data.frame
#' @export

interpret_bedscode_complete <- function(df) {

  df <- df %>%
    split_bedscode() %>%
    interpret_school_kind()

  df
}


#' Interpret bedscode
#'
#' @description breaks out bedscode into element
#' @inheritParams interpret_bedscode_complete
#'
#' @return data.frame
#' @export

interpret_bedscode <- function(df) {

  df <- df %>%
    interpret_bedscode_complete() %>%
    dplyr::select(-location_county_code, -sch_kind_code)

  df
}
