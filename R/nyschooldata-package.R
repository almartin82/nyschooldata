# Global variables used in NSE (non-standard evaluation) contexts
utils::globalVariables(c(
  "grade_level", "is_nyc", "n_students", "row_total", "school_code", "subgroup"
))

#' nyschooldata: Fetch and Process New York School Data
#'
#' Downloads and processes school data from the New York State Education
#' Department (NYSED). Provides functions for fetching enrollment data and
#' transforming it into tidy format for analysis.
#'
#' @section Main Functions:
#' \describe{
#'   \item{\code{\link{fetch_enr}}}{Fetch enrollment data for a school year}
#'   \item{\code{\link{fetch_enr_years}}}{Fetch enrollment data for multiple years}
#'   \item{\code{\link{fetch_enr_school}}}{Fetch enrollment for a specific school by BEDS code}
#'   \item{\code{\link{fetch_enr_district}}}{Fetch enrollment for a specific district}
#'   \item{\code{\link{fetch_enr_nyc}}}{Fetch NYC DOE enrollment data}
#'   \item{\code{\link{tidy_enr}}}{Transform wide enrollment data to long format}
#'   \item{\code{\link{id_enr_aggs}}}{Identify aggregation levels (state/district/school)}
#'   \item{\code{\link{enr_grade_aggs}}}{Create grade-level aggregates (K-8, HS, K-12)}
#' }
#'
#' @section Data Sources:
#' Data is downloaded from the NYSED data portal at
#' \url{https://data.nysed.gov/}.
#'
#' @keywords internal
"_PACKAGE"
