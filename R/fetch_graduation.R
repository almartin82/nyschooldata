# ==============================================================================
# Graduation Rate Data Fetching Functions
# ==============================================================================
#
# This file contains functions for downloading graduation rate data from the
# New York State Education Department (NYSED).
#
# Data source: NYSED Data Site - Graduation Rate Database
# Available years: 2014-2024 (see get_available_grad_years())
#
# ==============================================================================

#' Fetch New York graduation rate data
#'
#' Downloads and processes graduation rate data from the New York State
#' Education Department (NYSED) Data Site.
#'
#' Note: This function requires mdbtools to be installed on your system.
#' See https://github.com/mdbtools/mdbtools for installation instructions.
#'
#' @param end_year A school year. Year is the end of the academic year - eg 2023-24
#'   school year is year '2024'. Valid values are 2014-2024.
#' @param tidy If TRUE (default), returns data in long (tidy) format with
#'   subgroup column. If FALSE, returns wide format.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#'   Set to FALSE to force re-download and re-conversion from NYSED.
#' @param membership_code Optional membership code for cohort type.
#'   Default is 9 (4-year June outcome). Other options:
#'   6 (6-year June), 8 (5-year June), 10 (5-year August), 11 (4-year August).
#' @return Data frame with graduation rate data. Includes columns for
#'   end_year, type, district_id, district_name, school_id, school_name,
#'   subgroup, metric, grad_rate, cohort_count, graduate_count,
#'   is_state, is_district, is_school.
#' @export
#' @examples
#' \dontrun{
#' # Get 2024 graduation data (2023-24 school year)
#' grad_2024 <- fetch_graduation(2024)
#'
#' # Get historical data from 2018
#' grad_2018 <- fetch_graduation(2018)
#'
#' # Get wide format
#' grad_wide <- fetch_graduation(2024, tidy = FALSE)
#'
#' # Force fresh download (ignore /data-cache)
#' grad_fresh <- fetch_graduation(2024, use_cache = FALSE)
#'
#' # Get 5-year cohort rate instead of 4-year
#' grad_5year <- fetch_graduation(2024, membership_code = 8)
#'
#' # Compare district rates
#' grad_2024 |>
#'   dplyr::filter(is_district, subgroup == "all") |>
#'   dplyr::select(district_name, grad_rate, cohort_count) |>
#'   dplyr::arrange(dplyr::desc(grad_rate))
#' }
fetch_graduation <- function(end_year, tidy = TRUE, use_cache = TRUE, membership_code = 9) {

  # Validate year
  available_years <- get_available_grad_years()
  if (!end_year %in% available_years) {
    stop(paste0(
      "end_year must be between ", min(available_years), " and ", max(available_years), ". ",
      "Run get_available_grad_years() to see available years."
    ))
  }

  # Only support 2014+ for now
  if (end_year < 2014) {
    stop("Graduation data for years before 2014 is not currently supported. ",
         "Please use years 2014-2024.")
  }

  # Determine cache type based on tidy parameter
  cache_type <- if (tidy) "grad_tidy" else "grad_wide"

  # Check grad_tidy/grad_wide cache first (for processed data)
  if (use_cache) {
    # Build cache path manually to avoid function call issues
    cache_dir <- get_cache_dir()
    prefix <- "grad_"
    cache_path <- file.path(cache_dir, paste0(prefix, cache_type, "_", end_year, ".rds"))

    if (file.exists(cache_path)) {
      # Check cache age (30 days)
      file_age <- as.numeric(difftime(Sys.time(), file.info(cache_path)$mtime, units = "days"))
      if (file_age <= 30) {
        message(paste("Using processed cached data for", end_year))
        return(read_cache(end_year, cache_type))
      }
    }
  }

  # Get raw data from NYSED (uses /data-cache for CSV)
  force_refresh <- !use_cache
  raw <- get_raw_graduation(end_year, force_refresh = force_refresh)

  # Process to standard schema
  processed <- process_graduation(raw, end_year, membership_code = membership_code)

  # Optionally tidy
  if (tidy) {
    processed <- tidy_graduation(processed)
  }

  # Cache the processed data (separate from /data-cache)
  if (use_cache) {
    write_cache(processed, end_year, cache_type)
  }

  processed
}


