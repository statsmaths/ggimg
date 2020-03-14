#' Display PNG and JPEG Images given Bounding Boxes
#'
#' @param mapping      Set of aesthetic mappings created by [aes()] or
#'                     [aes_()]. If specified and `inherit.aes = TRUE` (the
#'                     default), it is combined with the default mapping at the
#'                     top level of the plot. You must supply `mapping` if there
#'                     is no plot mapping.
#' @param data         The data to be displayed in this layer. There are three
#'                     options:
#'
#'                     If `NULL`, the default, the data is inherited from the
#'                     plot data as specified in the call to [ggplot()].
#'
#'                     A `data.frame`, or other object, will override the plot
#'                     data. All objects will be fortified to produce a data
#'                     frame.
#'
#'                     A `function` will be called with a single argument,
#'                     the plot data. The return value must be a `data.frame`,
#'                     and will be used as the layer data. A `function` can be
#'                     created from a `formula` (e.g. `~ head(.x, 10)`).
#' @param stat         The statistical transformation to use on the data for
#'                     this layer, as a string.
#' @param position     Position adjustment, either as a string, or the result of
#'                     a call to a position adjustment function.
#' @param show.legend  logical. Should this layer be included in the legends?
#'                     `NA`, the default, includes if any aesthetics are mapped.
#'                     `FALSE` never includes, and `TRUE` always includes.
#'                     It can also be a named logical vector to finely select
#'                     the aesthetics to display.
#' @param inherit.aes  If `FALSE`, overrides the default aesthetics,
#'                     rather than combining with them. This is most useful for
#'                     helper functions that define both data and aesthetics
#'                     and shouldn't inherit behaviour from the default plot
#'                     specification, e.g. [borders()].
#'
#' @author Taylor B. Arnold, \email{taylor.arnold@@acm.org}
#'
#' @export
geom_image_bbox <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  show.legend = NA,
  inherit.aes = TRUE
) {
  ggplot2::layer(
    geom = GeomImageBBox,
    mapping = mapping,
    data = data,
    stat = stat,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes
  )
}

#' @export
#' @rdname geom_image_bbox
#' @importFrom png readPNG
#' @importFrom jpeg readJPEG
GeomImageBBox <- ggplot2::ggproto(
  "GeomImageBBox",
  ggplot2::Geom,
  required_aes = c("xmin", "xmax", "ymin", "ymax", "path"),
  non_missing_aes = c("alpha"),
  default_aes = ggplot2::aes(
    alpha = 1
  ),

  draw_key = ggplot2::draw_key_point,

  draw_panel = function(data, panel_params, coord) {
    coords <- coord$transform(data, panel_params)
    grobs <- vector("list", length(coords$path))
    class(grobs) <- "gList"
    for (i in seq_along(grobs))
    {
      nc <- nchar(coords$path[i])
      ext <- tolower(substr(coords$path[i], nc - 2L, nc))
      if ( ext == "png" )
      {
        img <- png::readPNG(coords$path[i])
      } else if ( ext %in% c("peg", "jpg") ) {
        img <- jpeg::readJPEG(coords$path[i])
      } else {
        stop(sprintf("Cannot open file %s", coords$path[i]))
      }

      img <- fix_img_dims(img, alpha = coords$alpha[i])

      grobs[[i]] <- grid::rasterGrob(
        img,
        coords$xmin[i],
        coords$ymin[i],
        coords$xmax[i] - coords$xmin[i],
        coords$ymax[i] - coords$ymin[i],
        hjust = 0,
        vjust = 0
      )
    }
    return(grobs)
  }
)

fix_img_dims <- function(img, alpha)
{
  # Black and white images may be returned as a matrix
  if (length(dim(img)) == 2L) img <- array(img, dim = c(dim(img), 1L))

  nchannel <- dim(img)[3]
  if (nchannel == 1L)
  {
    alpha_channel <- array(alpha, dim = c(dim(img)[1:2], 1L))
    img <- abind::abind(img, img, img, alpha_channel, along = 3L)
  } else if (nchannel == 2L) {
    img <- img[, , 1L, drop=FALSE]
    alpha_channel <- array(alpha, dim = c(dim(img)[1:2], 1L))
    img <- abind::abind(img, img, img, alpha_channel, along = 3L)
  } else if (nchannel == 3L) {
    alpha_channel <- array(alpha, dim = c(dim(img)[1:2], 1L))
    img <- abind::abind(img, alpha_channel, along = 3L)
  } else if (nchannel == 4L) {
    img[,,4L] <- alpha
  } else {
    stop(
      sprintf("We do not know how to display an image with %d channels",
      nchannel)
    )
  }

  return(img)
}
