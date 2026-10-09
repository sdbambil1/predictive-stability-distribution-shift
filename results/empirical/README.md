# Empirical result provenance

`test_metrics.csv` and `validation_comparison.csv` are supplied project outputs. The test CSV matches the uploaded manuscript's point estimates: raw logistic regression, log loss 0.31110699, Brier 0.09084911, ROC-AUC 0.75845265, PR-AUC 0.32882091, and threshold 0.1175.

The validation CSV contains all tuning configurations; the manuscript reports selected configurations by model family. Do not treat configuration suffixes as separate model families.

`calibration_summary.csv` and `test_bootstrap_intervals_reported.csv` transcribe the rounded values in manuscript Tables 13 and 11. They are manuscript transcriptions, not newly calculated estimates or full-precision original exports.

A separate supplied bootstrap-interval export had matching point estimates but different interval endpoints from the frozen PDF. It is excluded here to avoid mixing runs. No analyses were rerun during this upload.
