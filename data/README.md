# Empirical inputs

## Main benchmark

The publication manuscript identifies the Kaggle Loan Default Prediction Dataset shared by NIKHIL: https://www.kaggle.com/datasets/nikhil1e9/loan-default . It reports attribution to Coursera's Loan Default Prediction Challenge and a CC0 license. The original collection process and default horizon remain undocumented; the manuscript treats it as a prediction benchmark.

Place `Loan_default.csv` in this directory to rerun `analysis/empirical_pipeline.Rmd` through `scripts/01_render_empirical_paper.R`. Expected rows: 255,347. SHA-256: `1d7556a9071e7f9e872dc05a0cad174229fb1164b1cf3470ad35eed195c24278`. The main CSV is not redistributed.

## Separate stress-test input

`New_Loan_Validation_Data.csv` is a synthetic project stress-test input, not independent external validation. It is omitted from this public repository. The supporting empirical renderer requires it separately. See `DATA_MANIFEST.json` for the supplied fingerprint.

## Publication summary inputs

`manuscript/data/` contains simulation summaries and supporting records. These contain aggregate or replication-level statistical metrics, not individual loan records. The publication and supplement can be rendered from these inputs without the empirical row-level datasets.
