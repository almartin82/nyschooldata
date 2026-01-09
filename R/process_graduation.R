# ==============================================================================
# Graduation Rate Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw graduation data from NYSED
# into a standardized schema.
#
# ==============================================================================

#' Default cohort type for graduation rates
#' @keywords internal
DEFAULT_COHORT_TYPE <- "4year_june"

#' Process raw graduation data into standard schema
#'
#' Transforms raw NYSED graduation data into the standardized schema used by
#' the package. Converts text percentages to numeric, handles suppressed values,
#' and standardizes column names.
#'
#' @param raw_data Data frame from get_raw_graduation()
#' @param end_year School year end
#' @param membership_code Optional membership code to filter (default: 9 for 4-year June)
#' @return Processed data frame with standardized columns
#' @keywords internal
process_graduation <- function(raw_data, end_year, membership_code = 9) {

  # Helper to safely get a column value
  safe_col <- function(df, col_name) {
    if (col_name %in% names(df)) {
      return(df[[col_name]])
    }
    return(rep(NA_character_, nrow(df)))
  }

  # Helper to convert text percentage to numeric
  pct_to_num <- function(x) {
    x <- as.character(x)
    # Remove % character
    x <- gsub("%", "", x, fixed = TRUE)
    # Handle division errors
    x <- gsub("/0", NA_character_, x, fixed = TRUE)
    x <- gsub("#DIV/0!", NA_character_, x, fixed = TRUE)
    # Convert to numeric (divide by 100)
    as.numeric(x) / 100
  }

  # Helper to convert text count to numeric
  cnt_to_num <- function(x) {
    x <- as.character(x)
    # Empty strings to NA
    x[x == "" | is.na(x)] <- NA_character_
    as.integer(x)
  }

  # Extract columns with flexible name matching
  # NYSED columns are fairly consistent, but we'll handle variations

  # Type and identifiers
  agg_type <- safe_col(raw_data, "aggregation_type")
  agg_code <- safe_col(raw_data, "aggregation_code")
  agg_name <- safe_col(raw_data, "aggregation_name")
  lea_beds <- safe_col(raw_data, "lea_beds")
  lea_name <- safe_col(raw_data, "lea_name")

  # Subgroup
  subgroup_name <- safe_col(raw_data, "subgroup_name")

  # Membership (cohort type)
  membership_code_col <- raw_data$membership_code

  # Counts
  enroll_cnt <- cnt_to_num(safe_col(raw_data, "enroll_cnt"))
  grad_cnt <- cnt_to_num(safe_col(raw_data, "grad_cnt"))

  # Percentages
  grad_pct <- pct_to_num(safe_col(raw_data, "grad_pct"))

  # Build processed data frame
  processed <- data.frame(
    end_year = end_year,

    # Type from aggregation_type
    type = dplyr::case_when(
      agg_type == "Statewide" ~ "State",
      agg_type == "District" ~ "District",
      agg_type == "School" ~ "School",
      agg_type == "County" ~ "County",
      agg_type == "Need/Resource Category" ~ "NRC",
      TRUE ~ agg_type
    ),

    # District information
    district_id = dplyr::case_when(
      agg_type == "Statewide" ~ NA_character_,
      agg_type == "School" ~ substr(agg_code, 1, 6),  # Extract from school code
      agg_type == "District" ~ agg_code,  # Use district code directly
      agg_type == "NRC" ~ agg_code,  # NRCs have their own codes
      agg_type == "County" ~ agg_code,  # Counties have their own codes
      TRUE ~ substr(lea_beds, 1, 6)  # Fallback to lea_beds
    ),
    district_name = dplyr::case_when(
      agg_type == "Statewide" ~ NA_character_,
      agg_type == "School" ~ lea_name,  # Use LEA name for schools
      agg_type == "District" ~ agg_name,  # Use district name
      agg_type == "NRC" ~ agg_name,  # Use NRC name
      agg_type == "County" ~ agg_name,  # Use county name
      TRUE ~ lea_name  # Fallback to lea_name
    ),

    # School information (only for School type)
    school_id = dplyr::if_else(
      agg_type == "School",
      agg_code,
      NA_character_
    ),
    school_name = dplyr::if_else(
      agg_type == "School",
      agg_name,
      NA_character_
    ),

    # Subgroup
    subgroup = subgroup_name,
    subgroup_name = subgroup_name,  # Keep for mapping, remove later

    # Cohort information
    membership_code = membership_code_col,

    # Counts
    cohort_count = enroll_cnt,
    graduate_count = grad_cnt,

    # Graduation rate (as decimal 0-1)
    grad_rate = grad_pct,

    stringsAsFactors = FALSE
  )

  # Filter to requested cohort type
  if (!is.null(membership_code)) {
    processed <- processed[processed$membership_code == as.character(membership_code), ]
  }

  # Standardize subgroup names (using subgroup_name from original data)
  processed$subgroup <- dplyr::case_when(
    processed$subgroup_name == "All Students" ~ "all",
    processed$subgroup_name == "Male" ~ "male",
    processed$subgroup_name == "Female" ~ "female",
    processed$subgroup_name == "American Indian or Alaska Native" ~ "native_american",
    processed$subgroup_name == "Black or African American" ~ "black",
    processed$subgroup_name == "Hispanic or Latino" ~ "hispanic",
    processed$subgroup_name == "Asian or Native Hawaiian/Other Pacific Islander" ~ "asian_pacific_islander",
    processed$subgroup_name == "White" ~ "white",
    processed$subgroup_name == "Multiracial" ~ "multiracial",
    processed$subgroup_name == "General Education Students" ~ "general_ed",
    processed$subgroup_name == "Students with Disabilities" ~ "special_ed",
    processed$subgroup_name == "English Language Learner" ~ "english_learner",
    processed$subgroup_name == "Non-English Language Learner" ~ "english_proficient",
    processed$subgroup_name == "Economically Disadvantaged" ~ "economically_disadvantaged",
    processed$subgroup_name == "Not Economically Disadvantaged" ~ "not_economically_disadvantaged",
    processed$subgroup_name == "Migrant" ~ "migrant",
    processed$subgroup_name == "Not Migrant" ~ "not_migrant",
    processed$subgroup_name == "Homeless" ~ "homeless",
    processed$subgroup_name == "Not Homeless" ~ "not_homeless",
    processed$subgroup_name == "In Foster Care" ~ "foster_care",
    processed$subgroup_name == "Not in Foster Care" ~ "not_foster_care",
    processed$subgroup_name == "Parent in Armed Forces" ~ "military_connected",
    processed$subgroup_name == "Parent Not in Armed Forces" ~ "not_military_connected",
    processed$subgroup_name == "Nonbinary" ~ "nonbinary",
    is.na(processed$subgroup_name) ~ NA_character_,
    TRUE ~ tolower(gsub(" ", "_", processed$subgroup_name))
  )

  # Add aggregation level flags
  processed$is_state <- processed$type == "State"
  processed$is_district <- processed$type == "District"
  processed$is_school <- processed$type == "School"

  # Select final columns (14-column standard schema)
  # end_year, type, district_id, district_name, school_id, school_name,
  # subgroup, metric, grad_rate, cohort_count, graduate_count,
  # is_state, is_district, is_school

  processed$metric <- "grad_rate"

  # Select and order columns
  result <- processed[, c(
    "end_year", "type",
    "district_id", "district_name",
    "school_id", "school_name",
    "subgroup", "metric",
    "grad_rate", "cohort_count", "graduate_count",
    "is_state", "is_district", "is_school"
  )]

  # Remove rows with missing grad_rate (data quality)
  result <- result[!is.na(result$grad_rate), ]

  result
}
