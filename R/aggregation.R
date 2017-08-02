#' Aggregate results by subject across grade levels
#'
#' @param clean_df data.frame, output of clean_assess_db or fetch_assess_db
#'
#' @return data.frame with *only* the sch/dist aggregate scores.
#' @export

aggregate_grades <- function(clean_df) {

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
  )

  all_gr <- clean_df %>%
    dplyr::group_by_at(grouping_cols) %>%
    org_summary() %>%
    org_percentages()

  all_gr <- all_gr %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      item_desc = NA,
      test_grade = NA,
      test_grade_string = paste0('Gr ', min_grade, '-', max_grade, ' Aggregate'),
      cohort_numeric = NA,
      unique_id = NA,
      unique_id = paste(
        bedscode, test_grade_string, test_subject, subgroup_code, sep = '_'
      ),
      is_multigrade_aggregate = TRUE
    ) %>%
    dplyr::select(-total_tested_meanscale, -sum_of_mean_scale_score)

  all_gr
}


org_summary <- . %>%
  dplyr::summarize(
    min_grade = min(test_grade),
    max_grade = max(test_grade),
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
#' @param clean_df data.frame, ie output of clean_assess_db
#' @param bedscode bedscode for the school you want to custom aggregate
#' @param grades grades that are in this custom aggregation
#' @param cust_suffix suffix to throw onto the bedscode
#'
#' @return data.frame
#' @export

custom_aggregate <- function(clean_df, bedscode, grades, cust_suffix = '_custom') {
  #nse problems
  bedscode_in <- bedscode

  #limit the clean_df to the matching bedscode and grades
  matching_df <- clean_df %>%
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
  out <- dplyr::bind_rows(clean_df, all_agg) %>%
    peer_percentile_pipe()

  out
}


#' Creates an aggregation scaffold for one school/district
#'
#' @param bedscode character, BEDS identifier
#' @param min_gr integer, smallest grade level at this school
#' @param max_gr integer, largest grade level at this school
#'
#' @return data.frame, with all of the consecutive sub-grade runs

sch_aggregation_scaffold <- function(bedscode, min_gr, max_gr) {

  runs <- grade_runs(min_gr, max_gr)
  lengths <- purrr::map_int(runs, length)
  group_index <- rep(c(1:length(lengths)), lengths)

  scaffold <- data.frame(
    'bedscode' = bedscode,
    'group' = group_index,
    test_grade = purrr::flatten_int(runs),
    stringsAsFactors = FALSE
  )

  scaffold_ids <- scaffold %>%
    dplyr::group_by(bedscode, group) %>%
    dplyr::summarize(
      min_grade = min(test_grade),
      max_grade = max(test_grade)
    )

  scaffold <- scaffold %>%
    dplyr::inner_join(scaffold_ids, by = c('bedscode', 'group'))

  subjs <- data.frame(
    test_subject = c('ELA', 'Math'),
    stringsAsFactors = FALSE
  )

  merge(scaffold, subjs, all = TRUE)
}



#' Create the full aggregation scaffold for all records in a clean assess df
#'
#' @param clean_df output of clean_assess_db or fetch_assess_db
#'
#' @return data.frame ready to join back to the clean_df

full_aggregation_scaffold <- function(clean_df) {

  unq_sch <- clean_df %>%
    dplyr::group_by(test_year, test_subject, bedscode) %>%
    dplyr::summarize(
      min_grade = min(test_grade),
      max_grade = max(test_grade)
    )

  full_scaffold <- list()

  for (i in seq_len(nrow(unq_sch))) {
    full_scaffold[[i]] <- sch_aggregation_scaffold(
      bedscode = unq_sch[i, ]$bedscode,
      min_gr = unq_sch[i, ]$min_grade,
      max_gr = unq_sch[i, ]$max_grade
    )
  }

  full_scaffold_df <- dplyr::bind_rows(full_scaffold)

  full_scaffold_df
}


#' Makes all-grade and sub-grade aggregates from a clean data file
#'
#' @inheritParams full_aggregation_scaffold
#' @param verbose logical, print status updates to the console?
#'
#' @return data.frame, with all-grade and sub-grade aggregations
#' @export

aggregate_everything <- function(clean_df, verbose = TRUE) {

  if (verbose) cat('Calculating all-grade school-level aggregates\n')
  full_sch <- clean_df %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      bedscode = paste0(bedscode, '_all')
    ) %>%
    aggregate_grades() %>%
    dplyr::mutate(
      is_subschool = FALSE
    )

  if (verbose) cat('Calculating attainment %iles for all-grade aggregates\n')
  full_sch <- full_sch %>%
    peer_percentile_pipe()

  #subschools
  if (verbose) cat('Finding the relevant sub-grade pairs for each school\n')
  df <- full_aggregation_scaffold(clean_df) %>%
    dplyr::mutate(
      new_bedscode = paste(bedscode, min_grade, max_grade, sep = '_')
    ) %>%
    dplyr::select(
      -group, -min_grade, -max_grade
    ) %>%
    dplyr::left_join(
      y = clean_df,
      by = c('bedscode', 'test_grade', 'test_subject')
    ) %>%
    dplyr::select(-bedscode) %>%
    dplyr::rename(bedscode = new_bedscode)

  if (verbose) cat('Calculating sub-grade school aggregates\n')
  sub_sch <- df %>%
    aggregate_grades() %>%
    dplyr::mutate(
      is_subschool = TRUE
    )

  if (verbose) cat('Calculating attainment %iles for sub-grade aggregates\n')
  sub_sch <- sub_sch %>%
    peer_percentile_pipe()

  dplyr::bind_rows(full_sch, sub_sch)
}
