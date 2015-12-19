context("util")

test_that("zip_to_temp handles a NYSED zipped data file", {
  ex <- zip_to_temp("https://data.nysed.gov/files/assessment/3-8-2014-15.zip")

  expect_equal(length(ex), 2)
  expect_equal(ex$files$Name, c("3-8_ELA_AND_MATH_RESEARCHER_FILE_2015.mdb",
      "3-8_ELA_AND_MATH_RESEARCHER_FILE_2015.tab")
  )
})
