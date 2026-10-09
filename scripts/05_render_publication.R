# Run from repository root. Requires rmarkdown, knitr, ggplot2, Pandoc and XeLaTeX.
if (!requireNamespace("rmarkdown", quietly = TRUE)) stop("Install rmarkdown first.")
rmarkdown::render(
  input = file.path("manuscript", "paper.Rmd"),
  output_file = "paper_reproduced.pdf",
  knit_root_dir = normalizePath("manuscript"),
  envir = new.env(parent = globalenv())
)
