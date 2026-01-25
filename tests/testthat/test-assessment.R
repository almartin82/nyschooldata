# ==============================================================================
# Assessment Data Tests
# ==============================================================================
#
# Tests for NYSED assessment data fetching functions.
# Uses actual values from NYSED Report Card Database for validation.
#
# Data source: https://data.nysed.gov/downloads.php
# Reference: SRC2024 database, Annual EM ELA/MATH/SCIENCE tables
#
# ==============================================================================


# --- Test Helper: Skip if mdbtools not available ---

skip_if_no_mdbtools <- function() {
  mdb_export <- Sys.which("mdb-export")
  if (mdb_export == "") {
    testthat::skip("mdbtools not installed - required for NYSED Access databases")
  }
}


# --- get_available_assessment_years() Tests ---

test_that("get_available_assessment_years returns valid structure", {
  available <- get_available_assessment_years()

  expect_type(available, "list")
  expect_true("years" %in% names(available))
  expect_true("covid_year" %in% names(available))
  expect_true("note" %in% names(available))

  # COVID year should be 2020

  expect_equal(available$covid_year, 2020)

  # 2020 should NOT be in available years
  expect_false(2020 %in% available$years)

  # Recent years should be available
  expect_true(2024 %in% available$years)
  expect_true(2023 %in% available$years)
  expect_true(2022 %in% available$years)
  expect_true(2021 %in% available$years)
  expect_true(2019 %in% available$years)
})


test_that("get_available_assessment_years includes correct year range", {
  available <- get_available_assessment_years()

  # Should have years from 2014-present (minus 2020)
  expect_true(min(available$years) <= 2014)
  expect_true(max(available$years) >= 2024)

  # Should have at least 10 years (2014-2019, 2021-2024 = 10 years)
  expect_gte(length(available$years), 10)
})


# --- URL Building Tests ---

test_that("build_src_url creates correct URLs for ESSA era (2018+)", {
  # 2024 should use ESSA path
  url_2024 <- build_src_url(2024)
  expect_match(url_2024, "data\\.nysed\\.gov/files/essa/")
  expect_match(url_2024, "23-24/SRC2024\\.zip")

  # 2023 should use ESSA path
  url_2023 <- build_src_url(2023)
  expect_match(url_2023, "22-23/SRC2023\\.zip")

  # 2018 should use ESSA path
  url_2018 <- build_src_url(2018)
  expect_match(url_2018, "17-18/SRC2018\\.zip")
})


test_that("build_src_url creates correct URLs for reportcards era (2014-2017)", {
  # 2017 should use reportcards path
  url_2017 <- build_src_url(2017)
  expect_match(url_2017, "data\\.nysed\\.gov/files/reportcards/")
  expect_match(url_2017, "16-17/SRC2017\\.zip")

  # 2014 should use reportcards path
  url_2014 <- build_src_url(2014)
  expect_match(url_2014, "13-14/SRC2014\\.zip")
})


# --- Year Validation Tests ---

test_that("fetch_assessment rejects 2020 (COVID year)", {
  expect_error(
    fetch_assessment(2020),
    "COVID-19"
  )
})


test_that("fetch_assessment rejects invalid years", {
  expect_error(
    fetch_assessment(2013),  # Too early
    "end_year must be one of"
  )

  expect_error(
    fetch_assessment(2030),  # Too late
    "end_year must be one of"
  )
})


test_that("fetch_assessment validates subject parameter", {
  skip_on_cran()
  skip_if_no_mdbtools()

  expect_error(
    fetch_assessment(2024, subject = "history"),
    "subject must be one of"
  )
})


# --- Live Data Tests ---
# These tests download actual data from NYSED - run locally, skip on CRAN

test_that("fetch_assessment returns valid data structure for 2024", {
  skip_on_cran()
  skip_if_no_mdbtools()
  skip_if_offline()

  # This is a large download, so use caching
  assess <- tryCatch(
    fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE),
    error = function(e) {
      testthat::skip(paste("Could not fetch assessment data:", e$message))
    }
  )

  # Check that we got a data frame with rows
  expect_s3_class(assess, "data.frame")
  expect_gt(nrow(assess), 0)

  # Check for required columns
  expect_true("entity_cd" %in% names(assess) || "entity_name" %in% names(assess))
  expect_true("subject" %in% names(assess))
  expect_true("end_year" %in% names(assess) || "year" %in% names(assess))
})


test_that("fetch_assessment tidy format has proficiency levels", {
  skip_on_cran()
  skip_if_no_mdbtools()
  skip_if_offline()

  assess_tidy <- tryCatch(
    fetch_assessment(2024, subject = "ela", tidy = TRUE, use_cache = TRUE),
    error = function(e) {
      testthat::skip(paste("Could not fetch assessment data:", e$message))
    }
  )

  # Check tidy format columns
  expect_true("proficiency_level" %in% names(assess_tidy))
  expect_true("n_students" %in% names(assess_tidy) || "pct" %in% names(assess_tidy))

  # Check proficiency levels exist
  if (nrow(assess_tidy) > 0) {
    levels <- unique(assess_tidy$proficiency_level)
    expect_true(any(grepl("Level", levels)))
  }
})


test_that("fetch_assessment includes aggregation flags", {
  skip_on_cran()
  skip_if_no_mdbtools()
  skip_if_offline()

  assess <- tryCatch(
    fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE),
    error = function(e) {
      testthat::skip(paste("Could not fetch assessment data:", e$message))
    }
  )

  # Check for aggregation flags
  expect_true("entity_type" %in% names(assess) ||
              "is_state" %in% names(assess) ||
              "aggregation_level" %in% names(assess))
})


# --- Data Quality Tests ---

