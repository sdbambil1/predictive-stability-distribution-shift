# Data dictionary

See `DATA_DICTIONARY.csv` for the 18 required input fields and the derived `LoanToAnnualIncome` predictor. Roles and validation rules come from `analysis/empirical_pipeline.Rmd`; plain-language descriptions follow the supplied variable names. These descriptions are not a substitute for the original dataset codebook.

The main input has 255,347 records and 29,653 defaults. `LoanID` is not a predictor. `Default` must be complete and coded 0/1. The default horizon, currency conventions, and several measurement units are not established in the archived project materials; do not infer them when reporting the findings.

Categorical values are read from the input data, and preprocessing is estimated on the training partition. See `data/README.md` for dataset access and checksum instructions. No row-level dataset is redistributed.

The publication manuscript uses 16 original predictors plus `LoanToAnnualIncome`, computed as `LoanAmount / Income` when income is finite and positive, otherwise missing. The variable name reflects the pipeline; the source measurement-period convention should still be verified.
