#' Aggregate results by subject across grade levels
#'
#' @param df data.frame, output of clean_assess_db or fetch_assess_db
#'
#' @return data.frame with *only* the sch/dist aggregate scores.
#' @export

aggregate_grades <- function(df) {

  grouping_cols <- c(
    "school_year",
    "bedscode", "name",
    "nrc_code", "nrc_desc",
    "county_code", "county_desc",
    #from bedscode
    "location_city_code", "district_number",
    "internal_district_code", "sch_kind_desc",

    "subgroup_code", "subgroup_name",
    "item_subject_area", "test_subject",

    "test_year", "start_year",

    "is_school", "is_district"
  ) %>%
  lapply(., as.symbol)

  all_gr <- df %>%
    dplyr::regroup(grouping_cols) %>%
    org_summary() %>%
    org_percentages()

  all_gr <- all_gr %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      item_desc = NA,
      test_grade = NA,
      test_grade_string = 'All',
      cohort_numeric = NA,
      unique_id = NA,
      unique_id = paste(
        bedscode, 'Gr 3-8 Aggregate', test_subject, subgroup_code, sep = '_'
      ),
      is_multigrade_aggregate = TRUE
    ) %>%
  dplyr::select(
    -total_tested_meanscale, -sum_of_mean_scale_score
  )

  all_gr
}


org_summary <- . %>%
  dplyr::summarize(
    total_tested = sum(total_tested, na.rm = TRUE),
    total_tested_meanscale = sum(
      ifelse(is.na(mean_scale_score), NA, total_tested)
    ),
    l1_count = sum(l1_count, na.rm = TRUE),
    l2_count = sum(l2_count, na.rm = TRUE),
    l3_count = sum(l3_count, na.rm = TRUE),
    l4_count = sum(l4_count, na.rm = TRUE),
    l2_l4_count = sum(l2_l4_count, na.rm = TRUE),
    l3_l4_count = sum(l3_l4_count, na.rm = TRUE),
    sum_of_mean_scale_score = sum(mean_scale_score * total_tested)
  )


org_percentages <- . %>%
  dplyr::mutate(
    l1_pct = (l1_count / total_tested) %>% multiply_by(100) %>% round(1),
    l2_pct = (l2_count / total_tested) %>% multiply_by(100) %>% round(1),
    l3_pct = (l3_count / total_tested) %>% multiply_by(100) %>% round(1),
    l4_pct = (l4_count / total_tested) %>% multiply_by(100) %>% round(1),
    l2_l4_pct = (l2_l4_count / total_tested) %>% multiply_by(100) %>% round(1),
    l3_l4_pct = (l3_l4_count / total_tested) %>% multiply_by(100) %>% round(1),
    mean_scale_score = (sum_of_mean_scale_score / total_tested_meanscale) %>%
      round(1)
  )



#' make a custom aggregation
#'
#' @description some charters or schools have multiple 'campuses' inside of the same
#' bedscode. make a custom aggregation by grade level.
#' @param assess_df data.frame, output of fetch_aggregate_percentile_assess_db
#' @param bedscode bedscode for the school you want to custom aggregate
#' @param grades grades that are in this custom aggregation
#' @param cust_suffix suffix to throw onto the bedscode
#'
#' @return data.frame
#' @export

custom_aggregate <- function(assess_df, bedscode, grades, cust_suffix = '_custom') {
  #nse problems
  bedscode_in <- bedscode

  #limit the assess_df to the matching bedscode and grades
  matching_df <- assess_df %>%
    dplyr::filter(bedscode == bedscode_in &
                    test_grade %in% grades)

  #modify the bedscode and remake the unique_id
  matching_df <- matching_df %>%
    dplyr::mutate(
      bedscode = paste0(bedscode, cust_suffix),
      unique_id = paste(
        as.character(bedscode), item_desc, subgroup_code, sep = '_'
      )
    )

  #get the aggregate
  agg_df <- aggregate_grades(matching_df)


  #put it all together and return
  all_agg <- dplyr::bind_rows(agg_df, matching_df)

  #recalculate percentiles
  out <- dplyr::bind_rows(assess_df, all_agg) %>%
    peer_percentile_pipe()

  out
}
