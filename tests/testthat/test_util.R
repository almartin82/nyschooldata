context("util")

test_that("zip_to_temp handles a NYSED zipped data file", {
  ex <- zip_to_temp("http://data.nysed.gov/files/assessment/14-15/3-8-2014-15.zip")

  expect_equal(length(ex), 2)
  expect_equal(ex$files$Name, c("3-8_ELA_AND_MATH_RESEARCHER_FILE_2015.mdb",
      "3-8_ELA_AND_MATH_RESEARCHER_FILE_2015.tab")
  )
})


test_that("extract_mdb turns .mdb into data frame", {
  ex_filelist <- zip_to_temp("http://data.nysed.gov/files/assessment/14-15/3-8-2014-15.zip")
  ex <- extract_mdb(ex_filelist)

  expect_equal(nrow(ex), 434149)
})
