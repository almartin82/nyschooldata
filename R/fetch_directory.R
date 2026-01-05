# ==============================================================================
# School Directory Data Fetching Functions
# ==============================================================================
#
# This file contains functions for fetching New York school directory data
# from NYSED's SEDREF COGNOS reports system. Data includes school and district
# contact information for all New York State schools (including NYC).
#
# Data source: NYSED SEDREF COGNOS Public Reports Portal
# - Portal: https://eservices.nysed.gov/sedreports/
# - Main report used: "School Districts, Public, Nonpublic & Charter Schools:
#   CEO Info for Active School Districts, Public, Non Public & Charter Schools"
#
# Available years: Current year only (directory data is refreshed nightly)
#
# ==============================================================================


#' Fetch New York school directory data
#'
#' Downloads and returns school directory data from NYSED's SEDREF system.
#' This includes contact information for all NY public schools, districts,
#' charter schools, and nonpublic schools (including NYC).
#'
#' @param end_year School year end (2023-24 = 2024). Only current year data
#'   is available from SEDREF COGNOS reports. Defaults to current year.
#' @param tidy If TRUE (default), returns data in standardized format with
#'   consistent column names.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#' @return A tibble with school directory information including:
#'   \itemize{
#'     \item \code{end_year}: School year end (e.g., 2024 for 2023-24)
#'     \item \code{state_school_id}: BEDS code for school
#'     \item \code{state_district_id}: BEDS code for district
#'     \item \code{school_name}: School name
#'     \item \code{district_name}: District name
#'     \item \code{school_type}: School type (Elementary, Middle, High, etc.)
#'     \item \code{grades_served}: Grade levels served
#'     \item \code{address}: Street address
#'     \item \code{city}: City
#'     \item \code{state}: State (NY)
#'     \item \code{zip}: ZIP code
#'     \item \code{phone}: Phone number
#'     \item \code{principal_name}: Principal/CEO name
#'     \item \code{principal_email}: Principal/CEO email (if available)
#'     \item \code{superintendent_name}: Superintendent name (for districts)
#'     \item \code{superintendent_email}: Superintendent email (if available)
#'   }
#' @export
#' @examples
#' \dontrun{
#' # Get most recent directory data
#' dir_2024 <- fetch_directory(2024)
#'
#' # Force fresh download (bypass cache)
#' dir_fresh <- fetch_directory(2024, use_cache = FALSE)
#' }
fetch_directory <- function(end_year = NULL, tidy = TRUE, use_cache = TRUE) {

  # Default to current year if not specified
  if (is.null(end_year)) {
    end_year <- as.integer(format(Sys.Date(), "%Y"))
  }

  # Validate year - NYSED SEDREF only provides current data
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  if (end_year < current_year - 1 || end_year > current_year) {
    warning(paste0(
      "SEDREF COGNOS reports only provide current directory data.\n",
      "Requested year ", end_year, " may not be available. ",
      "Using current report (refreshed nightly)."
    ))
  }

  # Check cache first
  cache_key <- paste0("directory_", end_year)
  if (use_cache && cache_exists(end_year, "directory")) {
    message(paste("Using cached directory data for", end_year))
    return(read_cache(end_year, "directory"))
  }

  # Get raw data
  raw <- get_raw_directory(end_year)

  # Process if tidy requested
  if (tidy) {
    result <- process_directory(raw)
    result$end_year <- end_year
  } else {
    # Return raw data with end_year column
    raw$end_year <- end_year
    result <- raw
  }

  # Cache the result
  if (use_cache && tidy) {
    write_cache(result, end_year, "directory")
  }

  result
}


