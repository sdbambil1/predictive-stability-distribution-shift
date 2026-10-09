# Manuscript-to-repository audit

Audited against the supplied 17-page publication manuscript dated October 5, 2026. This is an artifact-consistency and summary-recalculation audit, not a fresh execution of the R models or a scientific peer review.

## Matching components

| Manuscript component | Repository evidence | Result |
| --- | --- | --- |
| Main PDF and R Markdown | manuscript/paper.pdf and manuscript/paper.Rmd | Supplied publication version; uploaded PDF hash matches original bytes |
| Empirical point estimates | results/empirical/test_metrics.csv | ROC-AUC 0.7585, PR-AUC 0.3288, Brier 0.0908, log loss 0.3111, threshold 0.1175, recall 0.6843, specificity 0.7011 agree at displayed precision |
| Calibration intercept and slope | results/empirical/calibration_summary.csv | 0.0073 and 0.9989 agree; this CSV transcribes rounded values from the earlier empirical report |
| Table 1 initial failure patterns | manuscript/data/failure_pattern_*.csv | All three strongest-condition rows agree at displayed precision; these are retained rerun summaries, not the older frozen reference files |
| Table 2 and Figures 1-2 adaptation results | manuscript/data/adaptation_probability_summary.csv | 65 method/condition groups; all 500 replications present; means and MCSEs independently recalculated from 32,500 metric records |
| Figure 3 and threshold narrative | manuscript/data/adaptation_threshold_summary.csv | Means and gain MCSE independently recalculated from 7,500 metric records; covariate endpoint thresholds 0.1598 to 0.3940 and BA gain 0.1475 agree |
| Severe-shift calibration diagnostic | verification/structural_shift_calibration_diagnostics.csv | 500 rows; means -38.24 and -17.97, medians -0.049 and 0.969, 13 absolute slopes over 10, and replication 251 agree |
| Supporting experiment and sample-size supplement | manuscript/supplementary_material.pdf, .Rmd and manuscript/data/ | Matching supplied supplement and summary inputs added; all 399 and 512 supplied verification flags are true |
| Render inputs | manuscript/data/ and bibliography | Direct CSV inputs and bibliography referenced by publication and supplement sources are present |
| Empirical pipeline design | analysis/empirical_pipeline.Rmd | 60/15/10/15 split, empirical seed 42, 0.001 selection tolerance, and derived loan-to-income feature agree with manuscript |

`manuscript_consistency_checks.csv` records the new numerical checks. The largest recalculated adaptation mean/MCSE discrepancy is about 1.3e-13. This recomputes summaries from recorded replication metrics, not borrower-level predictions. Original metric records used for the audit are retained in the working inputs; this repository does not yet include every full replication-level file.

## Corrections made

- Added the publication supplement and its source.
- Added retained rerun summaries supporting Table 1; older `results/frozen/` files remain explicitly historical references for the original verifier.
- Added the recovered 500-replication adaptation script as `scripts/06_adaptation_after_shift.R`. It uses seed 1998, independent samples of 5,000, the stated shift grids, and 99th-percentile capped, normalized importance weights. No fresh R execution was performed.
- Replaced the earlier project figures with exact extracts of publication Figures 1-3.
- Corrected the dataset uploader/source in the data README to match the manuscript.
- Added the derived LoanToAnnualIncome feature to the dictionary and corrected pipeline paths in data documentation.
- Included the analysis directory when capturing R dependencies.

## Remaining limitations before a complete reproducibility deposit

1. The manuscript R Markdown data/code availability sections have now been updated to link to GitHub and accurately state the partial deposit. The supplied PDF still has the earlier availability statements and must be regenerated from the revised source before final archival. Numerical findings and methods were unchanged.
2. Full raw simulation records, original supporting 1,000-replication scripts/settings, and the complete instrumented diagnostic script have not all been deposited. The uploaded recovered adaptation script supports the original 500-replication adaptation design, not the separate supporting designs.
3. No original renv.lock was found and R is unavailable in this audit environment. An actual lockfile must be captured in the original verified R project. Publication and supplement rendering have not been tested here.
4. Row-level empirical and stress-test inputs are omitted. Input acquisition and fingerprints are documented. Their model objects and borrower-level predictions were not independently re-audited.
5. `results/empirical/test_bootstrap_intervals_reported.csv` contains rounded intervals from the earlier empirical report. The publication manuscript does not report those intervals; do not treat it as a new publication result or merge it with a separate bootstrap run.

Zenodo archival should follow these remaining availability and reproducibility decisions. No DOI is claimed by this audit.
