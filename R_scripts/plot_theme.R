# generating new theme
theme_ajs <- function(
  base_size = 22,
  base_family = "",
  base_line_size = base_size / 170,
  base_rect_size = base_size / 170
) {
  theme_linedraw(
    base_size = base_size,
    base_family = base_family,
    base_line_size = base_line_size
  ) %+replace%
    theme(
      axis.line = element_line(colour = "black", size = rel(0.55)),
      axis.text = element_text(color = "black", size = rel(0.5)),
      axis.ticks = element_line(colour = "black"),
      axis.title = element_text(color = "black", size = rel(0.55)),
      # legend.key.width = unit(0.35, "cm"),
      legend.position = "right",
      legend.text = element_text(colour = "black", size = rel(0.4)),
      legend.title = element_text(colour = "black", size = rel(0.45)),
      panel.background = element_rect(colour = "black", fill = NA),
      panel.grid.major = element_line("black", linetype = "dotted"),
      panel.grid.minor = element_line("black", linetype = "dotted"),
      panel.ontop = TRUE,
      plot.title = element_text(colour = "black", size = rel(0.55), hjust = 0),
      plot.subtitle = element_text(colour = "black", size = rel(0.5), hjust = 0),
      complete = TRUE
    )
}

# generating new theme
theme_map <- function(
  base_size = 11,
  base_family = "",
  base_line_size = base_size / 22,
  base_rect_size = base_size / 22
) {
  theme_linedraw(
    base_size = base_size,
    base_family = base_family,
    base_line_size = base_line_size
  ) %+replace%
    theme(
      axis.line = element_line(colour = "black", size = rel(0.55)),
      axis.text = element_text(color = "black"),
      axis.ticks = element_line(colour = "black"),
      axis.title = element_text(color = "black"),
      legend.key.width = unit(10.75, "cm"),
      legend.position = "bottom",
      legend.text = element_text(colour = "black"),
      legend.title = element_text(colour = "black"),
      panel.background = element_rect(colour = "black", fill = NA),
      panel.grid.major = element_line("black", linetype = "dotted"),
      panel.grid.minor = element_line("black", linetype = "dotted"),
      panel.ontop = TRUE,
      plot.title = element_text(colour = "black", hjust = 0),
      plot.subtitle = element_text(colour = "black", hjust = 0),
      complete = TRUE
    )
}
