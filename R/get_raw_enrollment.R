# ==============================================================================
# Raw Enrollment Data Download Functions
# ==============================================================================
#
# This file contains functions for downloading raw enrollment data from NYSED.
# Data is sourced from the NYSED IRS Public School Enrollment archive.
#
# ==============================================================================

#' Download raw enrollment data from NYSED
#'
#' Downloads raw enrollment data files from the NYSED IRS archive. These files
#' contain grade-level enrollment by school or district for all students.
#'
#' @param end_year School year end (2023-24 = 2024). Valid years: 1977-2025.
#' @param level Data level: "school" (default) or "district"
#' @return Raw data frame from NYSED
#' @keywords internal
get_raw_enr <- function(end_year, level = "school") {

  # Validate inputs
  if (end_year < 1977 || end_year > 2025) {
    stop("end_year must be between 1977 and 2025")
  }

  if (!level %in% c("school", "district")) {
    stop("level must be 'school' or 'district'")
  }

  # Download based on file format (varies by year)
  if (end_year >= 2022) {
    get_raw_enr_modern(end_year, level)
  } else if (end_year >= 2012) {
    get_raw_enr_legacy(end_year, level)
  } else {
    get_raw_enr_archive(end_year, level)
  }
}


#' Build NYSED IRS enrollment file URL
#'
#' Constructs the download URL based on year and naming conventions.
#' URL patterns changed in 2022.
#'
#' @param end_year School year end
#' @param level Data level
#' @param category Data category (e.g., "all-students", "race-and-ethnic-origin")
#' @return Full download URL
#' @keywords internal
build_enr_url <- function(end_year, level = "school", category = "all-students") {

  base_url <- "https://www.p12.nysed.gov/irs/statistics/enroll-n-staff/"

  if (end_year >= 2022) {
    # Modern format: enrollment-public-school-2024-25-all-students.xlsx
    yy1 <- end_year - 1
    yy2 <- sprintf("%02d", end_year %% 100)
    school_year <- paste0(yy1, "-", yy2)

    filename <- paste0(
      "enrollment-public-",
      level,
      "-",
      school_year,
      "-",
      category,
      ".xlsx"
    )
  } else {
    # Legacy format: PublicSchool2021AllStudents.xlsx
    level_prefix <- if (level == "school") "PublicSchool" else "District"

    # Map category names to legacy format
    category_legacy <- dplyr::case_when(
      category == "all-students" ~ "AllStudents",
      category == "gender" ~ "Gender",
      category == "race-and-ethnic-origin" ~ "RaceEthnicity",
      category == "economically-disadvantaged" ~ "EconDisadv",
      category == "english-language-learners" ~ "ELL",
      category == "students-with-disabilities" ~ "SWD",
      TRUE ~ "AllStudents"
    )

    filename <- paste0(level_prefix, end_year, category_legacy, ".xlsx")
  }

  paste0(base_url, filename)
}


#' Download modern format (2022+) NYSED data
#'
#' @param end_year School year end
#' @param level Data level
#' @return Raw data frame
#' @keywords internal
get_raw_enr_modern <- function(end_year, level = "school") {

  url <- build_enr_url(end_year, level, "all-students")

  # Download to temp file
  tname <- tempfile(pattern = "nysed_enr", tmpdir = tempdir(), fileext = ".xlsx")

  tryCatch({
    downloader::download(url, dest = tname, mode = "wb", quiet = TRUE)
  }, error = function(e) {
    stop(paste("Failed to download enrollment data for", end_year, ":", e$message))
  })

  # Check file size (small files likely indicate error page)
  file_info <- file.info(tname)
  if (file_info$size < 10000) {
    stop(paste("Download failed for year", end_year, "- file too small"))
  }

  # Get sheet names and read data sheet (second sheet contains data)
  sheets <- readxl::excel_sheets(tname)

  # Data sheet is typically the second one (first is metadata)
  data_sheet <- if (length(sheets) > 1) sheets[2] else sheets[1]

  df <- readxl::read_excel(tname, sheet = data_sheet)

  # Add metadata
  df$end_year <- end_year
  df$level <- level

  df
}