#' Download raw school directory data from SEDREF COGNOS
#'
#' Downloads the CEO contact information report from NYSED's SEDREF
#' COGNOS public reports portal. This report includes schools, districts,
#' charter schools, and nonpublic schools.
#'
#' @param end_year School year end (not used - SEDREF provides current data)
#' @return Data frame with raw directory data from SEDREF
#' @keywords internal
get_raw_directory <- function(end_year) {

  message("Downloading NY school directory data from SEDREF COGNOS...")

  # Use the known working report URL with reportId
  # Report: "School Districts & Public Schools: Active School Districts &
  #          Public Schools listed within each BOCES with CEO Info"
  # This report includes both districts and schools with contact info
  report_url <- "https://eservices.nysed.gov/sedreports/view"

  # URL-encoded report path (double-encoded as needed by COGNOS)
  report_path <- "/content/folder[@name='NYSED Reports']/folder[@name='SEDREF']/folder[@name='SEDREF Reports for Public Website']/report[@name='School Districts & Public Schools: Active School Districts & Public Schools listed within each BOCES with CEO Info']"

  # Double URL-encode the report path (COGNOS requires this)
  report_path_encoded <- URLencode(URLencode(report_path, reserved = TRUE), reserved = TRUE)

  # Known reportId for this specific report
  report_id <- "iA5152A0B15F644F9BD84F5082B894805"

  # Build query parameters
  query_params <- list(
    rpt = report_path_encoded,
    format = "CSV",
    reportId = report_id
  )

  # Download to temp file
  temp_file <- tempfile(pattern = "ny_directory_", fileext = ".csv")

  tryCatch({
    message("  Fetching report from SEDREF COGNOS portal...")
    response <- httr::GET(
      report_url,
      query = query_params,
      httr::write_disk(temp_file, overwrite = TRUE),
      httr::timeout(120),
      httr::user_agent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36")
    )

    if (httr::http_error(response)) {
      status <- httr::status_code(response)
      stop(paste("Failed to download SEDREF directory report. HTTP status:", status))
    }

    # Check if we got a CSV or an HTML error page
    content_type <- httr::headers(response)$`content-type`
    first_bytes <- readLines(temp_file, n = 1, warn = FALSE)

    if (grepl("text/html", content_type, ignore.case = TRUE) ||
        grepl("^<!DOCTYPE", first_bytes, ignore.case = TRUE) ||
        grepl("^<html", first_bytes, ignore.case = TRUE)) {
      stop("Received HTML instead of CSV - SEDREF portal may be blocking requests")
    }

    # Parse CSV
    message("  Parsing CSV data...")
    df <- utils::read.csv(
      temp_file,
      stringsAsFactors = FALSE,
      check.names = FALSE,
      na.strings = c("", "NA", "N/A", "NULL")
    )

    unlink(temp_file)

    # Clean column names
    names(df) <- clean_column_names(names(df))

    message("  Download complete: ", nrow(df), " schools/districts")

    df

  }, error = function(e) {
    message(paste("  Error downloading directory data:", e$message))
    if (file.exists(temp_file)) unlink(temp_file)
    stop(paste("Failed to fetch NY school directory:", e$message))
  })
}


