context('assess_growth')

ex <- assess_growth(assess_15, assess_16)

test_that('assess_growth returns data frame', {
  expect_is(ex, 'data.frame')
})


test_that('assess_growth correctly calculates growth data', {
  expect_equal(nrow(ex), 462847)
})


assess_15 %>%
  dplyr::filter(bedscode == '331700010002' & subgroup_code == '01') %>%
  print.data.frame()

ex %>%
  dplyr::filter(bedscode == '331700010002' & subgroup_code == '01') %>%
  print.data.frame()
