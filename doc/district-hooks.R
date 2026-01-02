## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.width = 8,
  fig.height = 5,
  cache = TRUE
)

## ----load-packages------------------------------------------------------------
library(nyschooldata)
library(dplyr)
library(ggplot2)
library(scales)
library(tidyr)

## ----fetch-data, cache=TRUE---------------------------------------------------
# Fetch district-level data for all available years
enr <- fetch_enr_years(2012:2024, level = "district", tidy = TRUE)

## ----statewide-trend----------------------------------------------------------
state_trend <- enr %>%
  filter(grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop")

# Calculate loss
loss <- state_trend$total[state_trend$end_year == 2012] -
        state_trend$total[state_trend$end_year == 2024]

ggplot(state_trend, aes(x = end_year, y = total)) +
  geom_line(linewidth = 1.2, color = "#2E86AB") +
  geom_point(size = 3, color = "#2E86AB") +
  geom_hline(yintercept = state_trend$total[state_trend$end_year == 2024],
             linetype = "dashed", color = "darkred", alpha = 0.5) +
  annotate("text", x = 2016, y = 2350000,
           label = paste0("-", comma(loss), " students\n(-11%)"),
           color = "darkred", size = 4, fontface = "bold") +
  scale_y_continuous(labels = comma, limits = c(2200000, 2750000)) +
  scale_x_continuous(breaks = 2012:2024) +
  labs(
    title = "New York Lost 300,000 Students in 12 Years",
    subtitle = "Total public school enrollment, 2012-2024",
    x = "School Year (End Year)",
    y = "Total Enrollment",
    caption = "Source: NYSED IRS"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold", size = 14)
  )

## ----covid-impact-------------------------------------------------------------
state_yoy <- state_trend %>%
  mutate(
    change = total - lag(total),
    pct_change = round(change / lag(total) * 100, 2)
  )

ggplot(state_yoy %>% filter(!is.na(pct_change)),
       aes(x = end_year, y = pct_change, fill = pct_change > 0)) +
  geom_col(show.legend = FALSE) +
  geom_hline(yintercept = 0, color = "black") +
  scale_fill_manual(values = c("TRUE" = "#28A745", "FALSE" = "#DC3545")) +
  scale_x_continuous(breaks = 2013:2024) +
  labs(
    title = "The COVID Cliff: 2021's Unprecedented 4.2% Drop",
    subtitle = "Year-over-year enrollment change (%)",
    x = "School Year",
    y = "Percent Change",
    caption = "2024 shows first positive growth in the dataset"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

## ----prek-growth--------------------------------------------------------------
pk_trend <- enr %>%
  filter(grade_level == "PK_FULL") %>%
  group_by(end_year) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop") %>%
  mutate(
    yoy_pct = round((total - lag(total)) / lag(total) * 100, 1)
  )

ggplot(pk_trend, aes(x = end_year, y = total)) +
  geom_area(fill = "#17A2B8", alpha = 0.3) +
  geom_line(linewidth = 1.2, color = "#17A2B8") +
  geom_point(size = 3, color = "#17A2B8") +
  geom_vline(xintercept = 2015, linetype = "dashed", color = "darkgreen") +
  annotate("text", x = 2015.5, y = 100000,
           label = "NYC Universal Pre-K\nlaunches (+115%)",
           hjust = 0, color = "darkgreen", size = 3.5) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  scale_x_continuous(breaks = 2012:2024) +
  labs(
    title = "Full-Day Pre-K Grew 463% in 12 Years",
    subtitle = "The most dramatic policy-driven enrollment shift in NY history",
    x = "School Year",
    y = "Full-Day Pre-K Enrollment",
    caption = "Source: NYSED IRS"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

## ----county-change------------------------------------------------------------
county_2012 <- enr %>% filter(end_year == 2012, grade_level == "TOTAL") %>%
  group_by(county) %>% summarize(enr_2012 = sum(n_students, na.rm = TRUE), .groups = "drop")
county_2024 <- enr %>% filter(end_year == 2024, grade_level == "TOTAL") %>%
  group_by(county) %>% summarize(enr_2024 = sum(n_students, na.rm = TRUE), .groups = "drop")

county_change <- county_2012 %>%
  inner_join(county_2024, by = "county") %>%
  filter(enr_2012 > 10000) %>%  # Major counties only
  mutate(
    change = enr_2024 - enr_2012,
    pct_change = round((enr_2024 - enr_2012) / enr_2012 * 100, 1)
  ) %>%
  arrange(pct_change)

# Show top 10 declining and top 5 growing
county_display <- bind_rows(
  county_change %>% head(10),
  county_change %>% tail(5)
) %>%
  mutate(county = factor(county, levels = county))

ggplot(county_display, aes(x = reorder(county, pct_change), y = pct_change,
                           fill = pct_change > 0)) +
  geom_col(show.legend = FALSE) +
  geom_hline(yintercept = 0) +
  coord_flip() +
  scale_fill_manual(values = c("TRUE" = "#28A745", "FALSE" = "#DC3545")) +
  labs(
    title = "The Bronx Led the State in Enrollment Loss",
    subtitle = "Percent change in enrollment, 2012-2024 (counties with >10K students)",
    x = NULL,
    y = "Percent Change"
  ) +
  theme_minimal()

## ----major-districts----------------------------------------------------------
# Calculate 2012-2024 change by district
dist_2012 <- enr %>% filter(end_year == 2012, grade_level == "TOTAL") %>%
  select(district_name, county, enr_2012 = n_students)
dist_2024 <- enr %>% filter(end_year == 2024, grade_level == "TOTAL") %>%
  select(district_name, enr_2024 = n_students)

change <- dist_2012 %>%
  inner_join(dist_2024, by = "district_name") %>%
  filter(!is.na(enr_2012), !is.na(enr_2024), enr_2012 >= 10000) %>%
  mutate(
    change = enr_2024 - enr_2012,
    pct_change = round((enr_2024 - enr_2012) / enr_2012 * 100, 1)
  )

# Top decliners among big districts
big_declines <- change %>%
  arrange(pct_change) %>%
  head(12) %>%
  mutate(district_short = gsub(" - .*", "", district_name))

ggplot(big_declines, aes(x = reorder(district_short, pct_change), y = pct_change)) +
  geom_col(fill = "#DC3545") +
  geom_text(aes(label = paste0(pct_change, "%")), hjust = 1.1, color = "white", size = 3) +
  coord_flip() +
  labs(
    title = "Rochester Lost 30% - Worst Among Major Districts",
    subtitle = "Districts with 10,000+ students in 2012",
    x = NULL,
    y = "Percent Change (2012-2024)"
  ) +
  theme_minimal()

## ----district75---------------------------------------------------------------
# Find NYC District 75
nyc_districts <- change %>%
  filter(grepl("NYC", district_name)) %>%
  mutate(
    is_d75 = grepl("DIST 75", district_name)
  ) %>%
  arrange(pct_change)

# Top 10 NYC district changes
nyc_display <- bind_rows(
  nyc_districts %>% filter(is_d75),  # Always show District 75
  nyc_districts %>% filter(!is_d75) %>% head(5),  # Worst 5
  nyc_districts %>% filter(!is_d75) %>% tail(3)   # Best 3
) %>%
  mutate(district_short = gsub("NYC GEOG DIST ", "Dist ", district_name),
         district_short = gsub("NYC SPEC SCHOOLS - ", "", district_short))

ggplot(nyc_display, aes(x = reorder(district_short, pct_change), y = pct_change,
                        fill = pct_change > 0)) +
  geom_col(show.legend = FALSE) +
  geom_hline(yintercept = 0) +
  coord_flip() +
  scale_fill_manual(values = c("TRUE" = "#28A745", "FALSE" = "#DC3545")) +
  labs(
    title = "District 75 Bucked the Trend with 40% Growth",
    subtitle = "NYC geographic district enrollment change, 2012-2024",
    x = NULL,
    y = "Percent Change"
  ) +
  theme_minimal()

## ----grade-change-------------------------------------------------------------
grade_totals <- enr %>%
  filter(grade_level %in% c("K", "01", "05", "08", "09", "12")) %>%
  group_by(end_year, grade_level) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop")

g_2012 <- grade_totals %>% filter(end_year == 2012) %>% rename(n_2012 = total)
g_2024 <- grade_totals %>% filter(end_year == 2024) %>% rename(n_2024 = total) %>%
  select(grade_level, n_2024)

grade_change <- g_2012 %>%
  inner_join(g_2024, by = "grade_level") %>%
  mutate(
    pct_change = round((n_2024 - n_2012) / n_2012 * 100, 1),
    grade_label = case_when(
      grade_level == "01" ~ "Grade 1",
      grade_level == "05" ~ "Grade 5",
      grade_level == "08" ~ "Grade 8",
      grade_level == "09" ~ "Grade 9",
      grade_level == "12" ~ "Grade 12",
      grade_level == "K" ~ "Kindergarten"
    )
  )

ggplot(grade_change, aes(x = reorder(grade_label, pct_change), y = pct_change)) +
  geom_col(fill = "#6C757D") +
  geom_text(aes(label = paste0(pct_change, "%")), hjust = 1.1, color = "white", size = 4) +
  coord_flip() +
  labs(
    title = "First Grade Hit Hardest: -17.4%",
    subtitle = "Enrollment change by grade level, 2012-2024",
    x = NULL,
    y = "Percent Change"
  ) +
  theme_minimal()

## ----charter-data, cache=TRUE-------------------------------------------------
# Need school-level data for charter information
enr_schools <- fetch_enr_years(2023:2024, level = "school", tidy = TRUE)

## ----charter-share------------------------------------------------------------
charter_summary <- enr_schools %>%
  filter(grade_level == "TOTAL", is_school == TRUE) %>%
  group_by(end_year, is_charter) %>%
  summarize(
    total = sum(n_students, na.rm = TRUE),
    n_schools = n(),
    .groups = "drop"
  ) %>%
  mutate(
    type = ifelse(is_charter, "Charter", "Traditional"),
    avg_size = round(total / n_schools)
  )

# Show as table
charter_summary %>%
  select(end_year, type, total, n_schools, avg_size) %>%
  arrange(end_year, desc(type)) %>%
  knitr::kable(
    col.names = c("Year", "School Type", "Total Students", "# Schools", "Avg Size"),
    format.args = list(big.mark = ","),
    caption = "Charter schools grew from 175K to 181K students in one year"
  )

## ----county-growth------------------------------------------------------------
county_all <- county_2012 %>%
  inner_join(county_2024, by = "county") %>%
  mutate(
    pct_change = round((enr_2024 - enr_2012) / enr_2012 * 100, 1),
    grew = pct_change > 0
  )

# Summary stats
n_grew <- sum(county_all$grew)
n_declined <- sum(!county_all$grew)

cat(paste0("Counties that grew: ", n_grew, "\n"))
cat(paste0("Counties that declined: ", n_declined, "\n"))

# The one county that grew
county_all %>% filter(grew) %>%
  select(county, enr_2012, enr_2024, pct_change) %>%
  knitr::kable(caption = "The Only Growing County")

## ----prek-fullday-------------------------------------------------------------
enr_2024 <- fetch_enr(2024, level = "district", tidy = TRUE)

pk_comparison <- enr_2024 %>%
  filter(grade_level %in% c("PK_FULL", "PK_HALF")) %>%
  group_by(is_nyc, grade_level) %>%
  summarize(total = sum(n_students, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = grade_level, values_from = total) %>%
  mutate(
    region = ifelse(is_nyc, "NYC", "Rest of NY"),
    total_pk = PK_FULL + PK_HALF,
    pct_full_day = round(PK_FULL / total_pk * 100, 1)
  )

ggplot(pk_comparison, aes(x = region, y = pct_full_day, fill = region)) +
  geom_col(show.legend = FALSE, width = 0.6) +
  geom_text(aes(label = paste0(pct_full_day, "%")), vjust = -0.5, size = 5, fontface = "bold") +
  scale_fill_manual(values = c("NYC" = "#2E86AB", "Rest of NY" = "#A23B72")) +
  scale_y_continuous(limits = c(0, 110)) +
  labs(
    title = "NYC Pre-K is Now 99% Full-Day",
    subtitle = "Percentage of Pre-K students in full-day programs, 2024",
    x = NULL,
    y = "Percent Full-Day"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 12, face = "bold"),
    plot.title = element_text(face = "bold", size = 14)
  )

## ----session-info-------------------------------------------------------------
sessionInfo()

