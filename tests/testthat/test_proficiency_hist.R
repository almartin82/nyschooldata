context("proficiency hist")


test_that("basic_proficiency_hist produces a plot", {

  ex <- p_proficiency_hist(
    assess_db_all = assess_all,
    bedscodes = c('310100860866', ''),
    subjects = 'ELA',
    grades = c(5, 6)
  )

  expect_is(ex, 'ggplot')
})


test_that("basic_proficiency_hist produces a plot", {

  ex <- p_proficiency_hist(
    assess_db_all = assess_all,
    bedscodes = c('320800860940', '000000000001'),
    subjects = 'ELA',
    grades = c(5, 6)
  )

  expect_is(ex, 'ggplot')
})
