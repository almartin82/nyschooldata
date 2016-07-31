context("assess_db")


test_that("get_raw_assess_db correctly reads 2015 file", {
  ex <- get_raw_assess_db(2015)

  expect_equal(nrow(ex), 434149)
})

test_that("get_raw_assess_db correctly reads 2014 file", {
  ex <- get_raw_assess_db(2014)

  expect_equal(nrow(ex), 435946)
})

test_that("get_raw_assess_db correctly reads 2013 file", {
  ex <- get_raw_assess_db(2013)

  expect_equal(nrow(ex), 435244)
})

test_that("get_raw_assess_db correctly reads 2016 file", {
  ex <- get_raw_assess_db(2016)

  expect_equal(nrow(ex), 436464)
})
