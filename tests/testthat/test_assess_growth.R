context('assess_growth')

ex <- assess_growth(final_2015, final_2016)

test_that('assess_growth returns data frame', {
  expect_is(ex, 'data.frame')
})


test_that('assess_growth correctly calculates growth data', {
  expect_equal(nrow(ex), 462847)
})
