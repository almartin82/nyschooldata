# ==============================================================================
# Assessment Data Fetching Functions
# ==============================================================================
#
# This file contains the main user-facing functions for fetching New York
# State assessment data.
#
# Available assessments:
# - NY State Tests (ELA, Math): Grades 3-8
# - NY State Science Test: Grade 8
#
# Available years: 2014-2019, 2021-2025 (no 2020 due to COVID)
#
# ==============================================================================


#' Fetch New York State assessment data
#'
#' Downloads and returns assessment data from the New York State Education
#' Department (NYSED). Includes NY State Tests for ELA, Math (grades 3-8),
#' and Science (grade 8).
#'
#' Assessment proficiency levels:
#' - **Level 1**: Did Not Meet Standards
#' - **Level 2**: Partially Met Standards
#' - **Level 3**: Met Standards (proficient)
#' - **Level 4**: Exceeded Standards (proficient)
#'
#' @param end_year School year end (2023-24 = 2024). Valid range: 2014-2025
#'   (excluding 2020).
#' @param subject Subject to fetch: "ela", "math", "science", or "all" (default)
#' @param tidy If TRUE (default), returns data in long (tidy) format with
#'   proficiency_level column. If FALSE, returns wide format with separate
#'   level columns.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#' @return Data frame with assessment data
#' @export
#' @examples
#' \dontrun{
#' # Get 2024 assessment data for all subjects
#' assess_2024 <- fetch_assessment(2024)
#'
#' # Get only ELA data in wide format
#' ela_wide <- fetch_assessment(2024, subject = "ela", tidy = FALSE)
#'
#' # Get math data for multiple years
#' math_multi <- fetch_assessment_multi(2021:2024, subject = "math")
#'
#' # Filter to state-level ELA results
#' state_ela <- assess_2024 |>
#'   dplyr::filter(is_state, subject == "ELA")
#' }
fetch_assessment <- function(end_year, subject = "all", tidy = TRUE, use_cache = TRUE) {

  # Get available years
  available <- get_available_assessment_years()

  # Special handling for 2020 (COVID waiver year)
  if (end_year == 2020) {
    stop("2020 assessment data is not available due to COVID-19 testing waiver. ",
         "No statewide testing was administered in Spring 2020.")
  }

  # Validate year
  if (!end_year %in% available$years) {
    stop(paste0(
      "end_year must be one of: ", paste(available$years, collapse = ", "), ". ",
      "Got: ", end_year, "\n",
      "Note: 2020 had no testing due to COVID-19 pandemic."
    ))
  }

  # Validate subject
  subject <- tolower(subject)
  valid_subjects <- c("ela", "math", "science", "all")
  if (!subject %in% valid_subjects) {
    stop("subject must be one of: ", paste(valid_subjects, collapse = ", "))
  }

  # Determine cache type
  cache_type <- if (tidy) {
    paste0("assessment_tidy_", subject)
  } else {
    paste0("assessment_wide_", subject)
  }

  # Check cache first
  if (use_cache && cache_exists(end_year, cache_type)) {
    message(paste("Using cached assessment data for", end_year))
    return(read_cache(end_year, cache_type))
  }

  # Get raw data
  raw <- get_raw_assessment(end_year, subject = subject)

  # Check if data was returned
  if (nrow(raw) == 0) {
    warning(paste("No assessment data available for year", end_year))
    return(data.frame())
  }

  # Process to standard schema
  processed <- process_assessment(raw, end_year)

  # Optionally tidy
  if (tidy) {
    result <- tidy_assessment(processed)
  } else {
    result <- processed
  }

  # Cache the result
  if (use_cache) {
    write_cache(result, end_year, cache_type)
  }

  result
}


