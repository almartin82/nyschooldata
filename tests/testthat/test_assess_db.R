context("assess_db")

ex <- get_raw_assess_db(2015)
clean_ex <- fetch_assess_db(2013)

test_that("get_raw_assess_db correctly reads a NY state file", {

  expect_equal(nrow(ex), 434149)
})


test_that("fetch_aggregate_percentile_assess_db correctly reads
          and processes a NY state assessment file", {

  expect_is(clean_ex, 'data.frame')
  expect_equal(nrow(clean_ex), 562016)
})