#' Process raw directory data into standardized format
#'
#' Transforms the raw SEDREF COGNOS data into the standardized directory
#' schema expected by the package.
#'
#' @param raw Data frame with raw SEDREF directory data
#' @return Tibble with standardized directory data
#' @keywords internal
process_directory <- function(raw) {

  if (is.null(raw) || nrow(raw) == 0) {
    stop("No directory data to process")
  }

  # Map SEDREF columns to standard schema
  # SEDREF COGNOS report columns (based on NYSED documentation):
  # - Institution Name (school/district name)
  # - BEDS Code (state identifier)
  # - Institution Type (district/school/charter/nonpublic)
  # - Physical Address Line 1
  # - City
  # - State
  # - ZIP Code
  # - Phone
  # - CEO Name (principal/superintendent)
  # - CEO Email
  # - Grade Organization (grades served)
  # - County
  # - Superintendent Name (for districts)

  result <- data.frame(stringsAsFactors = FALSE)

  # Extract and map columns
  result$state_school_id <- extract_column(raw, c("beds_code", "beds", "institution_code",
                                                   "state_school_id", "school_code"))
  result$state_district_id <- extract_district_id(result$state_school_id, raw)

  result$school_name <- extract_column(raw, c("institution_name", "school_name",
                                               "name", "institution"))
  result$district_name <- extract_district_name(raw, result$state_district_id)

  result$school_type <- extract_column(raw, c("institution_type", "school_type",
                                               "type", "grade_organization"))
  result$grades_served <- extract_column(raw, c("grade_organization", "grades",
                                                "grades_served", "grade_org"))

  result$address <- extract_column(raw, c("physical_address_line_1", "address",
                                           "street_address", "physical_address"))
  result$city <- extract_column(raw, c("city"))
  result$state <- extract_column(raw, c("state")) %||% "NY"
  result$zip <- extract_column(raw, c("zip_code", "zip", "postal_code"))

  result$phone <- extract_column(raw, c("phone", "phone_number", "telephone"))

  result$principal_name <- extract_column(raw, c("ceo_name", "principal_name",
                                                  "chief_executive", "ceo"))
  result$principal_email <- extract_column(raw, c("ceo_email", "principal_email",
                                                   "email", "email_address"))

  result$superintendent_name <- extract_column(raw, c("superintendent_name",
                                                       "superintendent",
                                                       "district_superintendent"))
  result$superintendent_email <- extract_column(raw, c("superintendent_email",
                                                         "supt_email",
                                                         "district_email"))

  # Remove district-only rows (keep only schools)
  # SEDREF includes both districts and schools in the same report
  result <- filter_schools_only(result)

  # Add NCES IDs if available (SEDREF may include them)
  result$nces_school_id <- extract_column(raw, c("nces_school_id", "nces_id"))
  result$nces_district_id <- extract_column(raw, c("nces_district_id"))

  # Ensure all expected columns exist
  expected_cols <- c(
    "state_school_id", "state_district_id", "nces_school_id", "nces_district_id",
    "school_name", "district_name", "school_type", "grades_served",
    "address", "city", "state", "zip", "phone",
    "principal_name", "principal_email",
    "superintendent_name", "superintendent_email"
  )

  for (col in expected_cols) {
    if (!col %in% names(result)) {
      result[[col]] <- NA_character_
    }
  }

  # Select and order columns
  result <- result[, expected_cols]

  # Format BEDS codes with leading zeros
  result$state_school_id <- format_beds_code(result$state_school_id)
  result$state_district_id <- format_beds_code(result$state_district_id)

  # Remove duplicates
  result <- result[!duplicated(result$state_school_id) |
                   is.na(result$state_school_id), ]

  dplyr::as_tibble(result)
}


#' Extract column from data frame with multiple possible names
#'
#' @param df Data frame
#' @param possible_names Character vector of possible column names
#' @return Column values or NA if not found
#' @keywords internal
extract_column <- function(df, possible_names) {

  for (name in possible_names) {
    # Case-insensitive match
    idx <- which(tolower(names(df)) == tolower(name))
    if (length(idx) > 0) {
      return(df[[idx[1]]])
    }
  }

  NA_character_
}


#' Null coalescing operator
#'
#' Returns left side if not null, otherwise right side
#'
#' @param left Left value
#' @param right Right value (default)
#' @return left if not null/NA, else right
#' @keywords internal
`%||%` <- function(left, right) {
  if (is.null(left) || all(is.na(left))) {
    right
  } else {
    left
  }
}


#' Extract district ID from school data
#'
#' NY BEDS codes: 12-digit format
#' - First 6 digits: District code
#' - Last 6 digits: School code (000000 for districts themselves)
#'
#' @param school_ids Vector of school BEDS codes
#' @param raw Raw data frame (for fallback)
#' @return District BEDS codes
#' @keywords internal
extract_district_id <- function(school_ids, raw) {

  # Try to extract from BEDS code first
  if (!all(is.na(school_ids))) {
    # BEDS codes are 12 digits: first 6 are district
    # Format: DDDDDCSSSSSS where D=district, C=county, S=school
    district_codes <- substr(school_ids, 1, 6)
    return(district_codes)
  }

  # Fallback: try to find district column in raw data
  district_col <- extract_column(raw, c("district_beds_code", "district_code",
                                         "district_id", "leaid"))
  if (!all(is.na(district_col))) {
    return(as.character(district_col))
  }

  NA_character_
}