#' Download legacy format (2012-2021) NYSED data
#'
#' @param end_year School year end
#' @param level Data level
#' @return Raw data frame
#' @keywords internal
get_raw_enr_legacy <- function(end_year, level = "school") {

  url <- build_enr_url(end_year, level, "all-students")

  # Download to temp file
  tname <- tempfile(pattern = "nysed_enr", tmpdir = tempdir(), fileext = ".xlsx")

  tryCatch({
    downloader::download(url, dest = tname, mode = "wb", quiet = TRUE)
  }, error = function(e) {
    stop(paste("Failed to download enrollment data for", end_year, ":", e$message))
  })

  # Check file size
  file_info <- file.info(tname)
  if (file_info$size < 10000) {
    stop(paste("Download failed for year", end_year, "- file too small"))
  }

  # Legacy format has header in first row, data starts at row 1
  # Read with header to get column names
  df <- readxl::read_excel(tname, sheet = 1)

  # Standardize column names to match modern format
  df <- standardize_legacy_columns(df)

  # Add metadata
  df$end_year <- end_year
  df$level <- level

  df
}


#' Download archive format (1977-2011) NYSED data
#'
#' @param end_year School year end
#' @param level Data level
#' @return Raw data frame
#' @keywords internal
get_raw_enr_archive <- function(end_year, level = "district") {

  base_url <- "https://www.p12.nysed.gov/irs/statistics/enroll-n-staff/"

  # Archive format: Public_District_Enrollment_Total_YYYY.xlsx
  level_prefix <- if (level == "school") "School" else "District"
  filename <- paste0("Public_", level_prefix, "_Enrollment_Total_", end_year, ".xlsx")
  url <- paste0(base_url, filename)

  # Download to temp file
  tname <- tempfile(pattern = "nysed_archive", tmpdir = tempdir(), fileext = ".xlsx")

  tryCatch({
    downloader::download(url, dest = tname, mode = "wb", quiet = TRUE)
  }, error = function(e) {
    stop(paste("Failed to download enrollment data for", end_year, ":", e$message))
  })

  # Check file size
  file_info <- file.info(tname)
  if (file_info$size < 10000) {
    stop(paste("Download failed for year", end_year, "- file too small"))
  }

  # Read the Excel file

  df <- readxl::read_excel(tname, sheet = 1)

  # Standardize column names
  df <- standardize_archive_columns(df)

  # Add metadata
  df$end_year <- end_year
  df$level <- level

  df
}


#' Standardize column names from archive format (1977-2011)
#'
#' Maps archive column names to the modern format for consistent processing.
#'
#' @param df Data frame with archive column names
#' @return Data frame with standardized column names
#' @keywords internal
standardize_archive_columns <- function(df) {

  # Common mappings from archive to modern names
  col_map <- c(
    "SCHOOL YEAR" = "School Year",
    "county" = "County",
    "COUNTY" = "County",
    "STATE DISTRICT ID" = "State District Identifier",
    "STATE LOCATION ID" = "State Location Identifier",
    "DISTRICT NAME" = "District Name",
    "LOCATION NAME" = "Location Name",
    "SUBGROUP CODE" = "Subgroup Code",
    "SUBGROUP NAME" = "Subgroup Name",
    "K12 TOTAL" = "K-12 Total",
    "PK12 TOTAL" = "PreK-12 Total",
    "PK" = "PreK",
    "KG (HALF DAY)" = "Kindergarten (Half Day)",
    "KG (FULL DAY)" = "Kindergarten (Full Day)",
    "GRADE 1" = "Grade 1",
    "GRADE 2" = "Grade 2",
    "GRADE 3" = "Grade 3",
    "GRADE 4" = "Grade 4",
    "GRADE 5" = "Grade 5",
    "GRADE 6" = "Grade 6",
    "UNGRADED (ELEMENTARY)" = "Ungraded (Elementary)",
    "GRADE 7" = "Grade 7",
    "GRADE 8" = "Grade 8",
    "GRADE 9" = "Grade 9",
    "GRADE 10" = "Grade 10",
    "GRADE 11" = "Grade 11",
    "GRADE 12" = "Grade 12",
    "UNGRADED (SECONDARY)" = "Ungraded (Secondary)"
  )

  # Apply mappings
  old_names <- names(df)
  new_names <- old_names

  for (i in seq_along(old_names)) {
    key <- toupper(old_names[i])
    if (key %in% names(col_map)) {
      new_names[i] <- col_map[key]
    } else if (old_names[i] %in% names(col_map)) {
      new_names[i] <- col_map[old_names[i]]
    }
  }

  names(df) <- new_names
  df
}


