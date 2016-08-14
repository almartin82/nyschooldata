#' Download and unzip a file from the web
#'
#' @param url url to a zip file
#'
#' @return list, with the temp dir and a data frame of file names from zip file.

zip_to_temp <- function(url) {
  #download and unzip
  tdir <- tempdir()
  tname <- tempfile(pattern = "nyschooldata", tmpdir = tdir, fileext = ".zip")
  prev_timeout <- getOption('timeout')
  options(timeout = 900)
  httr::GET(url = url, httr::write_disk(tname))
  #download.file(url, destfile = tname, mode = "wb", quiet = TRUE)
  options(timeout = prev_timeout)
  utils::unzip(tname, exdir = tdir)

  #return a list with the directory and files
  list(dir = tdir, files = utils::unzip(tname, exdir = ".", list = TRUE))
}


#' Finds .mdb files in a temp directory and processes as data frames
#'
#' @param file_list list, output of zip_to_temp
#'
#' @return a list of data frames

extract_mdb <- function(file_list) {

  #identify access file
  mask <- grepl('.mdb', file_list$files$Name, fixed = TRUE)
  mdb_file <- file_list$files[mask, ]$Name
  mdb_file <- file.path(file_list$dir, mdb_file)

  #file names have reserved characters that mdbtools can't handle.  rename.
  tname <- tempfile(
    pattern = "access", tmpdir = file_list$dir, fileext = ".mdb"
  )
  file.rename(mdb_file, tname)

  #WINDOWS
  #process access database and return
#   connect_string <<- paste0(
#     "Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=",
#     gsub('\\', '/', tname, fixed = TRUE)
#   )
#   cat(connect_string)
#   out <- RODBC::odbcDriverConnect(connect_string)

  out <- Hmisc::mdb.get(
    tname, stringsAsFactors = FALSE, colClasses = 'character'
  )
  out
}


#' Is a vector sequential
#'
#' @param x integer vector
#'
#' @return logical
#' @export

is_sequential <- function(x){
  all(abs(diff(x)) == 1)
}


#' Finds grade runs
#'
#' @param min_gr smallest grade
#' @param max_gr largest grade
#'
#' @return list with grade runs
#' @export

grade_runs <- function(min_gr, max_gr) {

  grade_span <- 2:(max_gr - min_gr)

  #returns list of lists of vectors
  all_combs <- lapply(
    grade_span, function(x) combn(c(min_gr:max_gr), x, simplify = FALSE))

  #removes one level of heirarchy from all_combs (now just a list of vectors)
  all_combs <- purrr::flatten(all_combs)

  sequential_combs <- purrr::keep(all_combs, is_sequential)

  #return a list of vectors of all possible sequential permuations
  sequential_combs
}
