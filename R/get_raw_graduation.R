# ==============================================================================
# Raw Graduation Rate Data Download Functions - NYSED
# ==============================================================================
#
# This file contains functions for downloading raw graduation rate data from the
# New York State Education Department (NYSED) Data Site.
#
# Data source: NYSED Graduation Rate Database
# Available years: 2014-2024 (11 years)
# Format: ZIP files containing Microsoft Access (.mdb) databases
# Dependencies: mdbtools system package (mdb-export command)
#
# ==============================================================================

#' Base URL for NYSED graduation rate downloads
#' @keywords internal
NYSED_GRAD_BASE_URL <- "https://data.nysed.gov/files/gradrate"

#' Data cache directory for converted CSV files
#' @keywords internal
DATA_CACHE_DIR <- "data-cache"

#' Get available graduation years
#'
#' Returns a vector of years for which graduation rate data is available
#' from the New York State Education Department.
#'
#' @return Integer vector of years (2014-2024)
#' @export
#' @examples
#' \dontrun{
#' get_available_grad_years()
#' # Returns: 2014 2015 2016 ... 2024
#' }
get_available_grad_years <- function() {
  2014:2024
}

#' Build graduation rate download URL for a given year
#'
#' Constructs the appropriate URL based on the year's file naming pattern.
#'
#' @param end_year School year end (2023-24 = 2024)
#' @return URL to download ZIP file
#' @keywords internal
build_grad_url <- function(end_year) {

  if (end_year >= 2019) {
    # Pattern: /files/gradrate/YY-YY/gradrate.zip
    # e.g., 2024 -> 23-24
    start_year <- end_year - 2001
    end_short <- end_year - 2000
    url <- paste0(NYSED_GRAD_BASE_URL, "/", start_year, "-", end_short, "/gradrate.zip")

  } else if (end_year >= 2015) {
    # Pattern: /files/gradrate/YY-YY/gradrate_YYYY.zip
    start_year <- end_year - 2001
    end_short <- end_year - 2000
    url <- paste0(NYSED_GRAD_BASE_URL, "/", start_year, "-", end_short, "/gradrate_", end_year, ".zip")

  } else {
    # 2014: gradrate_2014.zip
    url <- paste0(NYSED_GRAD_BASE_URL, "/gradrate_", end_year, ".zip")
  }

  url
}

#' Extract .mdb filename from ZIP for a given year
#'
#' Returns the expected .mdb filename inside the ZIP.
#' Note: File naming patterns vary by year, this function tries multiple patterns.
#'
#' @param end_year School year end
#' @param temp_dir Directory where ZIP was extracted
#' @return .mdb filename (full path)
#' @keywords internal
get_mdb_filename <- function(end_year, temp_dir) {

  # Try multiple possible file name patterns
  possible_names <- c(
    paste0(end_year, "_GRADUATION_RATE.mdb"),
    paste0("GRAD_RATE_AND_OUTCOMES_", end_year, ".mdb"),
    paste0("gradrate_", end_year, ".mdb")
  )

  # Find which one exists
  for (name in possible_names) {
    full_path <- file.path(temp_dir, name)
    if (file.exists(full_path)) {
      return(full_path)
    }
  }

  # If none found, return NA (caller will handle error)
  NA_character_
}

#' Get cache path for converted CSV file
#'
#' @param end_year School year end
#' @return Path to cached CSV file
#' @keywords internal
get_grad_cache_path <- function(end_year) {
  file.path(DATA_CACHE_DIR, paste0("ny_grad_", end_year, ".csv"))
}

#' Check if mdbtools is available
#'
#' @return Logical indicating if mdb-export command is available
#' @keywords internal
check_mdbtools <- function() {

  mdb_path <- Sys.which("mdb-export")

  if (mdb_path == "" || !file.exists(mdb_path)) {
    return(FALSE)
  }

  # Test if it works
  result <- tryCatch({
    system2(mdb_path, "--help", stdout = FALSE, stderr = FALSE)
    TRUE
  }, error = function(e) {
    FALSE
  }, warning = function(w) {
    TRUE
  })

  result
}

#' Convert .mdb database to CSV
#'
#' Uses mdbtools mdb-export command to convert Access database to CSV.
#'
#' @param mdb_path Path to .mdb file
#' @param csv_path Path where CSV should be written
#' @return Invisibly returns TRUE on success
#' @keywords internal
convert_mdb_to_csv <- function(mdb_path, csv_path) {

  message("  Converting .mdb to CSV using mdb-export...")

  # Get table name
  result <- system2("mdb-tables", mdb_path, stdout = TRUE)
  table_name <- gsub("\\s.*$", "", result[1])  # First table, remove whitespace comments

  if (is.na(table_name) || table_name == "") {
    stop("Could not determine table name from .mdb file")
  }

  message("  Extracting table: ", table_name)

  # Convert to CSV
  exit_code <- system2(
    "mdb-export",
    args = c(mdb_path, table_name),
    stdout = csv_path,
    stderr = FALSE
  )

  if (exit_code != 0) {
    stop("Failed to convert .mdb to CSV using mdb-export")
  }

  # Verify file was created
  if (!file.exists(csv_path)) {
    stop("CSV file was not created")
  }

  file_size <- file.info(csv_path)$size
  message("  Created CSV: ", round(file_size / 1024 / 1024, 2), " MB")

  invisible(TRUE)
}

