## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.width = 7,
  fig.height = 4,
  eval = FALSE
)

## ----load-packages------------------------------------------------------------
# library(nyschooldata)
# library(dplyr)
# library(ggplot2)
# library(scales)

## ----fetch-basic--------------------------------------------------------------
# # Fetch 2024 enrollment data (2023-24 school year)
# # Note: year refers to the END of the school year
# enr <- fetch_enr(2024)
# 
# head(enr)

## ----available-years----------------------------------------------------------
# get_available_years()

## ----data-levels--------------------------------------------------------------
# # School-level data (default)
# school_enr <- fetch_enr(2024, level = "school")
# 
# # District-level aggregates
# district_enr <- fetch_enr(2024, level = "district")

## ----tidy-format--------------------------------------------------------------
# # Tidy format (default): one row per school per grade
# enr_tidy <- fetch_enr(2024, tidy = TRUE)
# 
# enr_tidy %>%
#   filter(is_school) %>%
#   select(school_name, grade_level, n_students) %>%
#   head(10)

## ----wide-format--------------------------------------------------------------
# # Wide format: one row per school, columns for each grade
# enr_wide <- fetch_enr(2024, tidy = FALSE)
# 
# enr_wide %>%
#   filter(is_school) %>%
#   select(school_name, row_total, grade_pk, grade_k, grade_01, grade_09, grade_12) %>%
#   head(5)

## ----filter-flags-------------------------------------------------------------
# # All districts
# districts <- enr %>% filter(is_district, grade_level == "TOTAL")
# nrow(districts)
# 
# # All schools
# schools <- enr %>% filter(is_school, grade_level == "TOTAL")
# nrow(schools)
# 
# # Only NYC schools
# nyc_schools <- enr %>% filter(is_school, is_nyc, grade_level == "TOTAL")
# nrow(nyc_schools)
# 
# # Only charter schools
# charters <- enr %>% filter(is_school, is_charter, grade_level == "TOTAL")
# nrow(charters)

## ----parse-beds---------------------------------------------------------------
# # Parse a BEDS code
# parse_beds_code("010100010018")
# # Returns:
# #      beds_code district_code school_code check_digits
# # 1 010100010018        010100        0001           18
# 
# # Parse multiple codes
# beds_codes <- c("010100010018", "310200010001", "261600010001")
# parse_beds_code(beds_codes)

## ----validate-beds------------------------------------------------------------
# # Validate BEDS codes
# validate_beds_code("010100010018")    # TRUE - valid
# validate_beds_code("31000001023")     # FALSE - only 11 digits
# validate_beds_code("invalid")          # FALSE - not numeric

## ----fetch-school-------------------------------------------------------------
# # Get enrollment for a specific school by BEDS code
# school_enr <- fetch_enr_school("010100010018", 2024)
# school_enr
# 
# # Get multiple years for a school
# school_history <- fetch_enr_school("010100010018", 2020:2024)

## ----fetch-district-----------------------------------------------------------
# # Get all schools in a district
# albany_schools <- fetch_enr_district("010100", 2024, level = "school")
# 
# # Get district aggregates only
# albany_district <- fetch_enr_district("010100", 2024, level = "district")

## ----top-districts------------------------------------------------------------
# enr %>%
#   filter(is_district, grade_level == "TOTAL") %>%
#   arrange(desc(n_students)) %>%
#   select(district_name, county, n_students) %>%
#   head(10)

## ----county-enrollment--------------------------------------------------------
# enr %>%
#   filter(is_district, grade_level == "TOTAL") %>%
#   group_by(county) %>%
#   summarize(
#     n_districts = n(),
#     total_enrollment = sum(n_students, na.rm = TRUE)
#   ) %>%
#   arrange(desc(total_enrollment)) %>%
#   head(10)

## ----grade-distribution-------------------------------------------------------
# # Statewide grade distribution
# enr %>%
#   filter(is_district, grade_level != "TOTAL") %>%
#   group_by(grade_level) %>%
#   summarize(total = sum(n_students, na.rm = TRUE)) %>%
#   arrange(factor(grade_level, levels = c("PK", "K", sprintf("%02d", 1:12))))

## ----grade-span---------------------------------------------------------------
# # Get only elementary grades (K-5)
# elem_enr <- filter_grade_span(enr, "elem")
# 
# # Get only high school grades (9-12)
# hs_enr <- filter_grade_span(enr, "hs")
# 
# # Available spans: "pk12", "k12", "k8", "hs", "elem" (K-5), "middle" (6-8)

