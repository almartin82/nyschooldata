# ==============================================================================
# Enrollment Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw NYSED enrollment data into a
# clean, standardized format.
#
# ==============================================================================

#' Convert to numeric, handling suppression markers
#'
#' NYSED uses various markers for suppressed data (*, s, etc.)
#' and uses commas in large numbers.
#'
#' @param x Vector to convert
#' @return Numeric vector with NA for non-numeric values
#' @keywords internal
safe_numeric <- function(x) {
  # Handle already numeric values
  if (is.numeric(x)) return(x)

  # Remove commas and whitespace, then convert to numeric
  x <- gsub(",", "", x)
  x <- trimws(x)
  suppressWarnings(as.numeric(x))
}


#' Process raw NYSED enrollment data
#'
#' Transforms raw data from get_raw_enr into a standardized format with
#' consistent column names and proper data types.
#'
#' @param df Raw data frame from get_raw_enr
#' @param end_year School year end
#' @return Processed data frame with standardized columns
#' @keywords internal
process_enr <- function(df, end_year) {

  cols <- names(df)

  # Build result with core identifier columns
  result <- data.frame(
    end_year = rep(end_year, nrow(df)),
    stringsAsFactors = FALSE
  )

  # County
  if ("County" %in% cols) {
    result$county <- df$County
  }

  # District identifier (12-digit BEDS code ending in 0000)
  dist_col <- intersect(c("State District Identifier", "STATE DISTRICT IDENTIFIER"), cols)[1]
  if (!is.na(dist_col)) {
    result$district_beds <- as.character(df[[dist_col]])
    # Extract 6-digit district code
    result$district_code <- substr(result$district_beds, 1, 6)
  }

  # District name
  if ("District Name" %in% cols) {
    result$district_name <- df[["District Name"]]
  }

  # School/location identifier (12-digit BEDS code)
  loc_col <- intersect(c("State Location Identifier", "STATE LOCATION IDENTIFIER"), cols)[1]
  if (!is.na(loc_col)) {
    result$beds_code <- as.character(df[[loc_col]])
    # Extract school code (positions 7-10)
    result$school_code <- substr(result$beds_code, 7, 10)
  }

  # School/location name
  loc_name_col <- intersect(c("Location Name", "LOCATION NAME"), cols)[1]
  if (!is.na(loc_name_col)) {
    result$school_name <- df[[loc_name_col]]
  }

  # School type
  type_col <- intersect(c("School Type", "SCHOOL TYPE"), cols)[1]
  if (!is.na(type_col)) {
    result$school_type <- df[[type_col]]
  }

  # Subgroup info (useful for demographic breakdowns)
  if ("Subgroup Code" %in% cols) {
    result$subgroup_code <- df[["Subgroup Code"]]
  }
  if ("Subgroup Name" %in% cols) {
    result$subgroup_name <- df[["Subgroup Name"]]
  }

  # Total enrollment
  total_col <- intersect(c("PreK-12 Total", "PK12 TOTAL"), cols)[1]
  if (!is.na(total_col)) {
    result$row_total <- safe_numeric(df[[total_col]])
  }

  # PreK enrollment
  pk_half_col <- intersect(c("PreK (Half Day)", "PK (HALF DAY)"), cols)[1]
  if (!is.na(pk_half_col)) {
    result$grade_pk_half <- safe_numeric(df[[pk_half_col]])
  }

  pk_full_col <- intersect(c("PreK (Full Day)", "PK (FULL DAY)"), cols)[1]
  if (!is.na(pk_full_col)) {
    result$grade_pk_full <- safe_numeric(df[[pk_full_col]])
  }

  # Kindergarten enrollment
  k_half_col <- intersect(c("Kindergarten (Half Day)", "K (HALF DAY)"), cols)[1]
  if (!is.na(k_half_col)) {
    result$grade_k_half <- safe_numeric(df[[k_half_col]])
  }

  k_full_col <- intersect(c("Kindergarten (Full Day)", "K (FULL DAY)"), cols)[1]
  if (!is.na(k_full_col)) {
    result$grade_k_full <- safe_numeric(df[[k_full_col]])
  }

  # Grade-level enrollment (1-12)
  grade_map <- list(
    "grade_01" = c("Grade 1", "GRADE 1"),
    "grade_02" = c("Grade 2", "GRADE 2"),
    "grade_03" = c("Grade 3", "GRADE 3"),
    "grade_04" = c("Grade 4", "GRADE 4"),
    "grade_05" = c("Grade 5", "GRADE 5"),
    "grade_06" = c("Grade 6", "GRADE 6"),
    "grade_07" = c("Grade 7", "GRADE 7"),
    "grade_08" = c("Grade 8", "GRADE 8"),
    "grade_09" = c("Grade 9", "GRADE 9"),
    "grade_10" = c("Grade 10", "GRADE 10"),
    "grade_11" = c("Grade 11", "GRADE 11"),
    "grade_12" = c("Grade 12", "GRADE 12")
  )

  for (new_name in names(grade_map)) {
    old_names <- grade_map[[new_name]]
    found_col <- intersect(old_names, cols)[1]
    if (!is.na(found_col)) {
      result[[new_name]] <- safe_numeric(df[[found_col]])
    }
  }

  # Ungraded categories
  ug_elem_col <- intersect(c("Ungraded (Elementary)", "UNGRADED ELEM"), cols)[1]
  if (!is.na(ug_elem_col)) {
    result$grade_ug_elem <- safe_numeric(df[[ug_elem_col]])
  }

  ug_sec_col <- intersect(c("Ungraded (Secondary)", "UNGRADED SEC"), cols)[1]
  if (!is.na(ug_sec_col)) {
    result$grade_ug_sec <- safe_numeric(df[[ug_sec_col]])
  }

  # Add combined PreK and K columns for convenience
  if ("grade_pk_half" %in% names(result) || "grade_pk_full" %in% names(result)) {
    result$grade_pk <- rowSums(
      result[, c("grade_pk_half", "grade_pk_full")[c("grade_pk_half", "grade_pk_full") %in% names(result)]],
      na.rm = TRUE
    )
    result$grade_pk[is.na(result$grade_pk_half) & is.na(result$grade_pk_full)] <- NA
  }

  if ("grade_k_half" %in% names(result) || "grade_k_full" %in% names(result)) {
    result$grade_k <- rowSums(
      result[, c("grade_k_half", "grade_k_full")[c("grade_k_half", "grade_k_full") %in% names(result)]],
      na.rm = TRUE
    )
    result$grade_k[is.na(result$grade_k_half) & is.na(result$grade_k_full)] <- NA
  }

  # Add aggregation level flags
  result <- add_agg_flags(result)

  result
}


