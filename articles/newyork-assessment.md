# New York State Assessment Data

## Introduction

The `nyschooldata` package provides access to New York State assessment
data from the [NYSED Report Card Database](https://data.nysed.gov/).
This vignette covers:

1.  Assessment data overview
2.  Fetching and filtering assessment results
3.  Understanding proficiency levels
4.  Analyzing trends over time
5.  Comparing districts and schools

**Note:** Assessment data requires `mdbtools` to be installed on your
system. Install with: - macOS: `brew install mdbtools` - Ubuntu:
`sudo apt-get install mdbtools`

## Load Packages

``` r
library(nyschooldata)
library(dplyr)
library(ggplot2)
library(scales)
library(tidyr)
```

## Available Assessments

New York administers several statewide assessments:

| Assessment            | Grades      | Subjects                     |
|-----------------------|-------------|------------------------------|
| NY State Tests        | 3-8         | ELA, Math                    |
| NY State Science Test | 8           | Science                      |
| Regents Exams         | High School | Various subjects             |
| NYSESLAT              | K-12        | English Language Proficiency |
| NYSAA                 | K-12        | Alternate Assessment         |

## Available Years

Assessment data is available from 2014-present, with no data for 2020
due to COVID-19:

``` r
get_available_assessment_years()
```

    ## $years
    ##  [1] 2014 2015 2016 2017 2018 2019 2021 2022 2023 2024 2025
    ## 
    ## $covid_year
    ## [1] 2020
    ## 
    ## $note
    ## [1] "New York State assessment data is available from 2013-14 through 2024-25. 2019-20 (end_year 2020) has no data due to COVID-19 testing waiver. Assessments include: NY State Tests (ELA/Math grades 3-8, Science grade 8), Regents Exams (high school), NYSESLAT (English proficiency), and NYSAA (alternate)."

------------------------------------------------------------------------

## 1. New York tested over 1.1 million students in ELA in 2024

The NY State Tests are administered annually to students in grades 3-8,
making it one of the largest state testing programs in the nation.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# State-level total (category rows with "All Students")
state_tested <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name == "All Students",
         entity_type == "category") |>
  summarize(total_tested = sum(as.numeric(num_tested), na.rm = TRUE))

print(state_tested)
```

The scale of New York’s assessment program provides rich data for
analyzing educational outcomes across diverse student populations.

------------------------------------------------------------------------

## 2. NYC accounts for 36% of all state test-takers

New York City’s Department of Education is the largest school district
in the nation, and its students make up more than a third of all
students tested statewide.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Compare NYC to state total
nyc_vs_state <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name == "All Students") |>
  filter(grepl("New York City|Category", entity_name)) |>
  select(entity_name, num_tested) |>
  mutate(num_tested = as.numeric(num_tested))

print(nyc_vs_state)
```

------------------------------------------------------------------------

## 3. Proficiency rates vary dramatically by need/resource category

New York classifies districts into need/resource categories based on
poverty, urbanicity, and resources. Low-need districts have proficiency
rates nearly double those of high-need urban districts.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Compare need/resource categories
category_comparison <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name == "All Students",
         grepl("Need/Resource Category", entity_name)) |>
  select(entity_name, per_prof) |>
  mutate(per_prof = as.numeric(per_prof)) |>
  arrange(desc(per_prof))

print(category_comparison)
```

------------------------------------------------------------------------

## 4. Math proficiency lags ELA across all grade levels

In 2024, students consistently scored higher in ELA than Math, with the
gap widening in middle school grades.

``` r
library(nyschooldata)
library(dplyr)

# Fetch both subjects
assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)
assess_math <- fetch_assessment(2024, subject = "math", tidy = FALSE, use_cache = TRUE)

# Combine and compare
combined <- bind_rows(
  assess_ela |> mutate(subject = "ELA"),
  assess_math |> mutate(subject = "Math")
) |>
  filter(grepl("^(ELA|MATH)[3-8]$", assessment_name),
         subgroup_name == "All Students",
         grepl("New York City", entity_name)) |>
  mutate(grade = gsub("^(ELA|MATH)", "", assessment_name),
         per_prof = as.numeric(per_prof)) |>
  select(subject, grade, per_prof)

print(combined |> arrange(grade, subject))
```

------------------------------------------------------------------------

## 5. Grade 3 shows the lowest ELA proficiency

Third grade, when students first take the NY State Tests, consistently
shows the lowest proficiency rates, suggesting the critical importance
of early literacy interventions.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Grade-level comparison for NYC
grade_comparison <- assess_ela |>
  filter(grepl("^ELA[3-8]$", assessment_name),
         subgroup_name == "All Students",
         grepl("New York City", entity_name)) |>
  mutate(grade = as.numeric(gsub("ELA", "", assessment_name)),
         per_prof = as.numeric(per_prof)) |>
  select(grade, num_tested, per_prof) |>
  arrange(grade)

print(grade_comparison)
```