#' Extract district name from data
#'
#' @param raw Raw data frame
#' @param district_ids District BEDS codes
#' @return District names
#' @keywords internal
extract_district_name <- function(raw, district_ids) {

  # Try district name column
  district_name <- extract_column(raw, c("district_name", "school_district_name",
                                          "lea_name", "district"))

  if (!all(is.na(district_name))) {
    return(district_name)
  }

  # For NYC, the district name is often embedded in institution name
  # or we use "New York City Public Schools" as default
  nyc_mask <- grepl("^8[0-9]{5}", district_ids)  # NYC districts start with 8
  if (any(nyc_mask, na.rm = TRUE)) {
    district_name[nyc_mask & is.na(district_name)] <- "New York City Public Schools"
  }

  district_name
}


#' Filter to keep only schools (remove district-only rows)
#'
#' SEDREF reports include both districts and schools. District rows typically
#' have school code ending in 000000.
#'
#' @param df Data frame with school and district rows
#' @return Data frame with school rows only
#' @keywords internal
filter_schools_only <- function(df) {

  # Remove rows where school_id is district-only (ends in 000000)
  if ("state_school_id" %in% names(df)) {
    # Keep schools (last 6 digits not all zeros) OR keep if it's the only data we have
    is_school <- !grepl("000000$", df$state_school_id) | is.na(df$state_school_id)

    # Also keep rows that look like schools based on name
    has_school_name <- grepl("school|elementary|middle|high|academy|center",
                             df$school_name, ignore.case = TRUE)

    df <- df[is_school | has_school_name, ]
  }

  df
}


#' Format BEDS code with leading zeros
#'
#' NY BEDS codes are 12 digits. Ensure proper formatting.
#'
#' @param beds_code BEDS code (character or numeric)
#' @return Character BEDS code padded to 12 digits
#' @keywords internal
format_beds_code <- function(beds_code) {

  beds_code <- as.character(beds_code)

  # Remove any non-numeric characters
  beds_code <- gsub("[^0-9]", "", beds_code)

  # Pad to 12 digits
  beds_code <- ifelse(nchar(beds_code) > 0,
                      sprintf("%012s", beds_code),
                      NA_character_)

  beds_code
}


#' Get available years for directory data
#'
#' Returns information about directory data availability.
#' NYSED SEDREF COGNOS reports only provide current data (refreshed nightly).
#'
#' @return A list with min_year, max_year, and description
#' @export
#' @examples
#' get_directory_years()
get_directory_years <- function() {
  current_year <- as.integer(format(Sys.Date(), "%Y"))

  list(
    min_year = current_year - 1,
    max_year = current_year,
    description = paste0(
      "School directory data is available from NYSED's SEDREF COGNOS reports. ",
      "Only current year data is available (reports are refreshed nightly). ",
      "Historical directory data is not available through this system. ",
      "For archival data, contact NYSED directly."
    ),
    data_source = "NYSED SEDREF COGNOS Public Reports Portal",
    url = "https://eservices.nysed.gov/sedreports/",
    refresh_frequency = "Nightly"
  )
}


#' Clean column names
#'
#' Converts column names to lowercase and replaces special characters
#' with underscores.
#'
#' @param names Character vector of column names
#' @return Cleaned column names
#' @keywords internal
clean_column_names <- function(names) {
  # Convert to lowercase
  names <- tolower(names)

  # Replace spaces and special characters with underscores
  names <- gsub("[^a-z0-9]+", "_", names)

  # Remove leading/trailing underscores
  names <- gsub("^_|_$", "", names)

  # Replace multiple underscores with single
  names <- gsub("_+", "_", names)

  names
}
