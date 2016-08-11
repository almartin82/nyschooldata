context('cohort_growth')

ex <- cohort_growth(assess_15, assess_16)

test_that('cohort_growth returns data frame', {
  expect_is(ex, 'data.frame')
})


test_that('cohort_growth correctly calculates growth data', {
  expect_equal(nrow(ex), 438379)
})
