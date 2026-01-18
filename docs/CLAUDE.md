# State Schooldata Package

## CRITICAL DATA SOURCE RULES

**NEVER use Urban Institute API, NCES CCD, or ANY federal data source**
— the entire point of these packages is to provide STATE-LEVEL data
directly from state DOEs. Federal sources aggregate/transform data
differently and lose state-specific details. If a state DOE source is
broken, FIX IT or find an alternative STATE source — do not fall back to
federal data.

## Local Testing Before PRs (REQUIRED)

**PRs will not be merged until CI passes.** Run these checks locally
BEFORE opening a PR:

### CI Checks That Must Pass

| Check        | Local Command                                                                  | What It Tests                                  |
|--------------|--------------------------------------------------------------------------------|------------------------------------------------|
| R-CMD-check  | [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)         | Package builds, tests pass, no errors/warnings |
| Python tests | `pytest tests/test_pynyschooldata.py -v`                                       | Python wrapper works correctly                 |
| pkgdown      | [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html) | Documentation and vignettes render             |

### Quick Commands

``` r
# R package check (required)
devtools::check()

# Python tests (required)
system("pip install -e ./pynyschooldata && pytest tests/test_pynyschooldata.py -v")

# pkgdown build (required)
pkgdown::build_site()
```

### Pre-PR Checklist

Before opening a PR, verify: - \[ \]
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) —
0 errors, 0 warnings - \[ \] `pytest tests/test_pynyschooldata.py` — all
tests pass - \[ \]
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
— builds without errors - \[ \] Vignettes render (no `eval=FALSE` hacks)

## LIVE Pipeline Testing

This package includes `tests/testthat/test-pipeline-live.R` with LIVE
network tests.

### Test Categories:

1.  URL Availability - HTTP 200 checks
2.  File Download - Verify actual file (not HTML error)
3.  File Parsing - readxl/readr succeeds
4.  Column Structure - Expected columns exist
5.  get_raw_enr() - Raw data function works
6.  Data Quality - No Inf/NaN, non-negative counts
7.  Aggregation - State total \> 0
8.  Output Fidelity - tidy=TRUE matches raw

### Running Tests:

``` r
devtools::test(filter = "pipeline-live")
```

## README Images from Vignettes (REQUIRED)

**NEVER use `man/figures/` or `generate_readme_figs.R` for README
images.**

README images MUST come from pkgdown-generated vignette output so they
auto-update on merge:

``` markdown
![Chart name](https://almartin82.github.io/{package}/articles/{vignette}_files/figure-html/{chunk-name}-1.png)
```

**Why:** Vignette figures regenerate automatically when pkgdown builds.
Manual `man/figures/` requires running a separate script and is easy to
forget, causing stale/broken images.

## README Standards (REQUIRED)

### README Must Be Identical to Vignette

**CRITICAL RULE:** The README content MUST be identical to a vignette -
all code blocks, outputs, and narrative text must match exactly. This
ensures: - Code is verified to run - Outputs are real (not fabricated) -
Images are auto-generated from pkgdown - Single source of truth

### Minimum Story Count

**Every README MUST have at least 15 stories/sections** on the README
and pkgdown front page. Each story tells a data story with headline,
narrative, code, output, and visualization.

### README Story Structure (REQUIRED)

Every story/section in the README MUST follow this structure:

1.  **Headline**: A compelling, factual statement about the data
2.  **Narrative text**: Brief explanation of why this matters
3.  **Code**: R code that fetches and analyzes the data (MUST exist in a
    vignette)
4.  **Output of code**: Data table/print statement showing actual values
    (REQUIRED)
5.  **Visualization**: Chart from vignette (auto-generated from pkgdown)

### Story Verification by Claude (REQUIRED)

Claude MUST read and verify each story: - Headline must make sense and
be supported by the code and code output - Headline must not be directly
contradicted by Claude’s world knowledge - If headline is dubious or
unsupported, flag it and fix it - Year ranges in headlines must match
actual data availability

### README Must Be Interesting

README should grab attention and be compelling: - Headlines should be
surprising, newsworthy, or counterintuitive - Lead with the most
interesting findings - Tell stories that make people want to explore the
data - Avoid boring/generic statements like “enrollment changed over
time”

### Charts Must Have Content

Every visualization MUST have actual data on it: - Empty charts =
something is broken (data issue, bad filter, wrong column) - Verify
charts visually show meaningful data - If chart is empty, investigate
and fix the underlying problem

### No Broken Links

All links in README must be valid: - No 404s - No broken image URLs - No
dead vignette references - Test all links before committing

### Opening Teaser Section (REQUIRED)

README should start with: - Project motivation/why this package exists -
Link back to njschooldata mothership (the original package) - Brief
overview of what data is available (years, entities, subgroups) - A hook
that makes readers want to explore further

