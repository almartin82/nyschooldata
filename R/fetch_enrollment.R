# ==============================================================================
# Enrollment Data Fetching Functions
# ==============================================================================
#
# This file contains the main user-facing functions for downloading and
# processing enrollment data from the New York State Education Department
# (NYSED) website.
#
# ==============================================================================

#' Fetch New York enrollment data
#'
#' Downloads and processes enrollment data from the New York State Education
#' Department (NYSED) IRS Public School Enrollment archive.
#'
#' @param end_year A school year. Year is the end of the academic year - eg 2023-24
#'   school year is year '2024'. Valid values are 2012-2025.
#' @param level Data level: "school" (default) or "district"
#' @param tidy If TRUE (default), returns data in long (tidy) format with
#'   grade_level column. If FALSE, returns wide format.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#'   Set to FALSE to force re-download from NYSED.
#' @return Data frame with enrollment data
#' @export
#' @examples
#' \dontrun{
#' # Get 2024 enrollment data (2023-24 school year)
#' enr_2024 <- fetch_enr(2024)
#'
#' # Get wide format
#' enr_wide <- fetch_enr(2024, tidy = FALSE)
#'
#' # Get district-level data
#' enr_district <- fetch_enr(2024, level = "district")
#'
#' # Force fresh download (ignore cache)
#' enr_fresh <- fetch_enr(2024, use_cache = FALSE)
#' }
fetch_enr <- function(end_year, level = "school", tidy = TRUE, use_cache = TRUE) {

  # Validate year
  if (end_year < 1977 || end_year > 2025) {
    stop("end_year must be between 1977 and 2025")
  }

  # Validate level
  if (!level %in% c("school", "district")) {
    stop("level must be 'school' or 'district'")
  }

  # Determine cache type based on parameters
  cache_type <- paste0(level, "_", if (tidy) "tidy" else "wide")

  # Check cache first
  if (use_cache && cache_exists(end_year, cache_type)) {
    message(paste("Using cached data for", end_year))
    return(read_cache(end_year, cache_type))
  }

  message(paste("Downloading", level, "enrollment data for", end_year, "..."))

  # Get raw data
  raw <- get_raw_enr(end_year, level)

  # Process to standard schema
  processed <- process_enr(raw, end_year)

  # Optionally tidy
  if (tidy) {
    processed <- tidy_enr(processed)
  }

  # Cache the result
  if (use_cache) {
    write_cache(processed, end_year, cache_type)
    message(paste("Cached data for", end_year))
  }

  processed
}


#' Fetch enrollment data for multiple years
#'
#' Convenience function to download enrollment data for multiple years
#' and combine into a single data frame.
#'
#' @param years Vector of end years (e.g., 2020:2024)
#' @param level Data level: "school" or "district"
#' @param tidy If TRUE, returns tidy format
#' @param use_cache If TRUE, uses cache
#' @return Combined data frame with enrollment data for all years
#' @export
#' @examples
#' \dontrun{
#' # Get 5 years of data
#' enr_multi <- fetch_enr_years(2020:2024)
#'
#' # Get district-level data for multiple years
#' dist_multi <- fetch_enr_years(2020:2024, level = "district")
#' }
fetch_enr_years <- function(years, level = "school", tidy = TRUE, use_cache = TRUE) {

  results <- purrr::map(
    years,
    function(yr) {
      tryCatch({
        fetch_enr(yr, level = level, tidy = tidy, use_cache = use_cache)
      }, error = function(e) {
        warning(paste("Failed to fetch data for", yr, ":", e$message))
        NULL
      })
    }
  )

  # Remove NULL results and combine
  results <- results[!sapply(results, is.null)]

  if (length(results) == 0) {
    stop("No data could be fetched for the requested years")
  }

  dplyr::bind_rows(results)
}


#' Get enrollment for a specific school by BEDS code
#'
#' Convenience function to filter enrollment data to a single school.
#'
#' @param beds_code 12-digit BEDS code for the school
#' @param end_year School year end (or vector of years)
#' @param tidy If TRUE, returns tidy format
#' @param use_cache If TRUE, uses cache
#' @return Data frame with enrollment for the specified school
#' @export
#' @examples
#' \dontrun{
#' # Get enrollment for a specific school
#' school_enr <- fetch_enr_school("010100010018", 2024)
#'
#' # Get multiple years for a school
#' school_history <- fetch_enr_school("010100010018", 2020:2024)
#' }
fetch_enr_school <- function(beds_code, end_year, tidy = TRUE, use_cache = TRUE) {

  # Validate BEDS code
  if (!validate_beds_code(beds_code)) {
    stop("Invalid BEDS code format. Must be 12 digits.")
  }

  if (length(end_year) == 1) {
    enr <- fetch_enr(end_year, level = "school", tidy = tidy, use_cache = use_cache)
  } else {
    enr <- fetch_enr_years(end_year, level = "school", tidy = tidy, use_cache = use_cache)
  }

  enr %>%
    dplyr::filter(beds_code == !!beds_code)
}


#' Get enrollment for a specific district
#'
#' Convenience function to filter enrollment data to a single district.
#'
#' @param district_code 6-digit district code (or 12-digit district BEDS code)
#' @param end_year School year end (or vector of years)
#' @param level Data level: "school" to get all schools in district,
#'   "district" for district totals only
#' @param tidy If TRUE, returns tidy format
#' @param use_cache If TRUE, uses cache
#' @return Data frame with enrollment for the specified district
#' @export
#' @examples
#' \dontrun{
#' # Get all schools in a district
#' district_schools <- fetch_enr_district("010100", 2024)
#'
#' # Get district totals only
#' district_total <- fetch_enr_district("010100", 2024, level = "district")
#' }
fetch_enr_district <- function(district_code, end_year, level = "school",
                                tidy = TRUE, use_cache = TRUE) {

  # Handle 12-digit BEDS code (extract first 6 digits)
  if (nchar(district_code) == 12) {
    district_code <- substr(district_code, 1, 6)
  }

  # Validate district code
  if (!grepl("^\\d{6}$", district_code)) {
    stop("Invalid district code format. Must be 6 digits.")
  }

  if (length(end_year) == 1) {
    enr <- fetch_enr(end_year, level = level, tidy = tidy, use_cache = use_cache)
  } else {
    enr <- fetch_enr_years(end_year, level = level, tidy = tidy, use_cache = use_cache)
  }

  enr %>%
    dplyr::filter(district_code == !!district_code)
}


#' Get NYC enrollment data
#'
#' Convenience function to get enrollment data for NYC DOE schools only.
#'
#' @param end_year School year end (or vector of years)
#' @param level Data level: "school" or "district"
#' @param tidy If TRUE, returns tidy format
#' @param use_cache If TRUE, uses cache
#' @return Data frame with NYC enrollment data
#' @export
#' @examples
#' \dontrun{
#' # Get NYC school enrollment
#' nyc_enr <- fetch_enr_nyc(2024)
#' }
fetch_enr_nyc <- function(end_year, level = "school", tidy = TRUE, use_cache = TRUE) {

  if (length(end_year) == 1) {
    enr <- fetch_enr(end_year, level = level, tidy = tidy, use_cache = use_cache)
  } else {
    enr <- fetch_enr_years(end_year, level = level, tidy = tidy, use_cache = use_cache)
  }

  enr %>%
    dplyr::filter(is_nyc == TRUE)
}
