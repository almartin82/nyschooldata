# ==============================================================================
# Data Caching Functions
# ==============================================================================
#
# Functions for caching downloaded NYSED data files to avoid repeated downloads.
#
# ==============================================================================

#' Get the cache directory for nyschooldata
#'
#' Returns the path to the cache directory, creating it if necessary.
#' Uses rappdirs for cross-platform cache location.
#'
#' @return Path to cache directory
#' @keywords internal
get_cache_dir <- function() {
  cache_dir <- file.path(
    rappdirs::user_cache_dir("nyschooldata"),
    "data"
  )

  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }

  cache_dir
}


#' Get cached file path for a given year
#'
#' @param end_year School year end
#' @param type File type ("raw" or "processed" or "tidy")
#' @return Path to cached file
#' @keywords internal
get_cache_path <- function(end_year, type = "raw") {
  cache_dir <- get_cache_dir()
  file.path(cache_dir, paste0("enr_", type, "_", end_year, ".rds"))
}


#' Check if cached data exists and is valid
#'
#' @param end_year School year end
#' @param type File type
#' @param max_age Maximum age in days (default 30)
#' @return TRUE if valid cache exists
#' @keywords internal
cache_exists <- function(end_year, type = "raw", max_age = 30) {
  cache_path <- get_cache_path(end_year, type)

  if (!file.exists(cache_path)) {
    return(FALSE)
  }

  # Check age
  file_info <- file.info(cache_path)
  age_days <- as.numeric(difftime(Sys.time(), file_info$mtime, units = "days"))

  age_days <= max_age
}


#' Read data from cache
#'
#' @param end_year School year end
#' @param type File type
#' @return Cached data frame
#' @keywords internal
read_cache <- function(end_year, type = "raw") {
  cache_path <- get_cache_path(end_year, type)
  readRDS(cache_path)
}


#' Write data to cache
#'
#' @param data Data frame to cache
#' @param end_year School year end
#' @param type File type
#' @keywords internal
write_cache <- function(data, end_year, type = "raw") {
  cache_path <- get_cache_path(end_year, type)
  saveRDS(data, cache_path)
  invisible(cache_path)
}


#' Clear the nyschooldata cache
#'
#' Removes all cached data files.
#'
#' @param years Optional vector of years to clear. If NULL, clears all.
#' @return Invisibly returns the number of files removed
#' @export
#' @examples
#' \dontrun{
#' # Clear all cached data
#' clear_enr_cache()
#'
#' # Clear only 2024 data
#' clear_enr_cache(2024)
#' }
clear_enr_cache <- function(years = NULL) {
  cache_dir <- get_cache_dir()

  if (is.null(years)) {
    files <- list.files(cache_dir, pattern = "\\.rds$", full.names = TRUE)
  } else {
    patterns <- paste0("enr_.*_", years, "\\.rds$")
    files <- unlist(lapply(patterns, function(p) {
      list.files(cache_dir, pattern = p, full.names = TRUE)
    }))
  }

  if (length(files) > 0) {
    file.remove(files)
    message(paste("Removed", length(files), "cached file(s)"))
  } else {
    message("No cached files to remove")
  }

  invisible(length(files))
}


#' Show cache status
#'
#' Lists all cached data files with their size and age.
#'
#' @return Data frame with cache information (invisibly)
#' @export
#' @examples
#' \dontrun{
#' cache_status()
#' }
cache_status <- function() {
  cache_dir <- get_cache_dir()
  files <- list.files(cache_dir, pattern = "\\.rds$", full.names = TRUE)

  if (length(files) == 0) {
    message("Cache is empty")
    return(invisible(data.frame()))
  }

  info <- file.info(files)
  info$file <- basename(files)
  info$year <- as.integer(gsub(".*_(\\d{4})\\.rds$", "\\1", info$file))
  info$type <- gsub("^enr_(.*)_\\d{4}\\.rds$", "\\1", info$file)
  info$size_mb <- round(info$size / 1024 / 1024, 2)
  info$age_days <- round(as.numeric(difftime(Sys.time(), info$mtime, units = "days")), 1)

  result <- info[, c("year", "type", "size_mb", "age_days")]
  result <- result[order(result$year, result$type), ]
  rownames(result) <- NULL

  print(result)
  invisible(result)
}
