context("rc_db")

test_that("get_raw_rc_db correctly reads 2010 file", {
  ex <- get_raw_rc_db(2010)

  expect_equal(length(ex), 41)
  expect_equal(
    lapply(ex, nrow) %>% unlist() %>% unname(),
    c(1896L, 16061L, 15558L, 16255L, 13959L, 692L, 89220L, 87752L,
      85789L, 66132L, 58984L, 58648L, 16086L, 19445L, 16489L, 5496L,
      89343L, 87937L, 85981L, 66361L, 59113L, 58786L, 38132L, 156800L,
      4617L, 81057L, 206808L, 87873L, 57609L, 30993L, 85831L, 58693L,
      16044L, 52354L, 52354L, 52354L, 52354L, 52354L, 466745L, 16255L,
      19445L)
  )
  expect_equal(
    names(ex),
    c("Aspirational Goal", "Attendance and Suspensions", "Average Class Size",
      "BEDS Day Enrollment", "BOCES and N/RC", "Career and Technical Education Programs",
      "ELA3 Subgroup Results", "ELA4 Subgroup Results", "ELA5 Subgroup Results",
      "ELA6 Subgroup Results", "ELA7 Subgroup Results", "ELA8 Subgroup Results",
      "Financial Information", "High School Noncompleters", "High School Post-Graduation Plans of Completers",
      "Institution Grouping", "Math3 Subgroup Results", "Math4 Subgroup Results",
      "Math5 Subgroup Results", "Math6 Subgroup Results", "Math7 Subgroup Results",
      "Math8 Subgroup Results", "New York State Alternate Assessment (NYSAA) Annual Results",
      "NYSESLAT Annual Results", "Recently Arrived LEP Students NOT Tested on ELA NYSTP",
      "Regents Competency Test (RCT) Annual Results", "Regents Examination Annual Results",
      "Science4 Subgroup Results", "Science8 Subgroup Results", "Second Language Proficiency (SLP) Test Annual Results",
      "SocialStudies5 Subgroup Results", "SocialStudies8 Subgroup Results",
      "Staff", "Total Cohort ELA Subgroup Results", "Total Cohort Global Hist & Geo Subgroup Results",
      "Total Cohort Math Subgroup Results", "Total Cohort Science Subgroup Results",
      "Total Cohort US Hist & Govt Subgroup Results", "Accountability",
      "Demographic Factors", "High School Completers")
  )
})
