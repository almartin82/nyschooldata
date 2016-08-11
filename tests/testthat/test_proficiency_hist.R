context("proficiency hist")


test_that("basic_proficiency_hist produces a plot", {

  ex <- p_proficiency_hist(
    assess_db_all = nys_all,
    bedscodes = c('310100860866', '320800860940'),
    subjects = 'ELA',
    grades = C(5, 6)
  )

  ex

})
