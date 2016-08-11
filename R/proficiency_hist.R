#' p_proficiency_hist
#'
#' @param assess_db_all data.frame, multiple years of assessment history
#' @param bedscodes character vector, one or more bedscode(s)
#' @param subjects character vector, one or more of c('ELA', 'Math')
#' @param grades vector, one or more grades, inclusive of 'All'.  c('All', 3, 4)
#' @param subgroup_codes vector, one or more subgroup codes
#'
#' @return ggplot

p_proficiency_hist <- function(
  assess_db_all, bedscodes, subjects, grades, subgroup_codes = '01'
){

  df <- prof_history_data_prep(assess_db_all, bedscodes, subjects, grades, subgroup_codes)

  #used by the plot
  year_min <- min(df$test_year)
  year_max <- max(df$test_year)

  p <- ggplot(
    data = df,
    aes(
      x = test_year,
      y = l3_l4_pct,
      group = grouping_key,
      color = grouping_key,
      label = l3_l4_pct
    )
  ) +
  geom_line(size = 1.25) +
  geom_point(
    shape = 16,
    size = 6,
    color = 'white'
  ) +
  geom_text() +
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    strip.text.x = element_text(size = 12),
    legend.title = element_blank()
  ) +
  ggthemes::scale_color_tableau() +
  scale_x_continuous(
    limits = c(year_min - .1, year_max + .1)
  ) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 10)
  ) +
  labs(
    x = 'Year',
    y = 'Percent Proficient'
  )

  p
}



prof_history_data_prep <- function(assess_db_all, bedscodes, subjects, grades, subgroup_codes) {

  #limit to target school and subject
  df <- assess_db_all %>%
    dplyr::filter(
      test_subject %in% subjects &
        bedscode %in% bedscodes &
        subgroup_code == subgroup_codes
    )

  #limit to grade
  #first pre-process to help with selection
  df$grade_selector <- ifelse(is.na(df$test_grade), 'All', as.character(df$test_grade))

  df <- df %>%
    dplyr::filter(grade_selector %in% grades)

  #make grouping key
  df <- df %>%
    dplyr::mutate(
      grouping_key = paste(name, test_subject, test_grade_string, subgroup_name)
    )

  df
}