#' Add aggregation level flags
#'
#' Determines whether each row is state, district, or school level data
#' and adds NYC and charter school flags.
#'
#' @param df Processed data frame
#' @return Data frame with aggregation flags
#' @keywords internal
add_agg_flags <- function(df) {

  # Check if this is district-level data (no beds_code or school_code is 0000)
  if (!"beds_code" %in% names(df)) {
    # District-level file
    df$is_school <- FALSE
    df$is_district <- TRUE
    df$is_state <- FALSE
  } else {
    # School-level file
    # School code of "0000" typically indicates district aggregate
    df$is_school <- !is.na(df$school_code) & df$school_code != "0000"
    df$is_district <- !is.na(df$school_code) & df$school_code == "0000"
    df$is_state <- FALSE
  }

  # NYC flag: NYC DOE geographic districts use codes starting with 30-35

  # - 307500: NYC Special Schools (District 75)
  # - 31xxxx: Manhattan (Districts 1-6)
  # - 32xxxx: Bronx (Districts 7-12)
  # - 33xxxx: Brooklyn (Districts 13-23, 32)
  # - 34xxxx: Queens (Districts 24-30)
  # - 35xxxx: Staten Island (District 31)
  if ("district_code" %in% names(df)) {
    first_two <- substr(df$district_code, 1, 2)
    df$is_nyc <- first_two %in% c("30", "31", "32", "33", "34", "35")
  } else {
    df$is_nyc <- FALSE
  }

  # Charter school flag
  # In NY, charter schools have specific school type codes
  if ("school_type" %in% names(df)) {
    df$is_charter <- grepl("CHARTER", toupper(df$school_type), fixed = FALSE)
  } else {
    df$is_charter <- FALSE
  }

  df
}


#' Parse BEDS code into components
#'
#' BEDS codes are 12 digits: DDDDDDSSSSCC
#' - DDDDDD: District code (6 digits)
#' - SSSS: School code (4 digits)
#' - CC: Check digits (2 digits)
#'
#' @param beds_code Character vector of BEDS codes
#' @return Data frame with parsed components
#' @export
#' @examples
#' parse_beds_code("010100010018")
#' # Returns: district_code = "010100", school_code = "0001", check_digits = "18"
parse_beds_code <- function(beds_code) {
  beds_code <- as.character(beds_code)

  data.frame(
    beds_code = beds_code,
    district_code = substr(beds_code, 1, 6),
    school_code = substr(beds_code, 7, 10),
    check_digits = substr(beds_code, 11, 12),
    stringsAsFactors = FALSE
  )
}


#' Validate BEDS code format
#'
#' Checks if a BEDS code has the expected 12-digit format.
#'
#' @param beds_code Character vector of BEDS codes
#' @return Logical vector indicating valid codes
#' @export
#' @examples
#' validate_beds_code(c("010100010018", "31000001023", "invalid"))
validate_beds_code <- function(beds_code) {
  beds_code <- as.character(beds_code)
  grepl("^\\d{12}$", beds_code)
}
