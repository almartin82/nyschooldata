
fake_fetch_assess_db <- function(year) {
  out <- paste(
    'clean', stringr::str_sub(as.character(year), start = -2), sep = '_'
  ) %>% get()

  out
}