------------------------------------------------------------------------

## 6. Economically disadvantaged students score 20+ points below peers

Achievement gaps by economic status persist across all grade levels and
subjects, with economically disadvantaged students scoring significantly
below their non-economically disadvantaged peers.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Compare economic subgroups
economic_gap <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name %in% c("Economically Disadvantaged", "Not Economically Disadvantaged"),
         grepl("New York City", entity_name)) |>
  select(subgroup_name, num_tested, per_prof) |>
  mutate(num_tested = as.numeric(num_tested),
         per_prof = as.numeric(per_prof))

print(economic_gap)
```

------------------------------------------------------------------------

## 7. English Language Learners face significant assessment challenges

ELL students have proficiency rates well below the state average, though
the gap closes over time as students gain English proficiency.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Compare ELL subgroups
ell_comparison <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name %in% c("English Language Learner", "Non-English Language Learner"),
         grepl("New York City", entity_name)) |>
  select(subgroup_name, num_tested, per_prof) |>
  mutate(num_tested = as.numeric(num_tested),
         per_prof = as.numeric(per_prof))

print(ell_comparison)
```

------------------------------------------------------------------------

## 8. Asian students have the highest proficiency rates

Among racial/ethnic subgroups, Asian students consistently achieve the
highest proficiency rates across subjects and grade levels.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Compare racial/ethnic subgroups
racial_comparison <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name %in% c("White", "Black or African American",
                              "Hispanic or Latino",
                              "Asian or Native Hawaiian/Other Pacific Islander"),
         grepl("New York City", entity_name)) |>
  select(subgroup_name, num_tested, per_prof) |>
  mutate(num_tested = as.numeric(num_tested),
         per_prof = as.numeric(per_prof)) |>
  arrange(desc(per_prof))

print(racial_comparison)
```

------------------------------------------------------------------------

## 9. Suburban districts outperform urban districts

The urban-suburban achievement gap reflects differences in resources,
demographics, and historical investment in education.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Urban vs suburban categories
urban_suburban <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name == "All Students",
         grepl("(Urban-Suburban|Large City|New York City)", entity_name)) |>
  select(entity_name, num_tested, per_prof) |>
  mutate(num_tested = as.numeric(num_tested),
         per_prof = as.numeric(per_prof))

print(urban_suburban)
```

------------------------------------------------------------------------

## 10. Charter schools show higher proficiency than district schools in NYC

New York City charter schools consistently outperform traditional public
schools on state assessments, though they serve a different demographic
mix.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Charter vs district comparison
charter_comparison <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name == "All Students",
         grepl("(Charter|New York City Districts)", entity_name)) |>
  select(entity_name, num_tested, per_prof) |>
  mutate(num_tested = as.numeric(num_tested),
         per_prof = as.numeric(per_prof))

print(charter_comparison)
```

------------------------------------------------------------------------

## 11. Rural districts struggle with limited resources

Rural districts in New York face unique challenges including sparse
population, limited tax base, and difficulty attracting teachers, which
affect student outcomes.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Rural districts
rural_results <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name == "All Students",
         grepl("Rural", entity_name)) |>
  select(entity_name, num_tested, per_prof) |>
  mutate(num_tested = as.numeric(num_tested),
         per_prof = as.numeric(per_prof))

print(rural_results)
```

------------------------------------------------------------------------

## 12. Gender gaps favor females in ELA, males in Math

Traditional gender patterns persist in New York assessment data, with
females outperforming males in ELA and the pattern reversing somewhat in
Math.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)
assess_math <- fetch_assessment(2024, subject = "math", tidy = FALSE, use_cache = TRUE)

# Gender comparison
gender_ela <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name %in% c("Female", "Male"),
         grepl("New York City", entity_name)) |>
  mutate(subject = "ELA")

gender_math <- assess_math |>
  filter(grepl("3_8", assessment_name),
         subgroup_name %in% c("Female", "Male"),
         grepl("New York City", entity_name)) |>
  mutate(subject = "Math")

gender_gaps <- bind_rows(gender_ela, gender_math) |>
  select(subject, subgroup_name, per_prof) |>
  mutate(per_prof = as.numeric(per_prof))

print(gender_gaps)
```

------------------------------------------------------------------------

## 13. Students with disabilities have significantly lower proficiency

Special education students face significant achievement gaps, though the
gap varies by disability category and support level.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Students with disabilities
swd_comparison <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name %in% c("General Education Students", "Students with Disabilities"),
         grepl("New York City", entity_name)) |>
  select(subgroup_name, num_tested, per_prof) |>
  mutate(num_tested = as.numeric(num_tested),
         per_prof = as.numeric(per_prof))

print(swd_comparison)
```

------------------------------------------------------------------------

## 14. Level 4 (Exceeded Standards) rates reveal the top performers

