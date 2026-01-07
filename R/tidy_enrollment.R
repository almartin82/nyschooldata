# ==============================================================================
# Enrollment Data Tidying Functions
# ==============================================================================
#
# This file contains functions for transforming enrollment data from wide
# format to long (tidy) format and identifying aggregation levels.
#
# ==============================================================================

#' Tidy enrollment data
#'
#' Transforms wide enrollment data to long format with grade_level column.
#' Each row represents enrollment for one school/district, one grade level.
#'
#' @param df A wide data.frame of processed enrollment data
#' @return A long data.frame of tidied enrollment data
#' @export
tidy_enr <- function(df) {

  # Invariant columns (identifiers that stay the same)
  invariants <- c(
    "end_year", "county",
    "district_beds", "district_code", "district_name",
    "beds_code", "school_code", "school_name",
    "school_type", "subgroup_code", "subgroup_name",
    "row_total",
    "is_state", "is_district", "is_school",
    "is_nyc", "is_charter"
  )
  invariants <- invariants[invariants %in% names(df)]

  # Grade columns to pivot
  grade_cols <- c(
    "grade_pk", "grade_pk_half", "grade_pk_full",
    "grade_k", "grade_k_half", "grade_k_full",
    "grade_01", "grade_02", "grade_03", "grade_04",
    "grade_05", "grade_06", "grade_07", "grade_08",
    "grade_09", "grade_10", "grade_11", "grade_12",
    "grade_ug_elem", "grade_ug_sec"
  )
  grade_cols <- grade_cols[grade_cols %in% names(df)]

  # Map column names to standard grade levels
  grade_level_map <- c(
    "grade_pk" = "PK",
    "grade_pk_half" = "PK_HALF",
    "grade_pk_full" = "PK_FULL",
    "grade_k" = "K",
    "grade_k_half" = "K_HALF",
    "grade_k_full" = "K_FULL",
    "grade_01" = "01",
    "grade_02" = "02",
    "grade_03" = "03",
    "grade_04" = "04",
    "grade_05" = "05",
    "grade_06" = "06",
    "grade_07" = "07",
    "grade_08" = "08",
    "grade_09" = "09",
    "grade_10" = "10",
    "grade_11" = "11",
    "grade_12" = "12",
    "grade_ug_elem" = "UG_ELEM",
    "grade_ug_sec" = "UG_SEC"
  )

  # Transform grade-level enrollment to long format
  if (length(grade_cols) > 0) {
    tidy_grades <- purrr::map_df(
      grade_cols,
      function(.x) {
        gl <- grade_level_map[.x]
        if (is.na(gl)) gl <- .x

        df |>
          dplyr::select(dplyr::all_of(c(invariants, .x))) |>
          dplyr::rename(n_students = dplyr::all_of(.x)) |>
          dplyr::mutate(
            grade_level = gl,
            subgroup = "total_enrollment",
            pct = n_students / row_total
          ) |>
          dplyr::select(dplyr::all_of(c(
            invariants[!invariants %in% c("row_total", "subgroup_code", "subgroup_name")],
            "grade_level", "subgroup", "n_students", "pct"
          )))
      }
    )
  } else {
    tidy_grades <- NULL
  }

  # Add total enrollment row
  if ("row_total" %in% names(df)) {
    tidy_total <- df |>
      dplyr::select(dplyr::all_of(invariants)) |>
      dplyr::mutate(
        n_students = row_total,
        subgroup = "total_enrollment",
        pct = 1.0,
        grade_level = "TOTAL"
      ) |>
      dplyr::select(dplyr::all_of(c(
        invariants[!invariants %in% c("row_total", "subgroup_code", "subgroup_name")],
        "grade_level", "subgroup", "n_students", "pct"
      )))
  } else {
    tidy_total <- NULL
  }

  # Combine all tidy data
  result <- dplyr::bind_rows(tidy_total, tidy_grades) |>
    dplyr::filter(!is.na(n_students))

  result
}