#' Fetch graduation rate data for multiple years
#'
#' Downloads and combines graduation rate data for multiple school years.
#'
#' @param end_years Vector of school year ends (e.g., c(2020, 2021, 2022))
#' @param tidy If TRUE (default), returns data in long (tidy) format.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#' @param membership_code Optional membership code for cohort type.
#'   Default is 9 (4-year June outcome).
#' @return Combined data frame with graduation rate data for all requested years
#' @export
#' @examples
#' \dontrun{
#' # Get 5 years of data
#' grad_multi <- fetch_graduation_multi(2020:2024)
#'
#' # Track graduation rate trends
#' grad_multi |>
#'   dplyr::filter(is_state, subgroup == "all") |>
#'   dplyr::select(end_year, grad_rate, cohort_count)
#'
#' # Compare NYC vs rest of state over time
#' grad_multi |>
#'   dplyr::filter(subgroup == "all", type %in% c("State", "NRC")) |>
#'   dplyr::select(end_year, type, grad_rate)
#' }
fetch_graduation_multi <- function(end_years, tidy = TRUE, use_cache = TRUE,
                                    membership_code = 9) {

  # Validate years
  available_years <- get_available_grad_years()
  invalid_years <- end_years[!end_years %in% available_years]
  if (length(invalid_years) > 0) {
    stop(paste("Invalid years:", paste(invalid_years, collapse = ", "),
               "\nAvailable years:", paste(range(available_years), collapse = "-")))
  }

  # Check for years before 2014
  old_years <- end_years[end_years < 2014]
  if (length(old_years) > 0) {
    stop("Graduation data for years before 2014 is not currently supported: ",
         paste(old_years, collapse = ", "))
  }

  # Fetch each year
  results <- purrr::map(
    end_years,
    function(yr) {
      message(paste("Fetching", yr, "..."))
      fetch_graduation(yr, tidy = tidy, use_cache = use_cache,
                       membership_code = membership_code)
    }
  )

  # Combine
  dplyr::bind_rows(results)
}


#' Clear graduation rate cache
#'
#' Removes all cached graduation rate data files from both the
# processed data cache and the /data-cache directory.
#'
#' @param years Optional vector of years to clear. If NULL, clears all years.
#' @param clear_data_cache If TRUE (default), also clears /data-cache CSV files.
#' @return Invisibly returns the number of files removed
#' @export
#' @examples
#' \dontrun{
#' # Clear all graduation cache (both processed and data-cache)
#' clear_grad_cache()
#'
#' # Clear only 2024 data
#' clear_grad_cache(2024)
#'
#' # Clear multiple years
#' clear_grad_cache(2020:2024)
#'
#' # Clear only processed cache, keep /data-cache
#' clear_grad_cache(clear_data_cache = FALSE)
#' }
clear_grad_cache <- function(years = NULL, clear_data_cache = TRUE) {

  total_removed <- 0

  # Clear processed data cache (grad_tidy/grad_wide)
  cache_dir <- get_cache_dir()

  if (!is.null(years)) {
    # Clear specific years
    patterns <- paste0("grad_.*_", years, "\\.rds$")
    files <- unlist(lapply(patterns, function(p) {
      list.files(cache_dir, pattern = p, full.names = TRUE)
    }))
  } else {
    # Clear all grad cache files
    files <- list.files(cache_dir, pattern = "^grad_.*\\.rds$", full.names = TRUE)
  }

  if (length(files) > 0) {
    file.remove(files)
    message(paste("Removed", length(files), "processed cached file(s)"))
    total_removed <- total_removed + length(files)
  }

  # Clear /data-cache CSV files
  if (clear_data_cache) {
    if (dir.exists("data-cache")) {
      if (!is.null(years)) {
        patterns <- paste0("ny_grad_", years, "\\.csv$")
        data_files <- unlist(lapply(patterns, function(p) {
          list.files("data-cache", pattern = p, full.names = TRUE)
        }))
      } else {
        data_files <- list.files("data-cache", pattern = "^ny_grad_.*\\.csv$", full.names = TRUE)
      }

      if (length(data_files) > 0) {
        file.remove(data_files)
        message(paste("Removed", length(data_files), "/data-cache CSV file(s)"))
        total_removed <- total_removed + length(data_files)
      }
    }
  }

  if (total_removed == 0) {
    message("No graduation cache files to remove")
  }

  invisible(total_removed)
}