#' Fetch assessment data for multiple years
#'
#' Downloads and combines assessment data for multiple school years.
#' Note: 2020 is automatically excluded (COVID-19 testing waiver).
#'
#' @param end_years Vector of school year ends (e.g., c(2022, 2023, 2024))
#' @param subject Subject to fetch: "ela", "math", "science", or "all" (default)
#' @param tidy If TRUE (default), returns data in long (tidy) format.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#' @return Combined data frame with assessment data for all requested years
#' @export
#' @examples
#' \dontrun{
#' # Get 3 years of data
#' assess_multi <- fetch_assessment_multi(2022:2024)
#'
#' # Track ELA proficiency trends at state level
#' assess_multi |>
#'   dplyr::filter(is_state, subject == "ELA", grade == "3-8",
#'                 subgroup_name == "All Students", is_proficient) |>
#'   dplyr::group_by(end_year) |>
#'   dplyr::summarize(pct_proficient = sum(pct, na.rm = TRUE))
#' }
fetch_assessment_multi <- function(end_years, subject = "all", tidy = TRUE, use_cache = TRUE) {

  # Get available years
  available <- get_available_assessment_years()

  # Remove 2020 if present (COVID waiver year)
  if (2020 %in% end_years) {
    warning("2020 excluded: No assessment data due to COVID-19 testing waiver.")
    end_years <- end_years[end_years != 2020]
  }

  # Validate years
  invalid_years <- end_years[!end_years %in% available$years]
  if (length(invalid_years) > 0) {
    stop(paste0(
      "Invalid years: ", paste(invalid_years, collapse = ", "), "\n",
      "Valid years are: ", paste(available$years, collapse = ", ")
    ))
  }

  if (length(end_years) == 0) {
    stop("No valid years to fetch")
  }

  # Fetch each year
  results <- purrr::map(
    end_years,
    function(yr) {
      message(paste("Fetching", yr, "..."))
      tryCatch({
        fetch_assessment(yr, subject = subject, tidy = tidy, use_cache = use_cache)
      }, error = function(e) {
        warning(paste("Failed to fetch year", yr, ":", e$message))
        data.frame()
      })
    }
  )

  # Combine, filtering out empty data frames
  results <- results[!sapply(results, function(x) nrow(x) == 0)]

  if (length(results) == 0) {
    warning("No data could be fetched for the requested years")
    return(data.frame())
  }

  dplyr::bind_rows(results)
}


#' Get assessment data for a specific district
#'
#' Convenience function to fetch and filter assessment data for a single district.
#'
#' @param end_year School year end
#' @param district_cd 12-digit district code (e.g., "010100010000" for Albany City)
#' @param subject Subject filter: "ela", "math", "science", or "all"
#' @param tidy If TRUE (default), returns tidy format
#' @param use_cache If TRUE (default), uses cached data
#' @return Data frame filtered to specified district
#' @export
#' @examples
#' \dontrun{
#' # Get Albany City School District assessment data
#' albany_assess <- fetch_district_assessment(2024, "010100010000")
#'
#' # Get NYC district assessment data for ELA only
#' nyc_ela <- fetch_district_assessment(2024, "310200010000", subject = "ela")
#' }
fetch_district_assessment <- function(end_year, district_cd, subject = "all",
                                      tidy = TRUE, use_cache = TRUE) {

  # Fetch all data (we need to filter from the full dataset)
  df <- fetch_assessment(end_year, subject = subject, tidy = tidy, use_cache = use_cache)

  if (nrow(df) == 0) {
    return(df)
  }

  # Filter to requested district (both district and school rows)
  if ("district_cd" %in% names(df)) {
    df |>
      dplyr::filter(.data$district_cd == !!district_cd | .data$entity_cd == !!district_cd)
  } else if ("entity_cd" %in% names(df)) {
    # Filter by entity_cd matching district or starting with district prefix
    district_prefix <- substr(district_cd, 1, 8)
    df |>
      dplyr::filter(
        .data$entity_cd == !!district_cd |
        (nchar(.data$entity_cd) == 12 & substr(.data$entity_cd, 1, 8) == !!district_prefix)
      )
  } else {
    df
  }
}


#' Get assessment data for a specific school
#'
#' Convenience function to fetch and filter assessment data for a single school.
#'
#' @param end_year School year end
#' @param school_cd 12-digit school code
#' @param subject Subject filter: "ela", "math", "science", or "all"
#' @param tidy If TRUE (default), returns tidy format
#' @param use_cache If TRUE (default), uses cached data
#' @return Data frame filtered to specified school
#' @export
#' @examples
#' \dontrun{
#' # Get a specific school's assessment data
#' school_assess <- fetch_school_assessment(2024, "010100010001")
#' }
fetch_school_assessment <- function(end_year, school_cd, subject = "all",
                                    tidy = TRUE, use_cache = TRUE) {

  # Fetch all data
  df <- fetch_assessment(end_year, subject = subject, tidy = tidy, use_cache = use_cache)

  if (nrow(df) == 0) {
    return(df)
  }

  # Filter to requested school
  if ("entity_cd" %in% names(df)) {
    df |>
      dplyr::filter(.data$entity_cd == !!school_cd)
  } else {
    df
  }
}
