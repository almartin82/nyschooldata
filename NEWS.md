# nyschooldata 0.2.6
* supports 2017 NYSED data

# nyschooldata 0.2.5
* `custom_aggregate` function for creating campus-level averages inside a school.
* `p_proficiency_hist()` visualization.

# nyschooldata 0.2.4
* bugfix on `aggregate_grades` that was causing duplicate rows in `assess_growth` and `cohort_growth`.

# nyschooldata 0.2.3
* new percentile functions and cache of some data in `\data`

# nyschooldata 0.2.2
* `prof_attainment_percentile` and `scale_attainment_percentile`

# nyschooldata 0.2.1
* fix for `assess_growth` with aggregated data

# nyschooldata 0.2.0
* aggregation functions

# nyschooldata 0.1.1
* bedscode processing

# nyschooldata 0.1.0
* `cohort_growth`

# nyschooldata 0.0.6
* `assess_growth`

# nyschooldata 0.0.5
* `clean_assess_db` and `fetch_assess_db`

# nyschooldata 0.0.4
* added 2016 assessment database

# nyschooldata 0.0.3
* refactored unzip/download code into separate functions in `util.R`, with tests
* removed `downloader` dependency
* added `rc_db.R` functions (`get_raw_rc_db()`), with tests

# nyschooldata 0.0.2
* added wercker CI files
* documentation and build status

# nyschooldata 0.0.1
* initial commits
* assessment database, 2013-2015, using helper in Hmisc
