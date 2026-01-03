# ==============================================================================
# Tests for enrollment functions
# ==============================================================================

test_that("validate_beds_code works correctly", {
  # Valid BEDS codes
  expect_true(validate_beds_code("010100010018"))
  expect_true(validate_beds_code("310200010100"))

  # Invalid BEDS codes
  expect_false(validate_beds_code("01010001001"))   # 11 digits
  expect_false(validate_beds_code("0101000100189")) # 13 digits
  expect_false(validate_beds_code("invalid"))
  expect_false(validate_beds_code(""))
  expect_false(validate_beds_code(NA))
})


test_that("parse_beds_code returns correct components", {
  result <- parse_beds_code("010100010018")

  expect_equal(result$beds_code, "010100010018")
  expect_equal(result$district_code, "010100")
  expect_equal(result$school_code, "0100")
  expect_equal(result$check_digits, "18")
})


test_that("school_year_label formats correctly", {
  expect_equal(school_year_label(2024), "2023-24")
  expect_equal(school_year_label(2021), "2020-21")
  expect_equal(school_year_label(2000), "1999-00")
})


test_that("parse_school_year parses correctly", {
  expect_equal(parse_school_year("2023-24"), 2024)
  expect_equal(parse_school_year("2020-21"), 2021)
  expect_equal(parse_school_year("2023-2024"), 2024)
})


test_that("get_available_years returns valid range", {
  years <- get_available_years()

  expect_true(is.list(years))
  expect_true("min_year" %in% names(years))
  expect_true("max_year" %in% names(years))
  expect_true(years$min_year < years$max_year)
})


test_that("fetch_enr validates year range", {
  # NY data available 1977-2024, so test with years outside that range
  expect_error(fetch_enr(1976), "end_year must be between")
  expect_error(fetch_enr(2030), "end_year must be between")
})


test_that("fetch_enr validates level parameter", {
  expect_error(fetch_enr(2024, level = "invalid"), "level must be")
})


test_that("build_enr_url generates correct URLs", {
  # Modern format (2022+)
  url_2024 <- nyschooldata:::build_enr_url(2024, "school", "all-students")
  expect_match(url_2024, "enrollment-public-school-2023-24-all-students.xlsx")
  expect_match(url_2024, "^https://www.p12.nysed.gov/")

  # Legacy format
  url_2018 <- nyschooldata:::build_enr_url(2018, "school", "all-students")
  expect_match(url_2018, "PublicSchool2018AllStudents.xlsx")
})


test_that("filter_grade_span validates span parameter", {
  expect_error(filter_grade_span(data.frame(), span = "invalid"), "Invalid span")
})


# Integration tests (skip if network unavailable)
test_that("fetch_enr downloads and processes data", {
  skip_on_cran()
  skip_if_offline()

  # Test with a recent year
  enr <- fetch_enr(2024, use_cache = FALSE)

  expect_true(is.data.frame(enr))
  expect_true(nrow(enr) > 0)

  # Check expected columns
  expect_true("end_year" %in% names(enr))
  expect_true("beds_code" %in% names(enr))
  expect_true("district_name" %in% names(enr))
  expect_true("grade_level" %in% names(enr))
  expect_true("n_students" %in% names(enr))

  # Check flags
  expect_true("is_school" %in% names(enr))
  expect_true("is_nyc" %in% names(enr))
  expect_true("is_charter" %in% names(enr))

  # Check year is correct
  expect_true(all(enr$end_year == 2024))

  # Clean up cache
  clear_enr_cache(2024)
})


test_that("fetch_enr wide format works", {
  skip_on_cran()
  skip_if_offline()

  enr_wide <- fetch_enr(2024, tidy = FALSE, use_cache = FALSE)

  expect_true(is.data.frame(enr_wide))
  expect_true(nrow(enr_wide) > 0)

  # Wide format should have grade columns instead of grade_level
  expect_true("grade_01" %in% names(enr_wide) || "grade_k" %in% names(enr_wide))
  expect_false("grade_level" %in% names(enr_wide))

  # Clean up
  clear_enr_cache(2024)
})


test_that("district level data works", {
  skip_on_cran()
  skip_if_offline()

  enr_dist <- fetch_enr(2024, level = "district", use_cache = FALSE)

  expect_true(is.data.frame(enr_dist))
  expect_true(nrow(enr_dist) > 0)

  # District data should not have school-level BEDS codes
  expect_false("beds_code" %in% names(enr_dist) && all(!is.na(enr_dist$beds_code)))

  # Clean up
  clear_enr_cache(2024)
})
