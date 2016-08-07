#' Assessment Growth (Same Grade)
#'
#' @description change in assessment performance,
#' same grade, across two test years.
#' @param clean_assess_start data.frame, start of window.
#' output of clean_assess_db
#' @param clean_assess_end data.frame, end of window.
#' output of clean_assess_db
#'
#' @return data.frame
#' @export

assess_growth <- function(clean_assess_start, clean_assess_end) {

  #tag the start and end dataframe with a simple record exists logical
  clean_assess_start$valid_record <- TRUE
  clean_assess_end$valid_record <- FALSE

  #get unique school/districts
  start_distinct <- clean_assess_start %>%
    dplyr::select(unique_id) %>%
    unique()

  end_distinct <- clean_assess_end %>%
    dplyr::select(unique_id) %>%
    unique()

  complete_distinct <- dplyr::bind_rows(start_distinct, end_distinct) %>%
    unique()

  #make scaffold
  scaffold <- complete_distinct %>%
    dplyr::mutate(
      start_test_year = unique(clean_assess_start$test_year),
      end_test_year = unique(clean_assess_end$test_year)
    )

  #get basic ids from assess_end
  id_cols <- c(
    "unique_id", "test_year", "bedscode", "nrc_code", "nrc_desc",
    "county_code", "county_desc", "name",
    "item_subject_area", "item_desc", "test_grade",
    "test_subject", "subgroup_code", "subgroup_name"
  )

  scaffold <- scaffold %>%
    dplyr::left_join(
      y = clean_assess_end %>% dplyr::select(dplyr::one_of(id_cols)),
      by = c('unique_id' = 'unique_id', 'end_test_year' = 'test_year')
    )

  #if there are any unidentified rows, repeat the process with assess_start
  if (sum(is.na(scaffold$name)) > 0) {
    identified <- scaffold %>% dplyr::filter(!is.na(name))
    unidentified <- scaffold %>% dplyr::filter(is.na(name)) %>%
      dplyr::select(unique_id, start_test_year, end_test_year)

    unidentified <- unidentified %>%
      dplyr::left_join(
        y = clean_assess_start %>% dplyr::select(dplyr::one_of(id_cols)),
        by = c('unique_id' = 'unique_id', 'start_test_year' = 'test_year')
      )

    scaffold <- dplyr::bind_rows(identified, unidentified)
  }

  #now get start academic data
  id_cols <- c("unique_id", "test_year")
  acad_cols <- c("valid_record", "total_tested",
      "l1_count", "l1_pct", "l2_count", "l2_pct",
      "l3_count", "l3_pct", "l4_count", "l4_pct",
      "l2_l4_count", "l2_l4_pct",
      "l3_l4_count", "l3_l4_pct",
      "mean_scale_score")
  acad_join <- c(id_cols, acad_cols)

  #join and rename start
  scaffold <- scaffold %>%
    dplyr::left_join(
      y = clean_assess_start %>% dplyr::select(dplyr::one_of(acad_join)),
      by = c('unique_id' = 'unique_id', 'start_test_year' = 'test_year')
    )

  mask <- names(scaffold) %in% acad_cols
  names(scaffold)[mask] <- paste0('start_', names(scaffold)[mask])

  #join and rename end
  scaffold <- scaffold %>%
    dplyr::left_join(
      y = clean_assess_end %>% dplyr::select(dplyr::one_of(acad_join)),
      by = c('unique_id' = 'unique_id', 'end_test_year' = 'test_year')
    )

  mask <- names(scaffold) %in% acad_cols
  names(scaffold)[mask] <- paste0('end_', names(scaffold)[mask])

  #complete obsv?
  start_complete = is.na(scaffold$start_valid_record)
  end_complete = is.na(scaffold$end_valid_record)

  start_recorded = is.na(scaffold$start_total_tested)
  end_recorded = is.na(scaffold$end_total_tested)

  scaffold$complete_obsv <- (start_complete + end_complete) == 2
  scaffold$complete_recorded_obsv <- (start_recorded + end_recorded) == 2

  #calculate growth
  scaffold <- scaffold %>%
    nys_change()

  #return
  scaffold
}


nys_change <- . %>% dplyr::mutate(
  total_tested_change = end_total_tested - start_total_tested,
  l1_count_change = end_l1_count - start_l1_count,
  l2_count_change = end_l2_count - start_l2_count,
  l3_count_change = end_l3_count - start_l3_count,
  l4_count_change = end_l4_count - start_l4_count,

  l1_pct_change = end_l1_pct - start_l1_pct,
  l2_pct_change = end_l2_pct - start_l2_pct,
  l3_pct_change = end_l3_pct - start_l3_pct,
  l4_pct_change = end_l4_pct - start_l4_pct,

  l2_l4_count_change = end_l2_l4_count - start_l2_l4_count,
  l3_l4_count_change = end_l3_l4_count - start_l3_l4_count,

  l2_l4_pct_change = end_l2_l4_pct - start_l2_l4_pct,
  l3_l4_pct_change = end_l3_l4_pct - start_l3_l4_pct,

  mean_scale_score_change = end_mean_scale_score - start_mean_scale_score
)
