# Reproducibility Package

## Predictive Stability Under Distribution Shift
### Calibration, Discrimination, and Decision Thresholds with a Loan-Default Application

Author: Silas Bambil

This repository accompanies the frozen project manuscript and includes a research poster.

## What is included

- `manuscript/paper.Rmd` — frozen executable manuscript source.
- `manuscript/paper.pdf` — frozen manuscript PDF.
- `poster/Silas_Bambil_Research_Poster.pdf` — research poster (October 5, 2026).
- `scripts/01_render_empirical_paper.R` — renders the empirical paper from the source data.
- `scripts/02_run_simulations.R` — full reconstructed Monte Carlo engine.
- `scripts/03_verify_against_frozen.R` — checks rerun simulation summaries against the frozen manuscript results.
- `results/frozen/` — numerical simulation summaries reported in the manuscript.
- `results/rerun/` — destination for fresh simulation outputs.
- `data/` — data instructions and checksum. Row-level datasets are not included.
- `environment/package_versions.R` — records the local R/package environment.
- `VERIFICATION_STATUS.md` — provenance and current verification status.

## Reproduction order

From the package root:

```r
source("environment/package_versions.R")
```

Place `Loan_default.csv` in `data/` and verify its SHA-256 checksum against `data/DATA_MANIFEST.json`.

The empirical renderer also requires `data/New_Loan_Validation_Data.csv`, a separately supplied synthetic stress-test file. It is not included in this public repository.

Then run:

```bash
Rscript scripts/01_render_empirical_paper.R
Rscript scripts/02_run_simulations.R
Rscript scripts/03_verify_against_frozen.R
```

The Monte Carlo script uses:

- seed = 1998
- R = 500 replications per condition
- n = 5,000 for training/evaluation samples unless otherwise stated
- covariate-shift delta = 0, 0.5, 1, 1.5, 2
- misspecification beta4 = 0, 0.25, 0.50
- intercept-shift gamma = 0, 0.25, 0.50, 0.75, 1
- slope-shift kappa = 0, 0.4, 0.8, 1.2, 1.6
- threshold grid = 0.01 to 0.50 by 0.005

## Important provenance note

The empirical RMarkdown is the frozen project source.

The standalone Monte Carlo script is a **reconstruction** from the frozen manuscript and numerical
outputs because the original interactive simulation source was not preserved as a separate file.
For that reason, the package distinguishes:

1. frozen reported results;
2. reconstructed simulation code; and
3. execution verification.

Do not describe the reconstructed script as bit-for-bit original code. Once the verification script
passes in R, it is appropriate to say that the reconstructed simulation implementation reproduces
the frozen findings within Monte Carlo tolerance.

## Main data fingerprint

`Loan_default.csv`

SHA-256: `1d7556a9071e7f9e872dc05a0cad174229fb1164b1cf3470ad35eed195c24278`

## Citation and archive

Author: Silas Bambil. See `CITATION.cff` for citation metadata.

This repository is being prepared for archival through Zenodo. No DOI has been assigned or verified yet.
The repository uses the existing MIT license.
