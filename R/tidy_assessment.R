# ==============================================================================
# Assessment Data Tidying Functions
# ==============================================================================
#
# This file contains functions for converting NYSED assessment data into
# tidy (long) format.
#
# ==============================================================================


#' Tidy assessment data to long format
#'
#' Converts wide-format assessment data (with level1_count, level2_count, etc.)
#' into long format with proficiency_level and count/pct columns.
#'
#' NY State Tests use 4 proficiency levels:
#' - Level 1: Did Not Meet Standards
#' - Level 2: Partially Met Standards
#' - Level 3: Met Standards
#' - Level 4: Exceeded Standards
#'
#' @param df Processed data frame from process_assessment()
#' @return Tidy data frame with proficiency_level, n_students, and pct columns
#' @keywords internal
tidy_assessment <- function(df) {

  if (nrow(df) == 0) {
    return(data.frame())
  }

  # Identify which level columns exist
  level_count_cols <- grep("^level[1-5]_count$", names(df), value = TRUE)
  level_pct_cols <- grep("^level[1-5]_pcttested$", names(df), value = TRUE)

  if (length(level_count_cols) == 0 && length(level_pct_cols) == 0) {
    # Already tidy or no level data - return as-is
    return(df)
  }

  # Define id columns (everything except the level columns)
  all_level_cols <- c(level_count_cols, level_pct_cols)
  id_cols <- setdiff(names(df), all_level_cols)

  # Pivot longer for counts
  if (length(level_count_cols) > 0) {
    counts_long <- tidyr::pivot_longer(
      df[, c(id_cols, level_count_cols)],
      cols = tidyr::all_of(level_count_cols),
      names_to = "proficiency_level",
      values_to = "n_students"
    )

    # Clean up proficiency level names
    counts_long$proficiency_level <- gsub("_count$", "", counts_long$proficiency_level)
    counts_long$proficiency_level <- gsub("level", "Level ", counts_long$proficiency_level)
  }

  # Pivot longer for percentages
  if (length(level_pct_cols) > 0) {
    pcts_long <- tidyr::pivot_longer(
      df[, c(id_cols, level_pct_cols)],
      cols = tidyr::all_of(level_pct_cols),
      names_to = "proficiency_level",
      values_to = "pct"
    )

    # Clean up proficiency level names
    pcts_long$proficiency_level <- gsub("_pcttested$", "", pcts_long$proficiency_level)
    pcts_long$proficiency_level <- gsub("level", "Level ", pcts_long$proficiency_level)
  }

  # Combine counts and percentages if both exist
  if (length(level_count_cols) > 0 && length(level_pct_cols) > 0) {
    result <- dplyr::left_join(
      counts_long,
      pcts_long[, c(id_cols, "proficiency_level", "pct")],
      by = c(id_cols, "proficiency_level")
    )
  } else if (length(level_count_cols) > 0) {
    result <- counts_long
    result$pct <- NA_real_
  } else {
    result <- pcts_long
    result$n_students <- NA_integer_
  }

  # Add proficiency level descriptions
  result$level_description <- dplyr::case_when(
    result$proficiency_level == "Level 1" ~ "Did Not Meet Standards",
    result$proficiency_level == "Level 2" ~ "Partially Met Standards",
    result$proficiency_level == "Level 3" ~ "Met Standards",
    result$proficiency_level == "Level 4" ~ "Exceeded Standards",
    result$proficiency_level == "Level 5" ~ "Advanced",  # Math only in some years
    TRUE ~ NA_character_
  )

  # Add proficient flag (Levels 3-4 are proficient)
  result$is_proficient <- result$proficiency_level %in% c("Level 3", "Level 4", "Level 5")

  # Reorder columns
  first_cols <- c(
    "end_year", "entity_cd", "entity_name", "entity_type",
    "aggregation_level", "is_state", "is_district", "is_school",
    "subject", "grade", "assessment_name", "subgroup_name",
    "proficiency_level", "level_description", "is_proficient",
    "n_students", "pct"
  )

  existing_first <- intersect(first_cols, names(result))
  remaining <- setdiff(names(result), existing_first)

  result <- result[, c(existing_first, remaining)]

  result
}


#' Calculate proficiency rates from tidy assessment data
#'
#' Summarizes tidy assessment data to calculate overall proficiency rates
#' (percentage at Level 3 or above).
#'
#' @param df Tidy data frame from tidy_assessment()
#' @return Data frame with proficiency rates
#' @export
#' @examples
#' \dontrun{
#' # Get tidy assessment data
#' assess <- fetch_assessment(2024, tidy = TRUE)
#'
#' # Calculate proficiency rates
#' prof_rates <- calculate_proficiency_rates(assess)
#' }
calculate_proficiency_rates <- function(df) {

  if (!"is_proficient" %in% names(df)) {
    stop("Data must be in tidy format with is_proficient column. ",
         "Use tidy = TRUE when fetching data.")
  }

  # Group by identifying columns
  group_cols <- c(
    "end_year", "entity_cd", "entity_name", "entity_type",
    "aggregation_level", "subject", "grade", "assessment_name", "subgroup_name"
  )
  group_cols <- intersect(group_cols, names(df))

  # Calculate proficiency
  result <- df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_cols))) |>
    dplyr::summarize(
      n_tested = sum(.data$n_students, na.rm = TRUE),
      n_proficient = sum(.data$n_students[.data$is_proficient], na.rm = TRUE),
      pct_proficient = ifelse(
        .data$n_tested > 0,
        round(.data$n_proficient / .data$n_tested * 100, 1),
        NA_real_
      ),
      .groups = "drop"
    )

  result
}
