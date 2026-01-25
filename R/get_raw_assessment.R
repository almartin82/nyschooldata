# ==============================================================================
# Raw Assessment Data Download Functions
# ==============================================================================
#
# This file contains functions for downloading raw assessment data from the
# New York State Education Department (NYSED).
#
# Data is sourced from the NYSED Report Card Database downloads, which contain
# Access databases (.mdb) with comprehensive assessment data.
#
# Available assessments:
# - NY State Tests (ELA, Math): Grades 3-8
# - NY State Science Test: Grade 8
# - Regents Exams: High school
# - NYSESLAT: English Language Proficiency
# - NYSAA: Alternate Assessment
#
# ==============================================================================


#' Download raw assessment data from NYSED
#'
#' Downloads and extracts assessment data from the NYSED Report Card Database.
#' Requires mdbtools to be installed on the system.
#'
#' @param end_year School year end (2023-24 = 2024). Valid years: 2014-2025.
#' @param subject Assessment subject: "ela", "math", "science", or "all" (default)
#' @return Data frame with raw assessment data
#' @keywords internal
get_raw_assessment <- function(end_year, subject = "all") {

  # Validate mdbtools is available
  check_mdbtools()

  # Get available years
  available <- get_available_assessment_years()

  # Validate year
  if (end_year == 2020) {
    stop("2020 assessment data is not available due to COVID-19 testing waiver. ",
         "No statewide testing was administered in Spring 2020.")
  }

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

  message(paste("Downloading NY assessment data for", end_year, "..."))

  # Download the database file
  db_path <- download_src_database(end_year)

  # Extract assessment tables
  assessment_data <- extract_assessment_tables(db_path, end_year, subject)

  # Clean up temp file
  unlink(db_path)

  assessment_data
}


#' Build NYSED Report Card Database URL
#'
#' Constructs the download URL based on year. URL patterns changed over time:
#' - 2018+: /files/essa/YY-YY/SRCYYYY.zip
#' - 2014-2017: /files/reportcards/YY-YY/SRCYYYY.zip
#'
#' @param end_year School year end
#' @return Full download URL
#' @keywords internal
build_src_url <- function(end_year) {

  # Build the school year folder (e.g., 23-24 for end_year 2024)
  start_yy <- sprintf("%02d", (end_year - 1) %% 100)
  end_yy <- sprintf("%02d", end_year %% 100)
  folder_year <- paste0(start_yy, "-", end_yy)

  # Build the filename
  filename <- paste0("SRC", end_year, ".zip")

  # URL base depends on year
  if (end_year >= 2018) {
    base_url <- "https://data.nysed.gov/files/essa/"
  } else {
    base_url <- "https://data.nysed.gov/files/reportcards/"
  }

  paste0(base_url, folder_year, "/", filename)
}


#' Download NYSED Report Card Database
#'
#' Downloads and extracts the Access database file from NYSED.
#'
#' @param end_year School year end
#' @return Path to the extracted .mdb file
#' @keywords internal
download_src_database <- function(end_year) {

  url <- build_src_url(end_year)

  message("  Downloading from: ", url)

  # Create temp directory for extraction
  temp_dir <- tempdir()
  zip_path <- file.path(temp_dir, paste0("SRC", end_year, ".zip"))

  # Download the zip file
  tryCatch({
    httr::GET(
      url,
      httr::write_disk(zip_path, overwrite = TRUE),
      httr::timeout(600),  # 10 minute timeout for large files
      httr::progress(),
      httr::user_agent("Mozilla/5.0 (compatible; nyschooldata R package)")
    )
  }, error = function(e) {
    stop(paste("Failed to download assessment data for year", end_year,
               "\nError:", e$message,
               "\nURL:", url))
  })

  # Check file was downloaded
  if (!file.exists(zip_path) || file.info(zip_path)$size < 10000) {
    stop("Downloaded file is too small or missing - likely an error page")
  }

  message("  Extracting database...")

  # List zip contents to find the .mdb file
  zip_contents <- utils::unzip(zip_path, list = TRUE)
  mdb_files <- zip_contents$Name[grepl("\\.mdb$", zip_contents$Name, ignore.case = TRUE)]

  if (length(mdb_files) == 0) {
    stop("No .mdb file found in the downloaded archive")
  }

  # Extract the .mdb file
  mdb_file <- mdb_files[1]
  utils::unzip(zip_path, files = mdb_file, exdir = temp_dir, overwrite = TRUE)

  mdb_path <- file.path(temp_dir, mdb_file)

  # Clean up zip file

  unlink(zip_path)

  if (!file.exists(mdb_path)) {
    stop("Failed to extract .mdb file")
  }

  mdb_path
}


