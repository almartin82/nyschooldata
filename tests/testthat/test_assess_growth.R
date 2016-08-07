context('assess_growth')

ex_2015 <- get_raw_assess_db(2015)
ex_2016 <- get_raw_assess_db(2016)

clean_assess_start <- clean_assess_db(ex_2015, 2015)
clean_assess_end <- clean_assess_db(ex_2016, 2016)

ex <- assess_growth(
  clean_assess_start,
  clean_assess_end
)

test_that('assess_growth returns data frame', {
  expect_is(ex, 'data.frame')
})


test_that('assess_growth correctly calculates growth data', {

  expect_equal(nrow(ex), 462847)

})
