context('cohort_growth')

ex <- cohort_growth(clean_assess_start, clean_assess_end)

test_that('cohort_growth returns data frame', {
  expect_is(ex, 'data.frame')
})


test_that('cohort_growth correctly calculates growth data', {
  expect_equal(nrow(ex), 438379)
})
