#' Subgroup Efficacy
#'
#' @param df data.frame, with one grade level or
#' school level aggregates
#' @param bedscode target bedscode
#' @param year school year
#' @param subject subject
#' @param subgroups vector of subgroup codes
#' @param sch_aggregates use school level aggregates?
#'
#' @return ggplot
#' @export
#'
subgroup_efficacy <- function(
  df, bedscode, year, subject,
  subgroups = c('01', '02', '03', '05', '06', '07', '08',
                '10', '11', '13', '15', '16'),
  sch_aggregates = TRUE
) {
  #nse
  bedscode_in <- bedscode

  #global edits
  df <- df %>%
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

  target_sch <- df %>%
    dplyr::filter(
      bedscode == bedscode_in &
        test_year == year &
        test_subject == subject &
        subgroup_code %in% subgroups
    ) %>%
    dplyr::mutate(
      subgroup_grade_key = paste(subgroup_code, test_grade_string, sep = '_'),
      ranking_format = paste0('#', proficient_numerator_desc, ' of ', proficient_denominator),
      ranking_format = ifelse(is.na(proficient_numerator_desc), '', ranking_format),
      percentile_format = paste0(round(proficiency_percentile * 100, 0), 'ile'),
      percentile_format = gsub('NAile', '', percentile_format)
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
  geom_text(size = 10) +
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    strip.text = element_text(lineheight = 0.5)
  ) +
  facet_wrap(~subgroup_name, ncol = 1) +
  labs(x = '  ', y = '', title = '% Proficient')

  #middle stack: dist
  if (sch_aggregates) {

    dist_df <- df %>%
      dplyr::filter(
        test_year == year &
          test_subject == subject &
          subgroup_code %in% subgroups &
          is_school == TRUE &
          is_subschool == FALSE &
          subgroup_code %in% target_sch$subgroup_code
      )

    print(dim(dist_df))

  } else {

    dist_df <- df %>%
      dplyr::filter(
        test_year == year &
          test_subject == subject &
          subgroup_code %in% subgroups &
          is_school == TRUE &
          subgroup_code %in% target_sch$subgroup_code
      )

    print(dim(dist_df))
  }

  p2 <- ggplot(
    data = dist_df,
    aes(
      x = l3_l4_pct %>% round(0)
    )
  ) +
  geom_text(
    data = target_sch,
    aes(x = 50, y = 0, label = ranking_format),
    size = 16,
    vjust = 0,
    alpha = 0.3,
    color = 'blue'
  ) +
  geom_histogram(
    alpha = 0.5,
    binwidth = 1,
    fill = 'gray70',
    color = 'white'
  ) +
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.ticks.y = element_blank(),
    axis.text.y = element_blank()
  ) +
  facet_grid(
    subgroup_name ~ ., scales = 'free_y'
  ) +
  geom_vline(
    data = target_sch,
    aes(
      xintercept = l3_l4_pct
    ),
    color = 'blue',
    size = 2
  ) +
  labs(
    x = 'Percent Proficient',
    y = 'Count of New York State Schools',
    title = 'Rank vs Other NYS Schools'
  )

  #right stack: peer percentile
  p3 <- ggplot(
    data = target_sch,
    aes(
      x = 1,
      y = 1,
      label = percentile_format
    )
  ) +
  geom_text(size = 10) +
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    strip.text = element_text(lineheight = 0.1)
  ) +
  facet_wrap(~subgroup_name, ncol = 1) +
  labs(x = '  ', y = '', title = 'Percentile Rank')

  out <- gridExtra::grid.arrange(
    p1, p2, p3,
    ncol = 3, widths = c(1, 3, 1)
  )

  out
}
