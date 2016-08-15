subgroup_efficacy <- function(
  agg_df, bedscode, year, subject,
  subgroups = c('01', '02', '03', '05', '06', '07', '08',
                '10', '11', '13', '15', '16')
) {
  #nse
  bedscode_in <- bedscode

  #global edits
  agg_df <- agg_df %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      subgroup_name = factor(
        x = subgroup_name,
        levels = c(
          "All Students", "Female", "Male", "American Indian or Alaska Native",
          "Black or African American", "Hispanic or Latino", "Asian or Pacific Islander",
          "White", "Multiracial", "General Education Students", "Students with Disabilities",
          "Not Limited English Proficient", "Limited English Proficient",
          "Economically Disadvantaged", "Not Economically Disadvantaged",
          "Migrant", "Not Migrant")
      )
    )

  target_sch <- agg_df %>%
    dplyr::filter(
      bedscode == bedscode_in &
        test_year == year &
        test_subject == subject &
        subgroup_code %in% subgroups
    ) %>%
    dplyr::mutate(
      subgroup_grade_key = paste(subgroup_code, test_grade_string, sep = '_')
    )


  #left stack: prof rate
  p1 <- ggplot(
    data = target_sch,
    aes(
      x = 1,
      y = 1,
      label = l3_l4_pct
    )
  ) +
    geom_text(size = 16) +
    theme_bw() +
    theme(
      panel.grid = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_blank()
    ) +
    facet_grid(subgroup_name ~ .) +
    labs(x = '', y = '')

  p1

  #middle stack: dist
  dist_df <- agg_df %>%
    dplyr::filter(
      test_year == year &
        test_subject == subject &
        subgroup_code %in% subgroups &
        is_school == TRUE
    ) %>%
    dplyr::mutate(
      is_target = ifelse(bedscode == bedscode_in, TRUE, FALSE),
      subgroup_grade_key = paste(subgroup_code, test_grade_string, sep = '_')
    ) %>%
    dplyr::filter(
      subgroup_grade_key %in% target_sch$subgroup_grade_key
    )

  ggplot(
    data = dist_df,
    aes(
      x = l3_l4_pct %>% round(0)
    )
  ) +
    geom_text(
      data = target_sch,
      aes(
        x = 50, y = 0,
        label = paste(
          proficient_numerator, '/', proficient_denominator)
      ),
      size = 18,
      vjust = 0,
      alpha = 0.3
    ) +
    geom_histogram(binwidth = 1) +
    theme_bw() +
    theme(
      panel.grid = element_blank()
    ) +
    facet_grid(
      subgroup_name ~ .
    ) +
    geom_vline(
      data = target_sch,
      aes(
        xintercept = l3_l4_pct
      ),
      color = 'blue'
    )

  #right stack: peer percentile
}
