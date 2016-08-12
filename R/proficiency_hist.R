#' p_proficiency_hist
#'
#' @description workhorse ggplot function that groups by
#' school/grade/subject and plots.  internal.  output needs to be
#' cleaned up by other functions.
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

  df <- prof_history_data_prep(
    assess_db_all, bedscodes, subjects, grades, subgroup_codes
  )

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
    size = 8,
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
    limits = c(year_min - .1, year_max + .1),
    breaks = seq(year_min, year_max, 1)
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



#' internal data helper function for comparison plots.  D.R.Y!
#'
#' @param assess_db_all data.frame, multiple years of assessment history
#' @param bedscodes character vector, one or more bedscode(s)
#' @param subjects character vector, one or more of c('ELA', 'Math')
#' @param grades vector, one or more grades, inclusive of 'All'.  c('All', 3, 4)
#' @param subgroup_codes vector, one or more subgroup codes
#'
#' @return data.frame

prof_history_data_prep <- function(
  assess_db_all, bedscodes, subjects, grades, subgroup_codes
) {

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


#' internal helper function for comparison plots. D.R.Y!
#'
#' @inheritParams prof_history_data_prep
#' @return list

p_proficiency_hist_sch_comparison_plot_helper <- function(
  assess_db_all, bedscodes, subjects, grades, subgroup_codes
){

  data_df <- prof_history_data_prep(
    assess_db_all, bedscodes, subjects, grades, subgroup_codes
  )

  unq_sch <- table(data_df$bedscode)
  if (length(unq_sch) > 2) {
    stop('this plot is designed only to compare two schools.')
  }

  data_df <- data_df %>%
    dplyr::group_by(bedscode) %>%
    dplyr::mutate(
      rank = order(test_year)
    )

  sch_1 <- data_df %>%
    dplyr::filter(rank == 1 & bedscode == bedscodes[1]
    ) %>% extract2('name')

  sch_2 <- data_df %>%
    dplyr::filter(rank == 1 & bedscode == bedscodes[2]
    ) %>% extract2('name')


  p_initial <- p_proficiency_hist(
    assess_db_all, bedscodes, subjects, grades, subgroup_codes
  )

  p <- p_initial + aes(group = name, color = name)

  list(
    'p' = p, 'subjects' = subjects,
    'sch_1' = sch_1, 'sch_2' = sch_2
  )
}



#' Proficiency History, One Subject, Comparing Two Entities
#'
#' @description exported visualization that compares the proficiency
#' history of two NY state entities - ie a school and the state.
#'
#' @inheritParams prof_history_data_prep
#' @return ggplot
#' @export

p_proficiency_hist_single_subj_sch_comparison <- function(
  assess_db_all, bedscodes, subjects, grades, subgroup_codes = '01'
){

  helper <- p_proficiency_hist_sch_comparison_plot_helper(
    assess_db_all, bedscodes, subjects, grades, subgroup_codes
  )

  base_p <- helper$p +
    labs(
      title = paste(
        helper$subjects, helper$sch_1, 'vs.',
        helper$sch_2, 'NY State Test'
      )
    )

  base_p
}


#' Proficiency History, Multiple Subjects, Comparing Two Entities
#'
#' @description exported visualization that compares the proficiency
#' history of two NY state entities - ie a school and the state.
#'
#' @inheritParams prof_history_data_prep
#' @return ggplot
#' @export

p_proficiency_hist_mult_subj_sch_comparison <- function(
  assess_db_all, bedscodes, subjects, grades, subgroup_codes = '01'
){

  helper <- p_proficiency_hist_sch_comparison_plot_helper(
    assess_db_all, bedscodes, subjects, grades, subgroup_codes
  )

  base_p <- helper$p +
    facet_grid(~ test_subject) +
    aes(color = name) +
    labs(
      title = paste(
        helper$sch_1, 'vs.', helper$sch_2, 'NY State Test'
      )
    )

  base_p
}

