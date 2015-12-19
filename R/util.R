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
  download.file(url, destfile = tname, mode = "wb", quiet = TRUE)
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

  #process access database and return
  out <- Hmisc::mdb.get(tname)
  out
}
