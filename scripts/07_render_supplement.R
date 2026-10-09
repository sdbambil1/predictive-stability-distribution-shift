# Run from repository root. Requires rmarkdown, knitr, ggplot2, Pandoc and XeLaTeX.
if (!requireNamespace("rmarkdown", quietly = TRUE)) stop("Install rmarkdown first.")
rmarkdown::render(
  input = file.path("manuscript", "supplementary_material.Rmd"),
  output_file = "supplementary_material_reproduced.pdf",
  knit_root_dir = normalizePath("manuscript"),
  envir = new.env(parent = globalenv())
)
