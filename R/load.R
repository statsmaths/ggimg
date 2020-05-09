#' Utility Function to Load Image Arrays
#'
#' Can be used within a pipeline of dplyr verbs to load images as a list
#' column. Images that cannot be loaded will be returned as \code{NULL}
#' rather than producing an error.
#'
#' @param path     character vector giving the path to the images
#'
#' @author Taylor B. Arnold, \email{taylor.arnold@@acm.org}
#'
#' @export
ggimg_util_load <- function(path)
{
  lapply(path, function(v) fix_img_dims(load_img(v, strict=FALSE)))
}
