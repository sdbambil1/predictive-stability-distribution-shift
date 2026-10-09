# Run from the repository root in the original, verified R environment.
if (!requireNamespace("renv", quietly = TRUE)) {
  stop("Install renv before capturing the project environment.")
}
deps <- renv::dependencies(c("manuscript", "analysis", "scripts", "environment"), progress = FALSE)
pkgs <- sort(unique(c(deps$Package, "rmarkdown", "knitr", "renv")))
pkgs <- pkgs[!is.na(pkgs) & nzchar(pkgs)]
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Required packages missing: ", paste(missing, collapse = ", "))
}
renv::snapshot(packages = pkgs, lockfile = "renv.lock", prompt = FALSE)
writeLines(capture.output(sessionInfo()), "environment/sessionInfo_verified.txt")
