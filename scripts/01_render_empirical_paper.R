# Run the empirical manuscript exactly as frozen.
# Execute from the package root.

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  stop("Install rmarkdown first: install.packages('rmarkdown')")
}

main_data <- file.path("data", "Loan_default.csv")
stress_data <- file.path("data", "New_Loan_Validation_Data.csv")

if (!file.exists(main_data)) {
  stop("Missing data/Loan_default.csv. See data/README.md.")
}
if (!file.exists(stress_data)) {
  stop("Missing data/New_Loan_Validation_Data.csv.")
}

rmarkdown::render(
  input = file.path("manuscript", "paper.Rmd"),
  output_file = "paper_reproduced.pdf",
  params = list(
    data_path = normalizePath(main_data),
    validation_path = normalizePath(stress_data),
    output_dir = normalizePath("results/empirical", mustWork = FALSE),
    force_retrain = TRUE,
    include_neural = FALSE,
    threshold_objective = "balanced_accuracy",
    bootstrap_reps = 300,
    seed = 42,
    simulation_seed = 1998,
    simulation_reps = 500
  ),
  envir = new.env(parent = globalenv())
)
