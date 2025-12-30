# ==============================================================================
# Enrollment Data Fetching Functions
# ==============================================================================
#
# This file contains functions for downloading enrollment data from the
# New York State Education Department (NYSED) website.
#
# ==============================================================================

# TODO: Implement fetch_enr() function
# - Download enrollment data from NYSED data portal
# - Support year parameter (end_year convention: 2024 = 2023-24 school year)
# - Implement caching via use_cache parameter
# - Return tidy or wide format based on tidy parameter
#
# Example signature:
# fetch_enr <- function(end_year, tidy = TRUE, use_cache = TRUE) {
#   # 1. Validate year
#   # 2. Check cache
#   # 3. Download raw data via get_raw_enr()
#   # 4. Process via process_enr()
#   # 5. Optionally tidy via tidy_enr()
#   # 6. Cache results
#   # 7. Return data frame
# }

# TODO: Explore NYSED data sources
# - Primary: https://data.nysed.gov/
# - Look for enrollment downloads section
# - Identify file formats (Excel, CSV, etc.)
# - Document URL patterns for different years

# TODO: Handle NYC special case
# - NYC DOE is a single district (BEDS code prefix 310000)
# - Contains ~1,800 schools
# - May need InfoHub data for CSD-level breakdowns
