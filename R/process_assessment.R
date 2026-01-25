# ==============================================================================
# Assessment Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw NYSED assessment data into
# a standardized format.
#
# ==============================================================================


#' Process raw NYSED assessment data
#'
#' Cleans and standardizes raw assessment data from the NYSED Report Card Database.
#' Adds entity type identification, converts numeric columns, and standardizes
#' column names.
#'
#' @param raw_data Data frame from get_raw_assessment()
#' @param end_year School year end (for metadata)
#' @return Processed data frame with standardized columns
#' @keywords internal
process_assessment <- function(raw_data, end_year) {

  if (nrow(raw_data) == 0) {
    return(data.frame())
  }

  # Standardize the data
  processed <- raw_data

  # Parse entity codes to identify entity type
  if ("entity_cd" %in% names(processed)) {
    processed <- parse_entity_codes(processed)
  }

  # Add end_year if not present
  if (!"end_year" %in% names(processed)) {
    processed$end_year <- end_year
  }

  # Extract subject from assessment_name or subject_table
  processed <- extract_subject(processed)

  # Extract grade from assessment_name
  processed <- extract_grade(processed)

  # Convert numeric columns
  processed <- convert_numeric_columns(processed)

  # Add aggregation flags
  processed <- add_aggregation_flags(processed)

  # Reorder columns for consistency
  processed <- reorder_assessment_columns(processed)

  processed
}


#' Parse entity codes to identify entity type
#'
#' NYSED entity codes follow patterns that indicate the type of entity:
#' - State: "000000000000" or starts with "0000000000"
#' - County: "000XXX000000" (XXX = county code)
#' - Need/Resource Category: "0000000000XX"
#' - District: "XXXXXXXXXXXX" (12 digits, ends in 0000)
#' - School: "XXXXXXXXXXXX" (12 digits, doesn't end in 0000)
#'
#' @param df Data frame with entity_cd column
#' @return Data frame with parsed entity information
#' @keywords internal
parse_entity_codes <- function(df) {

  df$entity_type <- dplyr::case_when(
    # Empty or aggregate categories
    is.na(df$entity_cd) | df$entity_cd == "" ~ "category",
    # State level - all zeros or very short codes
    grepl("^0+$", df$entity_cd) ~ "state",
    # County level - 12 digits, middle section is county code, ends in zeros
    nchar(df$entity_cd) == 12 & grepl("^000\\d{3}0{6}$", df$entity_cd) ~ "county",
    # Need/Resource Categories
    grepl("^0{10}\\d{2}$", df$entity_cd) ~ "category",
    # District level - 12 digits ending in 0000
    nchar(df$entity_cd) == 12 & grepl("0000$", df$entity_cd) ~ "district",
    # School level - 12 digits not ending in 0000
    nchar(df$entity_cd) == 12 ~ "school",
    # Default
    TRUE ~ "unknown"
  )

  # Extract district code from school entity codes
  if ("entity_cd" %in% names(df)) {
    df$district_cd <- dplyr::case_when(
      df$entity_type == "school" ~ paste0(substr(df$entity_cd, 1, 8), "0000"),
      df$entity_type == "district" ~ df$entity_cd,
      TRUE ~ NA_character_
    )
  }

  df
}


#' Extract subject from assessment data
#'
#' Determines the subject (ELA, Math, Science) from the assessment_name
#' or subject_table columns.
#'
#' @param df Data frame with assessment data
#' @return Data frame with subject column
#' @keywords internal
extract_subject <- function(df) {

  # First try subject_table
  if ("subject_table" %in% names(df)) {
    df$subject <- dplyr::case_when(
      grepl("ELA", df$subject_table, ignore.case = TRUE) ~ "ELA",
      grepl("MATH", df$subject_table, ignore.case = TRUE) ~ "Math",
      grepl("SCIENCE", df$subject_table, ignore.case = TRUE) ~ "Science",
      TRUE ~ NA_character_
    )
  }

  # Override with assessment_name if more specific
  if ("assessment_name" %in% names(df)) {
    df$subject <- dplyr::case_when(
      grepl("^ELA", df$assessment_name, ignore.case = TRUE) ~ "ELA",
      grepl("^MATH", df$assessment_name, ignore.case = TRUE) ~ "Math",
      grepl("^Science", df$assessment_name, ignore.case = TRUE) ~ "Science",
      grepl("^Combined.*Math", df$assessment_name, ignore.case = TRUE) ~ "Math",
      grepl("^Combined.*Science", df$assessment_name, ignore.case = TRUE) ~ "Science",
      grepl("^Regents.*Math", df$assessment_name, ignore.case = TRUE) ~ "Math",
      grepl("^Regents.*Science", df$assessment_name, ignore.case = TRUE) ~ "Science",
      TRUE ~ df$subject
    )
  }

  df
}