#' Identify enrollment aggregation levels
#'
#' Adds boolean flags to identify state, district, and school level records.
#' This is typically called automatically by fetch_enr, but can be used
#' to re-identify aggregation levels after filtering.
#'
#' @param df Enrollment dataframe
#' @return data.frame with boolean aggregation flags
#' @export
id_enr_aggs <- function(df) {

  # If flags already exist, just return
  if (all(c("is_state", "is_district", "is_school") %in% names(df))) {
    return(df)
  }

  # Add flags based on available identifiers
  if ("beds_code" %in% names(df)) {
    df <- df |>
      dplyr::mutate(
        is_school = !is.na(school_code) & school_code != "0000",
        is_district = !is.na(school_code) & school_code == "0000",
        is_state = FALSE,
        # Aggregation flag based on ID presence
        aggregation_flag = dplyr::case_when(
          !is.na(school_code) & school_code != "0000" ~ "campus",
          !is.na(school_code) & school_code == "0000" ~ "district",
          TRUE ~ "state"
        )
      )
  } else if ("district_beds" %in% names(df)) {
    df <- df |>
      dplyr::mutate(
        is_school = FALSE,
        is_district = TRUE,
        is_state = FALSE,
        # Aggregation flag based on ID presence
        aggregation_flag = "district"
      )
  }

  # NYC flag: NYC DOE geographic districts use codes starting with 30-35
  if ("district_code" %in% names(df)) {
    first_two <- substr(df$district_code, 1, 2)
    df$is_nyc <- first_two %in% c("30", "31", "32", "33", "34", "35")
  }

  # Charter flag
  if ("school_type" %in% names(df)) {
    df$is_charter <- grepl("CHARTER", toupper(df$school_type), fixed = FALSE)
  }

  df
}


#' Custom Enrollment Grade Level Aggregates
#'
#' Creates aggregations for common grade groupings: K-8, 9-12 (HS), K-12.
#'
#' @param df A tidy enrollment df (output of tidy_enr)
#' @return df of aggregated enrollment data
#' @export
enr_grade_aggs <- function(df) {

  # Group by invariants (everything except grade_level and counts)
  group_vars <- c(
    "end_year", "county",
    "district_beds", "district_code", "district_name",
    "beds_code", "school_code", "school_name",
    "school_type", "subgroup",
    "is_state", "is_district", "is_school", "is_nyc", "is_charter"
  )
  group_vars <- group_vars[group_vars %in% names(df)]

  # K-8 aggregate
  k8_agg <- df |>
    dplyr::filter(
      subgroup == "total_enrollment",
      grade_level %in% c("K", "01", "02", "03", "04", "05", "06", "07", "08")
    ) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) |>
    dplyr::summarize(
      n_students = sum(n_students, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      grade_level = "K8",
      pct = NA_real_
    )

  # High school (9-12) aggregate
  hs_agg <- df |>
    dplyr::filter(
      subgroup == "total_enrollment",
      grade_level %in% c("09", "10", "11", "12")
    ) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) |>
    dplyr::summarize(
      n_students = sum(n_students, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      grade_level = "HS",
      pct = NA_real_
    )

  # K-12 aggregate (excludes PK)
  k12_agg <- df |>
    dplyr::filter(
      subgroup == "total_enrollment",
      grade_level %in% c("K", "01", "02", "03", "04", "05", "06", "07", "08",
                         "09", "10", "11", "12")
    ) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) |>
    dplyr::summarize(
      n_students = sum(n_students, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      grade_level = "K12",
      pct = NA_real_
    )

  dplyr::bind_rows(k8_agg, hs_agg, k12_agg)
}


#' Filter enrollment data by grade span
#'
#' Convenience function to filter to common grade spans.
#'
#' @param df Tidy enrollment data frame
#' @param span Grade span: "pk12", "k12", "k8", "hs", "elem" (K-5), "middle" (6-8)
#' @return Filtered data frame
#' @export
filter_grade_span <- function(df, span = "k12") {

  grade_spans <- list(
    "pk12" = c("PK", "K", "01", "02", "03", "04", "05", "06", "07", "08",
               "09", "10", "11", "12"),
    "k12" = c("K", "01", "02", "03", "04", "05", "06", "07", "08",
              "09", "10", "11", "12"),
    "k8" = c("K", "01", "02", "03", "04", "05", "06", "07", "08"),
    "hs" = c("09", "10", "11", "12"),
    "elem" = c("K", "01", "02", "03", "04", "05"),
    "middle" = c("06", "07", "08")
  )

  if (!span %in% names(grade_spans)) {
    stop("Invalid span. Must be one of: ", paste(names(grade_spans), collapse = ", "))
  }

  df |>
    dplyr::filter(grade_level %in% grade_spans[[span]])
}
