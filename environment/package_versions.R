pkgs <- c("rmarkdown","knitr","ggplot2","dplyr","tidyr","recipes",
          "yardstick","ranger","glmnet","gbm")
cat("R version:\n")
print(R.version.string)
cat("\nPackage versions:\n")
for (p in pkgs) {
  v <- if (requireNamespace(p, quietly=TRUE)) as.character(packageVersion(p)) else "NOT INSTALLED"
  cat(sprintf("%-12s %s\n", p, v))
}
