# ggimg: The Missing Image Primitive for ggplot2

**Author:** Taylor B. Arnold<br/>
**License:** [GPL-2](https://opensource.org/licenses/GPL-2.0)

[![CRAN Version](http://www.r-pkg.org/badges/version/ggimg)](https://CRAN.R-project.org/package=ggimg) [![Travis-CI Build Status](https://travis-ci.org/statsmaths/ggimg.svg?branch=master)](https://travis-ci.org/statsmaths/ggimg) ![Downloads](http://cranlogs.r-pkg.org/badges/ggimg)
[![Codecov test coverage](https://codecov.io/gh/statsmaths/ggimg/branch/master/graph/badge.svg)](https://codecov.io/gh/statsmaths/ggimg?branch=master)

## Installation

The package is currently only available on GitHub and can be installed with

```{r}
remotes::install_github("statsmaths/ggimg")
```

It is planned to submit the package to CRAN by the end of the month
(March 2020).

## Overview

The **ggplot2** R package provides over 50 types of geometry layers, with many
of these internally built up from a small set of primitive graphic types such
as `geom_polygon` and `geom_rect`. Putting these elements together provides
the ability to create a wide variety of data visualizations. Curiously, however,
there is currently no default layer for displaying a collection of images.
The function `geom_raster` allows for displaying a grid *as* an image and
`annotation_raster` makes it possible to add a single to a plot. But what if
we have an image associated with each row of our dataset and want to display
these on the plot? Some other packages, such as **ggimage**, provide a complete
set of functions for working with images, however they require additional
external dependencies and are not convenient for quick tinkering, hands-on
workshops, or as dependencies for other packages.

The package **ggimg** provides a single new geometry, `geom_img`,
that displays one image for each row in the corresponding dataset. It has five
required aesthetics and one optional aesthetics as follows:

- **xmin**, **xmax**, **ymin**, **ymax**: Coordinates of a bounding box in which
to display the image.
- **img**: the image to display. Either be a local path to a PNG or JPEG
file, a URL starting with "http", or the raster image already as a matrix or
array with 1-4 color channels.
- **alpha**: Desired opacity of the image. Images can contain a native alpha
component,  which will be used if alpha is a negative number (the default).
If alpha is negative and no alpha channel is present, an alpha value of 1 is
assumed.

There are many possibilities for extending the package to deal with other
image types, different ways of defining the image region (height and width;
max/min dimension for preserving aspect ratios), and many kinds of image
preprocessing that can be done. However, as mentioned above, this package for
the moment is intended to only provide a low-level interface that can be easily
maintained in used in down-stream scripts and packages. For example, check out
my package [ggmaptile](https://github.com/statsmaths/ggmaptile) which uses
`geom_img` to display slippy map tiles underneath geospatial datasets.

## Example Usage

As an example of how to use the `geom_img` layer, we will use some data about
the 50 highest grossing animated U.S. films and their movie posters. The data
is included with the package, along with a thumbnail image of each movie's
poster.

To start, we read in the dataset, which includes one row for each movie along
with a path to the movie poster and some additional metadata. We will also add
a column containing the full path to the images, which are installed in the
same location as the package.

```{r}
library(ggimg)
library(ggplot2)
library(dplyr)

posters <- mutate(posters,
  path = file.path(system.file("extdata", package="ggimg"), img)
)
posters
```
```
# A tibble: 50 x 12
    year title img   rating_count  gross genre rating runtime stars metacritic
   <dbl> <chr> <chr>        <dbl>  <dbl> <chr> <chr>    <dbl> <dbl>      <dbl>
 1  2018 Incr… 2018…       226170 6.09e8 Anim… PG         118   7.6         NA
 2  2019 The … 2019…       168828 5.40e8 Anim… PG         118   6.9         55
 3  2016 Find… 2016…       224980 4.86e8 Anim… PG          97   7.3         NA
 4  2004 Shre… 2004…       398797 4.36e8 Anim… PG          93   7.2         NA
 5  2019 Toy … 2019…       159927 4.33e8 Anim… G          100   7.8         NA
 6  2010 Toy … 2010…       719003 4.15e8 Anim… G          103   8.3         NA
 7  2013 Froz… 2013…       545450 4.01e8 Anim… PG         102   7.5         NA
 8  2003 Find… 2003…       903078 3.81e8 Anim… G          100   8.1         NA
 9  2016 The … 2016…       173603 3.68e8 Anim… PG          87   6.5         NA
10  2013 Desp… 2013…       355343 3.68e8 Anim… PG          98   7.3         NA
# … with 40 more rows, and 2 more variables: description <chr>, path <chr>
```

Let's plot the year each film was released along the x-axis and its score on
IMDb on the y-axis. We will set the height and with of the images to be one unit
by off-setting the year and stars variable by plus or minus one half.

```{r}
ggplot(posters) +
  geom_img(aes(
    xmin = year - 0.5,
    xmax = year + 0.5,
    ymin = stars - 0.5,
    ymax = stars + 0.5,
    img = path
  )) +
  theme_minimal()
```

![](figs/poster_scatter.jpg)

The output looks nice without much more work! Notice that because our layer
does not have an explicit 'x' or 'y' variable axis labels need to be input
manually with `labs`, if needed.

## A Longer Example

As a more flexible option, we can instead load the images into R directly and
store them as a list column in our dataset. This allows us to do all kinds of
pre- and post-processing, working with different data types, and showing images
that are created or modified within R. As an example, we can read our movie
posters into R using the `readJPEG` function:

```{r}
library(jpeg)

posters$img_array <- lapply(
  posters$path, function(path) readJPEG(path)
)
```

Here, to show more of the things that are made possible with the library,
we convert each image into its hue, saturation, and value and extract the
average saturation (how rich the colors look) and value (how bright the image
is).

```{r}
posters$hsv <- lapply(
  posters$img_array, function(img) {
    rgb2hsv(
      as.numeric(img[,,1]),
      as.numeric(img[,,2]),
      as.numeric(img[,,3]),
      maxColorValue = 1
    )
  }
)

posters$avg_sat <- sapply(posters$hsv, function(mat) mean(mat[2,]))
posters$avg_val <- sapply(posters$hsv, function(mat) mean(mat[3,]))
```

And then we will put this into our `geom_img` by passing the img_array parameter
to the img aesthetic.

```{r}
ggplot(posters) +
  geom_img(aes(
    xmin = avg_sat - 0.03,
    xmax = avg_sat + 0.03,
    ymin = avg_val - 0.03,
    ymax = avg_val + 0.03,
    img = img_array
  )) +
  theme_minimal() +
  labs(x = "Average Saturation", y = "Average Value")
```

![](figs/poster_hsv.jpg)