#' Download raw graduation data from NYSED
#'
#' Downloads graduation rate data ZIP file from NYSED, extracts the .mdb file,
#' converts it to CSV using mdbtools, and caches the result.
#'
#' @param end_year School year end (2023-24 = 2024). Valid years: 2014-2024.
#' @param force_refresh If TRUE, bypass cache and re-download/convert
#' @return Data frame with graduation data
#' @keywords internal
get_raw_graduation <- function(end_year, force_refresh = FALSE) {

  # Validate year
  available_years <- get_available_grad_years()
  if (!end_year %in% available_years) {
    stop("end_year must be between ", min(available_years), " and ",
         max(available_years), ". Run get_available_grad_years() to see available years.")
  }

  # Only support 2014+ for now
  if (end_year < 2014) {
    stop("Graduation data for years before 2014 is not currently supported.")
  }

  message(paste("Downloading NYSED graduation data for", end_year, "..."))

  # Check for mdbtools
  if (!check_mdbtools()) {
    stop(
      "mdbtools not found. Please install:\n",
      "  macOS: brew install mdbtools\n",
      "  Linux: sudo apt-get install mdbtools\n",
      "  Windows: https://github.com/mdbtools/mdbtools/releases"
    )
  }

  # Create cache directory
  if (!dir.exists(DATA_CACHE_DIR)) {
    dir.create(DATA_CACHE_DIR, recursive = TRUE)
  }

  # Check cache
  cache_path <- get_grad_cache_path(end_year)
  use_cache <- FALSE

  if (!force_refresh && file.exists(cache_path)) {
    # Check cache age (30 days)
    file_age <- as.numeric(difftime(Sys.time(), file.info(cache_path)$mtime, units = "days"))
    if (file_age <= 30) {
      message("  Using cached CSV (", round(file_age, 1), " days old)")
      use_cache <- TRUE
    } else {
      message("  Cache expired (", round(file_age, 1), " days old), re-downloading...")
    }
  }

  if (!use_cache) {
    # Build URL
    url <- build_grad_url(end_year)

    # Create temp directory
    temp_dir <- tempdir()
    temp_zip <- file.path(temp_dir, paste0("gradrate_", end_year, ".zip"))

    # Download ZIP file
    message("  Downloading ZIP file from NYSED (this may take a moment for large files)...")
    response <- tryCatch({
      httr::GET(
        url,
        httr::write_disk(temp_zip, overwrite = TRUE),
        httr::timeout(300),  # 5 minute timeout for large files
        httr::add_headers(Accept = "*/*")
      )
    }, error = function(e) {
      stop("Failed to connect to NYSED: ", e$message)
    })

    if (httr::http_error(response)) {
      stop(paste("HTTP error:", httr::status_code(response),
                 "\nFailed to download graduation data for", end_year))
    }

    # Verify it's a valid ZIP file
    file_info <- file.info(temp_zip)
    if (file_info$size < 1000) {
      stop("Downloaded file is too small to be a valid ZIP file.")
    }

    message("  Downloaded ", round(file_info$size / 1024 / 1024, 2), " MB")

    # Extract ZIP
    message("  Extracting .mdb file from ZIP...")
    extracted_files <- unzip(temp_zip, exdir = temp_dir, overwrite = TRUE)

    # Find .mdb file (try multiple patterns)
    mdb_path <- get_mdb_filename(end_year, temp_dir)

    if (is.na(mdb_path) || !file.exists(mdb_path)) {
      stop("Expected .mdb file not found in ZIP for year ", end_year,
           "\nAvailable files: ", paste(basename(extracted_files), collapse = ", "))
    }

    message("  Extracted: ", basename(mdb_path))

    # Convert .mdb to CSV
    convert_mdb_to_csv(mdb_path, cache_path)

    # Clean up temp files
    unlink(temp_zip)
    unlink(extracted_files)

    message("  Cached CSV:", cache_path)
  }

  # Read CSV
  message("  Reading CSV from cache...")
  df <- tryCatch({
    readr::read_csv(
      cache_path,
      col_types = readr::cols(.default = "c"),
      progress = FALSE,
      show_col_types = FALSE
    )
  }, error = function(e) {
    stop("Failed to read cached CSV file: ", e$message)
  })

  message("  Loaded ", nrow(df), " rows, ", ncol(df), " columns")

  # Add end_year column
  df$end_year <- end_year

  df
}
