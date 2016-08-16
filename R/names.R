#' NYSD clean names
#'
#' @param name_vector character vector of school names
#'
#' @return character vector of codes
#' @export

nysd_clean_names <- function(name_vector) {

  #data
  clean <- list(
    #STATE
    "STATEWIDE − ALL DISTRICTS AND CHARTERS" = "NY State (all)",
  )

  name_vector <- sapply(X = name_vector, FUN = clean_name, clean = clean)

  out <- unname(name_vector)

  out <- gsub('NEW YORK CITY GEOGRAPHIC DISTRICT', 'CSD', out)
}


#' Clean a name vector
#'
#' @param x character vector
#'
#' @return character vector

clean_name <- function(x, clean) {
  z = clean[[x]]
  z = ifelse(is.null(z), x, z)
  return(z)
}
