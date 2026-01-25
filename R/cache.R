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
#' @param type File type ("raw", "processed", "tidy", "grad_wide", "grad_tidy",
#'   "assessment_tidy_all", "assessment_wide_ela", etc.)
#' @return Path to cached file
#' @keywords internal
get_cache_path <- function(end_year, type = "raw") {
  cache_dir <- get_cache_dir()

  # Determine prefix based on type
  if (grepl("^grad_", type)) {
    prefix <- "grad_"
  } else if (grepl("^assessment_", type)) {
    prefix <- "assess_"
  } else {
    prefix <- "enr_"
  }

  file.path(cache_dir, paste0(prefix, type, "_", end_year, ".rds"))
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
#' @param data_type Type of cache to clear: "enr" (enrollment), "grad" (graduation),
#'   "assess" (assessment), or NULL (all).
#' @return Invisibly returns the number of files removed
#' @export
#' @examples
#' \dontrun{
#' # Clear all cached data
#' clear_cache()
#'
#' # Clear only 2024 data
#' clear_cache(2024)
#'
#' # Clear only graduation cache
#' clear_cache(data_type = "grad")
#'
#' # Clear only assessment cache
#' clear_cache(data_type = "assess")
#' }
clear_cache <- function(years = NULL, data_type = NULL) {
  cache_dir <- get_cache_dir()

  if (is.null(years)) {
    if (is.null(data_type)) {
      files <- list.files(cache_dir, pattern = "\\.rds$", full.names = TRUE)
    } else {
      files <- list.files(cache_dir, pattern = paste0("^", data_type, "_.*\\.rds$"), full.names = TRUE)
    }
  } else {
    if (is.null(data_type)) {
      patterns <- paste0(c("enr", "grad", "assess"), "_.*_", years, "\\.rds$")
    } else {
      patterns <- paste0(data_type, "_.*_", years, "\\.rds$")
    }
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


#' @rdname clear_cache
#' @export
clear_enr_cache <- function(years = NULL, data_type = NULL) {
  clear_cache(years = years, data_type = data_type)
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

  # Extract type (enr_tidy, grad_wide, assess_assessment_tidy_all, etc.)
  info$type <- gsub("^(enr|grad|assess)_(.*)_\\d{4}\\.rds$", "\\2", info$file)
  info$data_type <- gsub("^(enr|grad|assess)_.*_\\d{4}\\.rds$", "\\1", info$file)

  info$size_mb <- round(info$size / 1024 / 1024, 2)
  info$age_days <- round(as.numeric(difftime(Sys.time(), info$mtime, units = "days")), 1)

  result <- info[, c("year", "data_type", "type", "size_mb", "age_days")]
  result <- result[order(result$data_type, result$year, result$type), ]
  rownames(result) <- NULL

  print(result)
  invisible(result)
}
