# ==============================================================================
# Enrollment Data Tidying Functions
# ==============================================================================
#
# This file contains functions for transforming enrollment data from wide
# format to long (tidy) format and identifying aggregation levels.
#
# ==============================================================================

# TODO: Implement tidy_enr() function
# - Transform wide enrollment data to long format
# - Create subgroup column for demographics
# - Handle grade-level enrollment columns
#
# Example signature:
# tidy_enr <- function(df) {
#   # 1. Identify invariant columns (identifiers)
#   # 2. Pivot demographic columns to long format
#   # 3. Pivot grade-level columns to long format
#   # 4. Calculate percentages
#   # 5. Combine and return
# }

# TODO: Implement id_enr_aggs() function
# - Add is_state, is_district, is_school flags
# - Add is_charter flag based on charter indicators
# - Add is_nyc flag for NYC schools

# TODO: Implement enr_grade_aggs() function
# - Create K-8, 9-12, K-12 aggregates
# - Similar to Illinois implementation