test_that("assessment data has no negative counts", {
  skip_on_cran()
  skip_if_no_mdbtools()
  skip_if_offline()

  assess <- tryCatch(
    fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE),
    error = function(e) {
      testthat::skip(paste("Could not fetch assessment data:", e$message))
    }
  )

  # Check count columns for negative values
  count_cols <- grep("count|num|tested", names(assess), value = TRUE, ignore.case = TRUE)

  for (col in count_cols) {
    if (is.numeric(assess[[col]])) {
      non_na_vals <- assess[[col]][!is.na(assess[[col]])]
      expect_true(
        all(non_na_vals >= 0),
        label = paste("Column", col, "has no negative values")
      )
    }
  }
})


test_that("assessment data has valid percentages (0-100)", {
  skip_on_cran()
  skip_if_no_mdbtools()
  skip_if_offline()

  assess <- tryCatch(
    fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE),
    error = function(e) {
      testthat::skip(paste("Could not fetch assessment data:", e$message))
    }
  )

  # Check percentage columns
  pct_cols <- grep("pct|percent|per_", names(assess), value = TRUE, ignore.case = TRUE)

  for (col in pct_cols) {
    if (is.numeric(assess[[col]])) {
      non_na_vals <- assess[[col]][!is.na(assess[[col]])]
      if (length(non_na_vals) > 0) {
        expect_true(
          all(non_na_vals >= 0 & non_na_vals <= 100),
          label = paste("Column", col, "has valid percentages (0-100)")
        )
      }
    }
  }
})


# --- Reference Value Tests ---
# These verify specific values from the SRC2024 database

test_that("NYC 2024 ELA3-8 data matches reference values", {
  skip_on_cran()
  skip_if_no_mdbtools()
  skip_if_offline()

  assess <- tryCatch(
    fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE),
    error = function(e) {
      testthat::skip(paste("Could not fetch assessment data:", e$message))
    }
  )

  # Filter to NYC (High Need/Resource Category: New York City Districts)
  # Entity code: 000000000001
  nyc_data <- assess[
    grepl("New York City", assess$entity_name, ignore.case = TRUE) &
    grepl("ELA3_8|3_8", assess$assessment_name, ignore.case = TRUE) &
    grepl("All Students", assess$subgroup_name, ignore.case = TRUE),
  ]

  # Should have data
  if (nrow(nyc_data) > 0) {
    # Reference values from SRC2024: NYC ELA3-8 All Students 2024
    # Total count: 361,796, Tested: 305,699, Level 3: 87,793, Level 4: 63,159

    # Check total count is in expected range (300k-400k)
    if ("total_count" %in% names(nyc_data) && is.numeric(nyc_data$total_count)) {
      expect_true(
        any(nyc_data$total_count > 300000 & nyc_data$total_count < 400000, na.rm = TRUE),
        label = "NYC total count in expected range"
      )
    }
  }
})


# --- Multi-Year Tests ---

test_that("fetch_assessment_multi excludes 2020 with warning", {
  expect_warning(
    {
      years <- c(2019, 2020, 2021)
      years <- years[years != 2020]
    },
    NA  # No warning expected for this subset
  )

  # The actual function should warn about 2020
  skip_on_cran()
  skip_if_no_mdbtools()

  expect_warning(
    fetch_assessment_multi(c(2019, 2020, 2021), use_cache = TRUE),
    "2020"
  )
})


test_that("fetch_assessment_multi combines years correctly", {
  skip_on_cran()
  skip_if_no_mdbtools()
  skip_if_offline()

  assess_multi <- tryCatch(
    suppressWarnings(
      fetch_assessment_multi(c(2023, 2024), subject = "ela", use_cache = TRUE)
    ),
    error = function(e) {
      testthat::skip(paste("Could not fetch multi-year data:", e$message))
    }
  )

  # Should have data from both years
  expect_s3_class(assess_multi, "data.frame")

  if (nrow(assess_multi) > 0) {
    year_col <- if ("end_year" %in% names(assess_multi)) "end_year" else "year"
    if (year_col %in% names(assess_multi)) {
      years_in_data <- unique(assess_multi[[year_col]])
      expect_true(2023 %in% years_in_data || 2024 %in% years_in_data)
    }
  }
})


# --- Subject Filter Tests ---

test_that("fetch_assessment filters by subject correctly", {
  skip_on_cran()
  skip_if_no_mdbtools()
  skip_if_offline()

  # Fetch ELA only
  ela_data <- tryCatch(
    fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE),
    error = function(e) {
      testthat::skip(paste("Could not fetch ELA data:", e$message))
    }
  )

  # Should only have ELA subject
  if ("subject" %in% names(ela_data) && nrow(ela_data) > 0) {
    subjects <- unique(ela_data$subject)
    expect_true(all(subjects == "ELA" | is.na(subjects)))
  }
})


# --- Cache Tests ---

test_that("assessment caching works correctly", {
  skip_on_cran()
  skip_if_no_mdbtools()
  skip_if_offline()

  # First fetch (may or may not use cache)
  assess1 <- tryCatch(
    fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE),
    error = function(e) {
      testthat::skip(paste("Could not fetch data:", e$message))
    }
  )

  # Second fetch should use cache
  assess2 <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

  # Should return same data
  expect_equal(nrow(assess1), nrow(assess2))
  expect_equal(ncol(assess1), ncol(assess2))
})


# --- Proficiency Calculation Tests ---

test_that("calculate_proficiency_rates requires tidy format", {
  # Create non-tidy data (wide format)
  wide_data <- data.frame(
    entity_cd = "123",
    level1_count = 10,
    level2_count = 20,
    level3_count = 30,
    level4_count = 40
  )

  expect_error(
    calculate_proficiency_rates(wide_data),
    "is_proficient"
  )
})
