# Manuscript-to-repository audit

The original numerical audit used the supplied 17-page publication manuscript dated October 5, 2026. The latest file/archive check on October 9, 2026 is recorded below. This is an artifact-consistency and summary-recalculation audit, not a fresh execution of the R models or a scientific peer review.

## Matching components

| Manuscript component | Repository evidence | Result |
| --- | --- | --- |
| Main PDF and R Markdown | manuscript/paper.pdf and manuscript/paper.Rmd | Current DOI-bearing publication version; current PDF Git blob SHA is 2081287e652a56572b85767c6c8ed933ba404574 |
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

1. The manuscript R Markdown data/code availability sections have now been updated to link to GitHub and accurately state the partial deposit. The author-regenerated PDF now contains the revised availability statements and has replaced the earlier PDF. Numerical findings and methods were unchanged.
2. Full raw simulation records, original supporting 1,000-replication scripts/settings, and the complete instrumented diagnostic script have not all been deposited. The uploaded recovered adaptation script supports the original 500-replication adaptation design, not the separate supporting designs.
3. No original renv.lock was found. R was unavailable during the original numerical audit; it was available for the subsequent PDF render. An actual lockfile must be captured in the original verified R project. The author successfully rendered the revised publication PDF in RStudio, and the supplied output was checked. Supplement rendering has not been rerun during this audit.
4. Row-level empirical and stress-test inputs are omitted. Input acquisition and fingerprints are documented. Their model objects and borrower-level predictions were not independently re-audited.
5. `results/empirical/test_bootstrap_intervals_reported.csv` contains rounded intervals from the earlier empirical report. The publication manuscript does not report those intervals; do not treat it as a new publication result or merge it with a separate bootstrap run.

Zenodo v1.0.1 has now been verified at https://doi.org/10.5281/zenodo.23256375. The remaining reproducibility limitations above still apply.

## Historical author-supplied PDF verification: October 9, 2026

The author supplied `paper_reproduced.pdf` (17 pages). It contains the revised GitHub availability wording and retains the prior scientific findings. Extracted text on pages 1-14 is unchanged; conclusion and reference text also agree after removing page-number and whitespace differences. The revised availability page was visually checked and GitHub link targets were confirmed in the PDF. The PDF replaces `manuscript/paper.pdf`; its Git blob SHA is `3f0b7e06285af92bfd969064fdf266bb77925acf`. Rendering from summary inputs is not a fresh rerun of the empirical or simulation models.

## Latest GitHub and Zenodo consistency check: October 9, 2026

- The current GitHub publication PDF is 17 pages, contains the archive DOI, and has Git blob SHA `2081287e652a56572b85767c6c8ed933ba404574`. It was rendered from the current R Markdown source and supplied summaries. Citation formatting and some page breaks differ from the earlier author-rendered PDF. Models were not rerun.
- Four empirical probability/ranking metrics, five adaptation endpoints, and five threshold/balanced-accuracy values were rechecked against GitHub CSVs and agree at the manuscript's displayed precision. All 65 adaptation probability groups and 15 threshold groups record 500 replications each.
- All 26 retained consistency flags, 399 supporting-summary flags, and 512 sensitivity flags pass. These retained flags document earlier summary checks; they are not a fresh model-execution test.
- All direct CSV inputs for the publication and supplement sources are present. All manuscript citation keys resolve to the supplied bibliography or inline reference.
- The actual Zenodo ZIP contains 61 files. Its MD5 checksum is `ad2b5bb748d44046c0ff4108b005c750`. Every archived file matches the GitHub v1.0.1 tag by Git blob hash. There are no extra files and no poster files.
- Zenodo's record title and MIT license agree with the repository metadata.
- The Zenodo archive contains the earlier PDF, source and README because v1.0.1 preceded the DOI update. Those three files differ from the current GitHub main branch. Subsequent documentation corrections are also newer than v1.0.1. Updating main does not update the published archive. A later release is needed to archive these revisions.
- `CITATION.cff` now links the verified v1.0.1 archive DOI; the DOI identifies that fixed release, not subsequent main-branch changes.
