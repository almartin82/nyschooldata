#' Proficinency Attainment Percentile
#'
#' @description compares schools to schools, districts to districts, to
#' get a statewide peer attainment percentile.
#'
#' @param percent_prof numeric, percent proficient, 0-100 scale
#' @param comparison_df data.frame (usually same year) to compare to
#' @param school_logical logical, is this a school?  schools get
#' @param district_logical logical, is this a district?
#' @param multigrade_logical logical, is this multigrade?
#' @param subject character, ELA or Math?
#' @param grade grade level?
#' @param subgroup character, subgroup number
#'
#' @return numeric length 1 vector
#' @export

prof_attainment_percentile <- function(
  percent_prof,
  comparison_df,
  school_logical,
  district_logical,
  multigrade_logical,
  subject,
  grade = NA,
  subgroup = 01
) {

  #don't calculate percentiles for things that aren't schools or districts
  if (!school_logical & !district_logical) {
    out <- NA_real_
  }

  #don't calculate percentiles for nonsense inputs
  if (is.na(percent_prof) | is.nan(percent_prof)) {
    out <- NA_real_
  }

  #limit df to relevant subject and subgroup
  df <- comparison_df %>%
    dplyr::filter(
      test_subject == subject &
      subgroup_code == subgroup &
      !is.na(l3_l4_pct)
    )

  #grade/multigrade first
  if (multigrade_logical) {
    df <- df %>% dplyr::filter(is_multigrade_aggregate == TRUE)
  } else if (!multigrade_logical) {
    df <- df %>% dplyr::filter(test_grade == grade)
  }

  #then school/district filter
  if (school_logical) {
    df <- df %>% dplyr::filter(is_school == TRUE)
  } else if (district_logical) {
    df <- df %>% dplyr::filter(is_district == TRUE)
  }

  mask <- percent_prof >= df$l3_l4_pct

  out <- mean(mask) %>% multiply_by(100) %>% round(0)
  out
}



#' Mean Scale Score Attainment Percentile
#'
#' @inheritParams prof_attainment_percentile
#'
#' @return numeric vector length 1
#' @export

scale_attainment_percentile <- function(
  scale_score,
  comparison_df,
  school_logical,
  district_logical,
  multigrade_logical,
  subject,
  grade = NA,
  subgroup = 01
) {

  #don't calculate percentiles for things that aren't schools or districts
  if (!school_logical & !district_logical) {
    out <- NA_real_
  }

  #don't calculate percentiles for nonsense inputs
  if (is.na(scale_score) | is.nan(scale_score)) {
    out <- NA_real_
  }

  #limit df to relevant subject and subgroup
  df <- comparison_df %>%
    dplyr::filter(
      test_subject == subject &
        subgroup_code == subgroup &
        !is.na(mean_scale_score)
    )

  #grade/multigrade first
  if (multigrade_logical) {
    df <- df %>% dplyr::filter(is_multigrade_aggregate == TRUE)
  } else if (!multigrade_logical) {
    df <- df %>% dplyr::filter(test_grade == grade)
  }

  #then school/district filter
  if (school_logical) {
    df <- df %>% dplyr::filter(is_school == TRUE)
  } else if (district_logical) {
    df <- df %>% dplyr::filter(is_district == TRUE)
  }

  mask <- percent_prof >= df$mean_scale_score

  out <- mean(mask) %>% multiply_by(100) %>% round(0)
  out
}