## ----grade-aggs---------------------------------------------------------------
# # Get grade span aggregates
# aggs <- enr_grade_aggs(enr)
# 
# aggs %>%
#   filter(is_district) %>%
#   select(district_name, grade_level, n_students) %>%
#   head(15)

## ----nyc-data-----------------------------------------------------------------
# # Get NYC enrollment directly
# nyc <- fetch_enr_nyc(2024)
# 
# # Largest NYC schools
# nyc %>%
#   filter(is_school, grade_level == "TOTAL") %>%
#   arrange(desc(n_students)) %>%
#   select(school_name, district_name, n_students) %>%
#   head(10)

## ----multi-year---------------------------------------------------------------
# # Fetch 5 years of data
# enr_multi <- fetch_enr_years(2020:2024)
# 
# # Check years retrieved
# unique(enr_multi$end_year)

## ----enrollment-trend---------------------------------------------------------
# # Statewide enrollment trend
# state_trend <- enr_multi %>%
#   filter(is_district, grade_level == "TOTAL") %>%
#   group_by(end_year) %>%
#   summarize(total_enrollment = sum(n_students, na.rm = TRUE))
# 
# state_trend

## ----viz-state-trend, eval=FALSE----------------------------------------------
# library(ggplot2)
# library(scales)
# 
# ggplot(state_trend, aes(x = end_year, y = total_enrollment)) +
#   geom_line(linewidth = 1, color = "steelblue") +
#   geom_point(size = 3, color = "steelblue") +
#   scale_y_continuous(labels = comma, limits = c(0, NA)) +
#   labs(
#     title = "New York State Public School Enrollment",
#     x = "School Year (End Year)",
#     y = "Total Enrollment",
#     caption = "Source: NYSED IRS"
#   ) +
#   theme_minimal()

## ----viz-grade-dist, eval=FALSE-----------------------------------------------
# grade_dist <- enr %>%
#   filter(is_district, !grade_level %in% c("TOTAL", "PK_HALF", "PK_FULL", "K_HALF", "K_FULL", "UG_ELEM", "UG_SEC")) %>%
#   group_by(grade_level) %>%
#   summarize(total = sum(n_students, na.rm = TRUE)) %>%
#   mutate(grade_level = factor(grade_level, levels = c("PK", "K", sprintf("%02d", 1:12))))
# 
# ggplot(grade_dist, aes(x = grade_level, y = total)) +
#   geom_col(fill = "steelblue") +
#   scale_y_continuous(labels = comma) +
#   labs(
#     title = "NY State Enrollment by Grade Level",
#     x = "Grade",
#     y = "Enrollment"
#   ) +
#   theme_minimal()

## ----viz-district-compare, eval=FALSE-----------------------------------------
# # Compare top 5 districts over time
# top_districts <- enr_multi %>%
#   filter(is_district, grade_level == "TOTAL", end_year == max(end_year)) %>%
#   slice_max(n_students, n = 5) %>%
#   pull(district_code)
# 
# district_trends <- enr_multi %>%
#   filter(district_code %in% top_districts, is_district, grade_level == "TOTAL")
# 
# ggplot(district_trends, aes(x = end_year, y = n_students, color = district_name)) +
#   geom_line(linewidth = 1) +
#   geom_point(size = 2) +
#   scale_y_continuous(labels = comma) +
#   labs(
#     title = "Enrollment Trends: Top 5 NY Districts",
#     x = "School Year",
#     y = "Enrollment",
#     color = "District"
#   ) +
#   theme_minimal() +
#   theme(legend.position = "bottom") +
#   guides(color = guide_legend(nrow = 2))

## ----cache-management---------------------------------------------------------
# # View cache status
# cache_status()
# 
# # Clear all cached data
# clear_enr_cache()
# 
# # Clear only 2024 data
# clear_enr_cache(2024)
# 
# # Force fresh download (bypass cache)
# enr_fresh <- fetch_enr(2024, use_cache = FALSE)

## ----school-year-labels-------------------------------------------------------
# # Convert end year to label
# school_year_label(2024)
# # [1] "2023-24"
# 
# # Parse label back to end year
# parse_school_year("2023-24")
# # [1] 2024
# 
# # Works with "2023-2024" format too
# parse_school_year("2023-2024")
# # [1] 2024

