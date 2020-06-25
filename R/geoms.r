GeomXSideBar <- ggproto("XSideBar",
                        GeomTile,
                        requied_aes = c("x","y"),
                        default_aes = aes(xfill = "grey20",
                                          width = 1, height = 1,
                                          size = 0.1, alpha = 1, location = "bottom"),
                        draw_key = function(data, params, size){
                          {
                            #browser()
                            if (is.null(data$size)) {
                              data$size <- 0.5
                            }
                            lwd <- min(data$size, min(size)/4)
                            rectGrob(width = unit(1, "npc") - unit(lwd, "mm"),
                                     height = unit(1,"npc") - unit(lwd, "mm"),
                                     gp = gpar(col = data$colour %||% NA,
                                               fill = alpha(data$xfill %||% "grey20", data$alpha),
                                               lty = data$linetype %||% 1,
                                               lwd = lwd * .pt,
                                               linejoin = params$linejoin %||% "mitre",
                                               lineend = if (identical(params$linejoin,"round")) "round" else "square"))
                          }
                        },
                        setup_data = function(data, params){
                          #browser()
                          #pad the width and height
                          data$width <- data$width %||% params$width %||% resolution(data$x, FALSE)
                          yres <- if(resolution(data$y, FALSE)!=1) (diff(range(data$y))*.05) else 1
                          data$height <- data$height %||% params$height %||% yres
                          data$location <- data$location %||% params$location
                          loc <- unique(data$location)
                          if(!loc%in%c("bottom","top")||length(loc)>1){
                            stop("xbar location must be either \"bottom\" or \"top\"\n")
                          }
                          if(loc=="bottom"){
                            data$yint <- min(data$y) - unique(data$height)
                          } else if(loc=="top"){
                            data$yint <- max(data$y) + unique(data$height)
                          }
                          transform(data, xmin = x - width/2, xmax = x + width/2, width = NULL,
                                    ymin = yint - height/2, ymax = yint + height/2, height = NULL)
                        },
                        draw_panel = function (self, data, panel_params, coord, linejoin = "mitre")
                        {
                          #browser()
                          loc <- unique(data$location)
                          if(loc=="bottom"){
                            indx <- 1
                            .expand <- .6
                          } else if(loc=="top"){
                            indx <- 2
                            .expand <- -.6
                          }
                          if(panel_params$y$is_discrete()){
                            # panel_params$y$continuous_range[indx] <- panel_params$y$continuous_range[indx] + .expand
                            # panel_params$y$limits <- if(loc=="bottom") c(panel_params$y$limits, "xbar") else c("xbar", panel_params$y$limits)
                          } else {
                            panel_params$y$continuous_range[indx] <- panel_params$y$limits[indx]
                          }
                          if (!coord$is_linear()) {
                            aesthetics <- setdiff(names(data), c("x", "y", "xmin",
                                                                 "xmax", "ymin", "ymax"))
                            polys <- lapply(split(data, seq_len(nrow(data))), function(row) {
                              poly <- rect_to_poly(row$xmin, row$xmax, row$ymin,
                                                   row$ymax)
                              aes <- new_data_frame(row[aesthetics])[rep(1, 5),]
                              GeomPolygon$draw_panel(cbind(poly, aes), panel_params,coord)
                            })
                            ggname("bar", do.call("grobTree", polys))
                          }
                          else {
                            coords <- coord$transform(data, panel_params)
                            ggname("geom_rect", rectGrob(coords$xmin, coords$ymax,
                                                         width = coords$xmax - coords$xmin,
                                                         height = coords$ymax - coords$ymin,
                                                         default.units = "native", just = c("left","top"),
                                                         gp = gpar(col = coords$colour %||% alpha(coords$xfill,coords$alpha),
                                                                   fill = alpha(coords$xfill,coords$alpha),
                                                                   lwd = coords$size * .pt,
                                                                   lty = coords$linetype,
                                                                   linejoin = linejoin,
                                                                   lineend = if (identical(linejoin,"round"))"round" else "square")))
                          }
                        }


)


geom_xsidebar <- function(mapping = NULL, data = NULL,
                          na.rm = FALSE, show.legend = TRUE,
                          position = "identity",stat = "identity", inherit.aes = TRUE, ...) {
  #browser()
  # if(!location%in%c("bottom","top")){
  #   stop("location must be specified as top or bottom")
  # }
  layer(
    geom = GeomXSideBar, mapping = mapping, data = data, stat = stat,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )

}
