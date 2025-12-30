# ==============================================================================
# Enrollment Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw NYSED enrollment data into a
# clean, standardized format.
#
# ==============================================================================

# TODO: Implement process_enr() function
# - Standardize column names
# - Parse BEDS codes into components
# - Convert enrollment counts to numeric
# - Handle suppressed data markers
#
# Example signature:
# process_enr <- function(df, end_year) {
#   # 1. Identify column mapping for this year
#   # 2. Rename columns to standard schema
#   # 3. Parse BEDS codes (12-digit: DDDDDDSSSSCC)
#   # 4. Extract district_code (6 digits) and school_code (4 digits)
#   # 5. Convert counts to numeric, handling suppression
#   # 6. Add metadata columns
# }

# TODO: Document BEDS code structure
# BEDS codes are 12 digits: DDDDDDSSSSCC
# - DDDDDD: District code (6 digits)
# - SSSS: School code (4 digits)
# - CC: Check digits (2 digits)
# NYC district code: 310000

# TODO: Implement safe_numeric() helper
# - Handle NYSED suppression markers (*, s, <5, etc.)
# - Remove commas from large numbers
# - Return NA for non-numeric values

# TODO: Handle NYC flag
# - Add is_nyc column based on district code prefix
# - NYC DOE district code starts with 31
