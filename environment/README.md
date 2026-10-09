# Recorded R environment

`sessionInfo_recorded.txt` is the supplied session record: R 4.4.1 on macOS, with installed package versions. It records a project session; it does not establish that every frozen result was generated in that exact session.

No original `renv.lock` was found. A lockfile has not been invented from the session listing. Run the following in the original R project after confirming that it reproduces the paper:

```r
source("scripts/04_capture_environment.R")
```

This creates `renv.lock` from installed dependencies. Review it and commit it alongside the analysis. The capture step requires R and the original packages. PDF rendering also requires Pandoc and a LaTeX installation.