Looking beyond basic proficiency, Level 4 rates show where students are
truly excelling and ready for advanced work.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Level 4 comparison by category
level4_rates <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name == "All Students",
         grepl("Need/Resource Category", entity_name)) |>
  select(entity_name, level4_pcttested) |>
  mutate(level4_pcttested = as.numeric(level4_pcttested)) |>
  arrange(desc(level4_pcttested))

print(level4_rates)
```

------------------------------------------------------------------------

## 15. County-level data reveals geographic patterns

Assessment results vary significantly across New York’s 62 counties,
reflecting regional economic and demographic differences.

``` r
library(nyschooldata)
library(dplyr)

assess_ela <- fetch_assessment(2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Top 10 counties by proficiency
county_results <- assess_ela |>
  filter(grepl("3_8", assessment_name),
         subgroup_name == "All Students",
         entity_type == "county") |>
  select(entity_name, num_tested, per_prof) |>
  mutate(num_tested = as.numeric(num_tested),
         per_prof = as.numeric(per_prof)) |>
  arrange(desc(per_prof)) |>
  head(10)

print(county_results)
```

------------------------------------------------------------------------

## Working with Tidy Format

For detailed analysis, use tidy format which pivots proficiency levels
into rows:

``` r
library(nyschooldata)
library(dplyr)

# Fetch in tidy format
assess_tidy <- fetch_assessment(2024, subject = "ela", tidy = TRUE, use_cache = TRUE)

# Calculate proficiency rates by aggregating Level 3 and 4
proficiency_by_grade <- assess_tidy |>
  filter(grepl("^ELA[3-8]$", assessment_name),
         subgroup_name == "All Students",
         grepl("New York City", entity_name),
         is_proficient) |>
  group_by(assessment_name) |>
  summarize(pct_proficient = sum(pct, na.rm = TRUE))

print(proficiency_by_grade)
```

------------------------------------------------------------------------

## Multi-Year Analysis

Track trends over time with multi-year data:

``` r
library(nyschooldata)
library(dplyr)

# Fetch 2021-2024 (note: 2020 excluded automatically)
assess_multi <- fetch_assessment_multi(2021:2024, subject = "ela", tidy = FALSE, use_cache = TRUE)

# Track NYC proficiency over time
nyc_trend <- assess_multi |>
  filter(grepl("3_8", assessment_name),
         subgroup_name == "All Students",
         grepl("New York City Districts", entity_name)) |>
  select(year, per_prof) |>
  mutate(per_prof = as.numeric(per_prof))

print(nyc_trend)
```

------------------------------------------------------------------------

## Data Notes

### Data Source

- **URL:** <https://data.nysed.gov/downloads.php>
- **Format:** Access Database (.mdb) in ZIP archive
- **Years Available:** 2014-2019, 2021-2025 (no 2020 due to COVID-19)

### Suppression Rules

- Counts \<5 are suppressed and displayed as “s”
- Percentages are suppressed when underlying counts are \<5
- Some subgroup data may be suppressed to prevent identification

### Proficiency Levels

- **Level 1:** Did Not Meet Standards
- **Level 2:** Partially Met Standards
- **Level 3:** Met Standards (considered proficient)
- **Level 4:** Exceeded Standards (considered proficient)

### Known Caveats

- 2020 data unavailable due to COVID-19 testing waiver
- Assessment standards changed over time (not directly comparable across
  all years)
- NYC charter school data reported separately from district schools

------------------------------------------------------------------------

## Session Info

``` r
sessionInfo()
```

    ## R version 4.5.2 (2025-10-31)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.3 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
    ##  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
    ##  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
    ## [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] tidyr_1.3.2        scales_1.4.0       ggplot2_4.0.1      dplyr_1.1.4       
    ## [5] nyschooldata_0.1.0
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] gtable_0.3.6       jsonlite_2.0.0     compiler_4.5.2     tidyselect_1.2.1  
    ##  [5] jquerylib_0.1.4    systemfonts_1.3.1  textshaping_1.0.4  yaml_2.3.12       
    ##  [9] fastmap_1.2.0      R6_2.6.1           generics_0.1.4     knitr_1.51        
    ## [13] tibble_3.3.1       desc_1.4.3         bslib_0.9.0        pillar_1.11.1     
    ## [17] RColorBrewer_1.1-3 rlang_1.1.7        cachem_1.1.0       xfun_0.56         
    ## [21] fs_1.6.6           sass_0.4.10        S7_0.2.1           cli_3.6.5         
    ## [25] pkgdown_2.2.0      withr_3.0.2        magrittr_2.0.4     digest_0.6.39     
    ## [29] grid_4.5.2         lifecycle_1.0.5    vctrs_0.7.1        evaluate_1.0.5    
    ## [33] glue_1.8.0         farver_2.1.2       codetools_0.2-20   ragg_1.5.0        
    ## [37] purrr_1.2.1        rmarkdown_2.30     tools_4.5.2        pkgconfig_2.0.3   
    ## [41] htmltools_0.5.9