### Data Notes Section (REQUIRED)

README should include a Data Notes section covering: - Data source
(state DOE URL) - Available years - Suppression rules (e.g., counts \<10
suppressed) - Any known data quality issues or caveats - Census Day or
reporting period details

### Badges (REQUIRED)

README must have 4 badges in this order: 1. R CMD CHECK 2. Python tests
3. pkgdown 4. lifecycle

### Python and R Quickstart Examples (REQUIRED)

README must include quickstart code for both languages: - R installation
and basic fetch example - Python installation and basic fetch example -
Both should show the same data for consistency

### Why Code Matching Matters

The Idaho fix revealed critical bugs when README code didn’t match
vignettes: - Wrong district names (lowercase vs ALL CAPS) - Text claims
that contradicted actual data - Missing data output in examples

### Enforcement

The `state-deploy` skill verifies this before deployment: - Extracts all
README code blocks - Searches vignettes for EXACT matches - Fails
deployment if code not found in vignettes - Randomly audits packages for
claim accuracy

### What This Prevents

- ❌ Wrong district/entity names (case sensitivity, typos)
- ❌ Text claims that contradict data
- ❌ Broken code that fails silently
- ❌ Missing data output
- ❌ Empty charts with no data
- ❌ Broken image links
- ✅ Verified, accurate, reproducible examples

### Example Story

``` markdown
### 1. State enrollment grew 28% since 2002

State added 68,000 students from 2002 to 2026, bucking national trends.

```r
library(arschooldata)
library(dplyr)

enr <- fetch_enr_multi(2002:2026)

enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students) %>%
  filter(end_year %in% c(2002, 2026)) %>%
  mutate(change = n_students - lag(n_students),
         pct_change = round((n_students / lag(n_students) - 1) * 100, 1))
# Prints: 2002=XXX, 2026=YYY, change=ZZZ, pct=PP.P%
```

![Chart](https://almartin82.github.io/arschooldata/articles/...)

Chart

    ---

    ## Vignette Caching (REQUIRED)

    All packages use knitr chunk caching to speed up vignette builds and CI.

    ### Three-Part Caching Approach

    **1. Enable knitr caching in setup chunks:**
    ```r
    ```{r setup, include=FALSE}
    knitr::opts_chunk$set(
      echo = TRUE,
      message = FALSE,
      warning = FALSE,
      cache = TRUE
    )

    **2. Use cache in fetch calls:**
    ```r
    enr <- fetch_enr(2024, use_cache = TRUE)
    enr_multi <- fetch_enr_multi(2020:2024, use_cache = TRUE)

**3. Commit cache directories:** - Cache directories
(`vignettes/*_cache/`) are **committed to git** - **DO NOT** add
`*_cache/` to `.gitignore` - Cache provides reproducible builds and
faster CI

### Why Cache is Committed

- **Reproducibility:** Same cache = same output across builds
- **CI Speed:** Cache hits avoid expensive data downloads
- **Consistency:** All developers get identical vignette results
- **Stability:** Network issues don’t break vignette builds

### Cache Management

Each package has `clear_cache()` and
[`cache_status()`](https://almartin82.github.io/nyschooldata/reference/cache_status.md)
functions:

``` r
# View cached files
cache_status()

# Clear all cache
clear_cache()

# Clear specific year
clear_cache(2024)
```

Cache is stored in two locations: 1. **Vignette cache:**
`vignettes/*_cache/` (committed to git) 2. **Data cache:**
[`rappdirs::user_cache_dir()`](https://rappdirs.r-lib.org/reference/user_cache_dir.html)
(local only, not committed)

### Session Info in Vignettes (REQUIRED)

Every vignette must end with
[`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) for
reproducibility:

``` r
```{r session-info}
sessionInfo()
```

\`\`\`

------------------------------------------------------------------------

# nyschooldata

## Git Commits and PRs (EXPLICIT NO AI MENTIONS)

**CRITICAL:** NEVER reference Claude, Claude Code, or AI assistance in
commit messages or PR descriptions.

### Forbidden in Commit Messages:

- ❌ “Generated with Claude Code”
- ❌ “Co-Authored-By: Claude Sonnet”
- ❌ “AI-assisted commit”
- ❌ Any mention of Anthropic, Claude, or AI tools

### Forbidden in PR Descriptions:

- ❌ “Created with help from Claude”
- ❌ “AI-generated PR”
- ❌ References to AI assistance

### Required Format:

- ✅ Focus on WHAT changed, not HOW it was written
- ✅ Standard commit messages: “Fix: update data source URL”
- ✅ Clean PR descriptions describing changes only

### Why This Matters

This package appears in professional contexts where AI assistance must
not be visible in git history. Maintain clean, human-appearing commit
messages and PR descriptions.
