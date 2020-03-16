# ggimg: The Missing Image Primative for ggplot2

The **ggplot2** R package provides over 50 types of geometry layers, with many
of these internally built up from a small set of primative graphic types such
as `geom_polygon` and `geom_rect`. Putting these elements together provides
the ability to create a wide variety of data visualizations. Curiously, however,
there is currently no default layer for displaying a collection of images.
The function `geom_raster` allows one to displaying a grid *as* an image and
`annotation_raster` makes it possible to add a single to a plot. But what if
we have an image associated with each row of our dataset and want to display
these on the plot? Some other packages, such as **ggimage**, provide a complete
set of functions for working with images, however they require additional
external dependencies and are not convenient for quick tinkering, hands-on
workshops, or as dependencies for other packages.

The package **ggimg** provides a single new geometry type called `geom_img`
that displays one image for each row in the corresponding dataset. It has five
required aesthetics and one optional aesthetics as follows:

- **xmin**, **xmax**, **ymin**, **ymax**: Coordinates of a bounding box in which
to display the image.
- **img**: the image to display. Either be a local path to a PNG or JPEG
file, a URL starting with "http", or the raster image already as a matrix or
array with 1-4 color channels.
- alpha: Desired opacity of the image. Images can contain a native alpha
component,  which will be used if alpha is a negative number (the default).
If alpha is negative and no alpha channel is present, an alpha value of 1 is
assumed.






A few other packages,