#' Extract assessment tables from Access database
#'
#' Uses mdbtools to export assessment tables from the Access database.
#'
#' @param db_path Path to the .mdb file
#' @param end_year School year end (for metadata)
#' @param subject Subject filter: "ela", "math", "science", or "all"
#' @return Data frame with assessment data
#' @keywords internal
extract_assessment_tables <- function(db_path, end_year, subject = "all") {

  # Define which tables to extract based on subject
  tables_to_extract <- if (subject == "all") {
    c("Annual EM ELA", "Annual EM MATH", "Annual EM SCIENCE")
  } else if (subject == "ela") {
    "Annual EM ELA"
  } else if (subject == "math") {
    "Annual EM MATH"
  } else if (subject == "science") {
    "Annual EM SCIENCE"
  }

  message("  Extracting tables: ", paste(tables_to_extract, collapse = ", "))

  all_data <- list()

  for (table_name in tables_to_extract) {

    # Export table using mdb-export
    csv_output <- tryCatch({
      system2(
        "mdb-export",
        args = c(shQuote(db_path), shQuote(table_name)),
        stdout = TRUE,
        stderr = FALSE
      )
    }, error = function(e) {
      warning(paste("Failed to extract table:", table_name, "-", e$message))
      character(0)
    })

    if (length(csv_output) == 0) {
      warning(paste("No data returned for table:", table_name))
      next
    }

    # Parse CSV output
    df <- tryCatch({
      readr::read_csv(
        I(paste(csv_output, collapse = "\n")),
        show_col_types = FALSE,
        col_types = readr::cols(.default = readr::col_character())
      )
    }, error = function(e) {
      warning(paste("Failed to parse table:", table_name, "-", e$message))
      data.frame()
    })

    if (nrow(df) == 0) next

    # Add subject identifier
    df$subject_table <- table_name

    all_data[[table_name]] <- df
  }

  if (length(all_data) == 0) {
    warning("No assessment data could be extracted")
    return(data.frame())
  }

  # Combine all tables
  combined <- dplyr::bind_rows(all_data)

  # Clean column names
  names(combined) <- clean_assessment_column_names(names(combined))

  combined
}


#' Check if mdbtools is available
#'
#' Verifies that mdb-export is installed and accessible.
#'
#' @return TRUE if available, stops with error if not
#' @keywords internal
check_mdbtools <- function() {

  mdb_export <- Sys.which("mdb-export")

  if (mdb_export == "") {
    stop(
      "mdbtools is required to read NYSED Access databases.\n\n",
      "Install mdbtools:\n",
      "  macOS:  brew install mdbtools\n",
      "  Ubuntu: sudo apt-get install mdbtools\n",
      "  Fedora: sudo dnf install mdbtools\n\n",
      "For Windows, use Windows Subsystem for Linux (WSL)."
    )
  }

  invisible(TRUE)
}


#' Clean assessment column names
#'
#' Standardizes column names by converting to lowercase and replacing
#' special characters.
#'
#' @param x Character vector of column names
#' @return Cleaned character vector
#' @keywords internal
clean_assessment_column_names <- function(x) {
  x <- tolower(x)
  x <- gsub(" ", "_", x)
  x <- gsub("%", "pct", x)
  x <- gsub("-", "_", x)
  x <- gsub("[^a-z0-9_]", "", x)
  x
}


#' Get available assessment years for New York
#'
#' Returns the years for which assessment data is available from NYSED.
#'
#' Assessment data is available from 2014-present, with the following notes:
#' - 2020: No data due to COVID-19 testing waiver
#' - 2014-2017: NY State Tests (ELA, Math grades 3-8; Science grade 8)
#' - 2018-present: Same assessments with ESSA accountability framework
#'
#' @return A list with:
#'   \item{years}{Integer vector of available years}
#'   \item{covid_year}{Integer year with no testing (2020)}
#'   \item{note}{Character string with information about data availability}
#' @export
#' @examples
#' get_available_assessment_years()
get_available_assessment_years <- function() {

  # Years with available data
  available_years <- c(2014:2019, 2021:2025)

  list(
    years = available_years,
    covid_year = 2020,
    note = paste0(
      "New York State assessment data is available from 2013-14 through 2024-25. ",
      "2019-20 (end_year 2020) has no data due to COVID-19 testing waiver. ",
      "Assessments include: NY State Tests (ELA/Math grades 3-8, Science grade 8), ",
      "Regents Exams (high school), NYSESLAT (English proficiency), and NYSAA (alternate)."
    )
  )
}
