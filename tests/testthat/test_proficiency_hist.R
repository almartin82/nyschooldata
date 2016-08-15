context("proficiency hist")


test_that("basic_proficiency_hist produces a plot", {

  ex <- p_proficiency_hist(
    assess_db_all = clean_all,
    bedscodes = c('310100860866', '320800860940'),
    subjects = 'ELA',
    grades = c(5, 6)
  )

  expect_is(ex, 'ggplot')
})


test_that("basic_proficiency_hist produces a plot", {

  ex <- p_proficiency_hist(
    assess_db_all = clean_all,
    bedscodes = c('320800860940', '000000000001'),
    subjects = 'ELA',
    grades = c(5, 6)
  )

  expect_is(ex, 'ggplot')
})


test_that("p_proficiency_hist_single_subj_sch_comparison", {

  sch_vs_nyc_math <- p_proficiency_hist_single_subj_sch_comparison(
    assess_db_all = agg_all,
    bedscodes = c('320800860940', '000000000001'),
    subjects =  'Math',
    grades = 'All'
  )

  sch_vs_nyc_math

})
