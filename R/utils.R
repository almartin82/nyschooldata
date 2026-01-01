# ==============================================================================
# Utility Functions
# ==============================================================================

#' @importFrom rlang .data
NULL


#' @importFrom rlang .data
NULL


#' School Year Label
#'
#' Converts an end year integer to a school year label string.
#'
#' @param end_year Integer end year (e.g., 2024)
#' @return Character school year label (e.g., "2023-24")
#' @export
#' @examples
#' school_year_label(2024)  # Returns "2023-24"
#' school_year_label(2021)  # Returns "2020-21"
school_year_label <- function(end_year) {
  start_year <- end_year - 1
  end_yy <- sprintf("%02d", end_year %% 100)
  paste0(start_year, "-", end_yy)
}


#' Parse School Year Label
#'
#' Converts a school year label string to an end year integer.
#'
#' @param label Character school year label (e.g., "2023-24")
#' @return Integer end year (e.g., 2024)
#' @export
#' @examples
#' parse_school_year("2023-24")  # Returns 2024
#' parse_school_year("2020-21")  # Returns 2021
parse_school_year <- function(label) {
  # Handle both "2023-24" and "2023-2024" formats
  parts <- strsplit(label, "-")[[1]]

  if (length(parts) != 2) {
    stop("Invalid school year format. Expected format: '2023-24' or '2023-2024'")
  }

  start_year <- as.integer(parts[1])
  end_part <- parts[2]

  if (nchar(end_part) == 2) {
    # Two-digit year
    century <- floor(start_year / 100) * 100
    end_year <- century + as.integer(end_part)

    # Handle century rollover (e.g., "1999-00")
    if (end_year < start_year) {
      end_year <- end_year + 100
    }
  } else {
    # Four-digit year
    end_year <- as.integer(end_part)
  }

  end_year
}


#' Get Available Years
#'
#' Returns the range of years for which enrollment data is available.
#'
#' @return Named list with min_year and max_year
#' @export
#' @examples
#' get_available_years()
get_available_years <- function() {
  list(
    min_year = 1977L,
    max_year = 2025L
  )
}
