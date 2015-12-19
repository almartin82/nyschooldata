#' Download and unzip a file from the web
#'
#' @param url url to a zip file
#'
#' @return list, with the temp dir and a data frame of file names from zip file.
#' @export

zip_to_temp <- function(url) {
  #download and unzip
  tname <- tempfile(pattern = "nyschooldata", tmpdir = tempdir(), fileext = ".zip")
  tdir <- tempdir()
  downloader::download(url, dest = tname, mode = "wb")
  utils::unzip(tname, exdir = tdir)

  #return a list with the directory and files
  list(dir = tdir, files = utils::unzip(tname, exdir = ".", list = TRUE))
}