#' Extract grade from assessment name
#'
#' Parses the grade level from the assessment_name column.
#' NY State Tests are typically named like "ELA3", "MATH5", "ELA3_8", etc.
#'
#' @param df Data frame with assessment_name column
#' @return Data frame with grade column
#' @keywords internal
extract_grade <- function(df) {

  if (!"assessment_name" %in% names(df)) {
    df$grade <- NA_character_
    return(df)
  }

  # Extract grade from patterns like "ELA3", "MATH5", "Science8"
  df$grade <- dplyr::case_when(
    # Combined grades (3-8)
    grepl("3_8$", df$assessment_name) ~ "3-8",
    # Individual grades
    grepl("3$", df$assessment_name) ~ "03",
    grepl("4$", df$assessment_name) ~ "04",
    grepl("5$", df$assessment_name) ~ "05",
    grepl("6$", df$assessment_name) ~ "06",
    grepl("7$", df$assessment_name) ~ "07",
    grepl("8$", df$assessment_name) ~ "08",
    # Regents (typically high school - no specific grade)
    grepl("^Regents", df$assessment_name, ignore.case = TRUE) ~ "HS",
    TRUE ~ NA_character_
  )

  df
}


#' Convert numeric columns in assessment data
#'
#' Converts count and percentage columns to numeric, handling
#' suppression markers (s, *, etc.)
#'
#' @param df Data frame with assessment data
#' @return Data frame with numeric columns converted
#' @keywords internal
convert_numeric_columns <- function(df) {

  # Columns that should be numeric (counts)
  count_cols <- c(
    "total_count", "not_tested", "num_tested",
    "level1_count", "level2_count", "level3_count", "level4_count", "level5_count",
    "num_prof", "total_scale_scores", "tested"
  )

  # Columns that should be numeric (percentages)
  pct_cols <- c(
    "pct_not_tested", "pct_tested",
    "level1_pcttested", "level2_pcttested", "level3_pcttested",
    "level4_pcttested", "level5_pcttested",
    "per_prof", "mean_score"
  )

  # Convert count columns
  for (col in count_cols) {
    if (col %in% names(df)) {
      df[[col]] <- safe_numeric_assessment(df[[col]])
    }
  }

  # Convert percentage columns
  for (col in pct_cols) {
    if (col %in% names(df)) {
      df[[col]] <- safe_numeric_assessment(df[[col]])
    }
  }

  df
}


#' Safely convert to numeric, handling suppression markers
#'
#' NYSED uses "s" and other markers for suppressed data.
#'
#' @param x Vector to convert
#' @return Numeric vector with NA for non-numeric values
#' @keywords internal
safe_numeric_assessment <- function(x) {
  # Convert to character if not already
  x <- as.character(x)

  # Remove whitespace
  x <- trimws(x)

  # Handle common suppression markers
  x[x %in% c("s", "S", "*", ".", "-", "N/A", "NA", "", "RV", "**", "n/a")] <- NA_character_

  # Remove commas (thousands separator)
  x <- gsub(",", "", x)

  suppressWarnings(as.numeric(x))
}


#' Add aggregation flags to assessment data
#'
#' Adds is_state, is_district, is_school flags based on entity_type.
#'
#' @param df Data frame with entity_type column
#' @return Data frame with aggregation flags
#' @keywords internal
add_aggregation_flags <- function(df) {

  if ("entity_type" %in% names(df)) {
    df$is_state <- df$entity_type == "state"
    df$is_county <- df$entity_type == "county"
    df$is_district <- df$entity_type == "district"
    df$is_school <- df$entity_type == "school"

    df$aggregation_level <- dplyr::case_when(
      df$is_state ~ "state",
      df$is_county ~ "county",
      df$is_district ~ "district",
      df$is_school ~ "school",
      TRUE ~ "category"
    )
  }

  df
}


#' Reorder assessment columns for consistency
#'
#' Puts identifying columns first, then assessment results.
#'
#' @param df Data frame to reorder
#' @return Data frame with reordered columns
#' @keywords internal
reorder_assessment_columns <- function(df) {

  # Define preferred column order
  first_cols <- c(
    "end_year", "year",
    "entity_cd", "entity_name", "entity_type",
    "district_cd", "institution_id",
    "aggregation_level", "is_state", "is_county", "is_district", "is_school",
    "subject", "grade", "assessment_name",
    "subgroup_name"
  )

  # Get columns that exist
  existing_first <- intersect(first_cols, names(df))
  remaining <- setdiff(names(df), existing_first)

  # Reorder
  df[, c(existing_first, remaining)]
}