#' Standardize column names from legacy format
#'
#' Maps legacy column names to the modern format for consistent processing.
#'
#' @param df Data frame with legacy column names
#' @return Data frame with standardized column names
#' @keywords internal
standardize_legacy_columns <- function(df) {

  # Common mappings from legacy to modern names
  col_map <- c(
    "SCHOOL YEAR" = "School Year",
    "DATE OF REPORT" = "Date of Report",
    "COUNTY" = "County",
    "STATE DISTRICT IDENTIFIER" = "State District Identifier",
    "DISTRICT NAME" = "District Name",
    "STATE LOCATION IDENTIFIER" = "State Location Identifier",
    "LOCATION NAME" = "Location Name",
    "SCHOOL TYPE" = "School Type",
    "SUBGROUP CODE" = "Subgroup Code",
    "SUBGROUP NAME" = "Subgroup Name",
    "PK12 TOTAL" = "PreK-12 Total",
    "PK (HALF DAY)" = "PreK (Half Day)",
    "PK (FULL DAY)" = "PreK (Full Day)",
    "K (HALF DAY)" = "Kindergarten (Half Day)",
    "K (FULL DAY)" = "Kindergarten (Full Day)",
    "GRADE 1" = "Grade 1",
    "GRADE 2" = "Grade 2",
    "GRADE 3" = "Grade 3",
    "GRADE 4" = "Grade 4",
    "GRADE 5" = "Grade 5",
    "GRADE 6" = "Grade 6",
    "UNGRADED ELEM" = "Ungraded (Elementary)",
    "GRADE 7" = "Grade 7",
    "GRADE 8" = "Grade 8",
    "GRADE 9" = "Grade 9",
    "GRADE 10" = "Grade 10",
    "GRADE 11" = "Grade 11",
    "GRADE 12" = "Grade 12",
    "UNGRADED SEC" = "Ungraded (Secondary)"
  )

  # Apply mappings
  old_names <- toupper(names(df))
  new_names <- names(df)

  for (i in seq_along(old_names)) {
    if (old_names[i] %in% names(col_map)) {
      new_names[i] <- col_map[old_names[i]]
    }
  }

  names(df) <- new_names
  df
}


#' Download demographics enrollment data from NYSED
#'
#' Downloads enrollment broken down by demographic subgroups (race/ethnicity,
#' economically disadvantaged, ELL, SWD).
#'
#' @param end_year School year end
#' @param level Data level: "school" or "district"
#' @param category Demographic category: "race", "economic", "ell", "swd"
#' @return Raw data frame with demographic breakdowns
#' @keywords internal
get_raw_enr_demographics <- function(end_year, level = "school", category = "race") {

  # Map category to URL segment
  cat_map <- c(
    "race" = "race-and-ethnic-origin",
    "economic" = "economically-disadvantaged",
    "ell" = "english-language-learners",
    "swd" = "students-with-disabilities",
    "gender" = "gender"
  )

  if (!category %in% names(cat_map)) {
    stop("Invalid category. Must be one of: race, economic, ell, swd, gender")
  }

  url_category <- cat_map[category]
  url <- build_enr_url(end_year, level, url_category)

  # Download to temp file
  tname <- tempfile(pattern = "nysed_demo", tmpdir = tempdir(), fileext = ".xlsx")

  tryCatch({
    downloader::download(url, dest = tname, mode = "wb", quiet = TRUE)
  }, error = function(e) {
    stop(paste("Failed to download", category, "data for", end_year, ":", e$message))
  })

  # Read data
  if (end_year >= 2022) {
    sheets <- readxl::excel_sheets(tname)
    data_sheet <- if (length(sheets) > 1) sheets[2] else sheets[1]
    df <- readxl::read_excel(tname, sheet = data_sheet)
  } else {
    df <- readxl::read_excel(tname, sheet = 1)
    df <- standardize_legacy_columns(df)
  }

  df$end_year <- end_year
  df$level <- level
  df$demographic_category <- category

  df
}
