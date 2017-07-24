#' Cohort Assessment Growth
#'
#' @description change in assessment performance following an
#' implicit cohort over multiple years
#' @inheritParams assess_growth
#'
#' @return data.frame
#' @export

cohort_growth <- function(clean_assess_start, clean_assess_end) {

  #tag the start and end dataframe with a simple record exists logical
  clean_assess_start$valid_record <- TRUE
  clean_assess_end$valid_record <- FALSE

  basic_id_cols <- c("bedscode", "test_subject", "subgroup_code", "test_grade")
  #get unique school/districts
  start_distinct <- clean_assess_start %>%
    dplyr::ungroup() %>%
    dplyr::select(dplyr::one_of(basic_id_cols)) %>%
    unique()

  end_distinct <- clean_assess_end %>%
    dplyr::ungroup() %>%
    dplyr::select(dplyr::one_of(basic_id_cols)) %>%
    unique()

  complete_distinct <- dplyr::bind_rows(start_distinct, end_distinct) %>%
    unique()

  #make scaffold
  scaffold <- complete_distinct %>%
    dplyr::rename(start_grade = test_grade) %>%
    dplyr::mutate(end_grade = start_grade + 1)

  #get basic ids from assess_end
  id_cols <- c(
    "bedscode",
    "test_subject", "test_grade", "test_grade_string",
    "nrc_code", "nrc_desc",
    "county_code", "county_desc", "name",
    "subgroup_code", "subgroup_name",
    "item_subject_area", "item_desc",
    "is_school", "is_district", "is_multigrade_aggregate"
  )

  scaffold <- scaffold %>%
    dplyr::left_join(
      y = clean_assess_end %>%
        dplyr::ungroup() %>%
        dplyr::select(dplyr::one_of(id_cols)),
      by = c(
        'bedscode' = 'bedscode',
        'test_subject' = 'test_subject',
        'subgroup_code' = 'subgroup_code',
        'end_grade' = 'test_grade'
      )
    )

  #if there are any unidentified rows, repeat the process with assess_start
  if (sum(is.na(scaffold$name)) > 0) {
    identified <- scaffold %>% dplyr::filter(!is.na(name))
    unidentified <- scaffold %>%
      dplyr::filter(is.na(name)) %>%
      dplyr::ungroup() %>%
      dplyr::select(bedscode, test_subject, subgroup_code, start_grade)

    unidentified <- unidentified %>%
      dplyr::left_join(
        y = clean_assess_start %>%
          dplyr::ungroup() %>%
          dplyr::select(dplyr::one_of(id_cols)),
        by = c(
          'bedscode' = 'bedscode',
          'test_subject' = 'test_subject',
          'subgroup_code' = 'subgroup_code',
          'start_grade' = 'test_grade'
        )
      )

    scaffold <- dplyr::bind_rows(identified, unidentified) %>%
      #some rows are nonsense, eg 2nd or 9th grade
      dplyr::filter(!is.na(name))
  }

  #now get start academic data
  acad_cols <- c("valid_record", "total_tested",
                 "l1_count", "l1_pct", "l2_count", "l2_pct",
                 "l3_count", "l3_pct", "l4_count", "l4_pct",
                 "l2_l4_count", "l2_l4_pct",
                 "l3_l4_count", "l3_l4_pct",
                 "mean_scale_score", "proficiency_percentile",
                 "scale_score_percentile")
  acad_join <- c(basic_id_cols, acad_cols)

  #join and rename start
  scaffold <- scaffold %>%
    dplyr::left_join(
      y = clean_assess_start %>%
        dplyr::ungroup() %>%
        dplyr::select(dplyr::one_of(acad_join)),
      by = c(
        'bedscode' = 'bedscode',
        'test_subject' = 'test_subject',
        'subgroup_code' = 'subgroup_code',
        'start_grade' = 'test_grade'
      )
    )

  mask <- names(scaffold) %in% acad_cols
  names(scaffold)[mask] <- paste0('start_', names(scaffold)[mask])

  #join and rename end
  scaffold <- scaffold %>%
    dplyr::left_join(
      y = clean_assess_start %>%
        dplyr::ungroup() %>%
        dplyr::select(dplyr::one_of(acad_join)),
      by = c(
        'bedscode' = 'bedscode',
        'test_subject' = 'test_subject',
        'subgroup_code' = 'subgroup_code',
        'end_grade' = 'test_grade'
      )
    )

  mask <- names(scaffold) %in% acad_cols
  names(scaffold)[mask] <- paste0('end_', names(scaffold)[mask])

  #complete obsv?
  start_complete = is.na(scaffold$start_valid_record)
  end_complete = is.na(scaffold$end_valid_record)

  start_recorded = is.na(scaffold$start_total_tested)
  end_recorded = is.na(scaffold$end_total_tested)

  scaffold$complete_obsv <- (start_complete + end_complete) == 2
  scaffold$reported_obsv <- (start_recorded + end_recorded) == 2

  #calculate growth
  scaffold <- scaffold %>%
    nys_change()

  scaffold
}
