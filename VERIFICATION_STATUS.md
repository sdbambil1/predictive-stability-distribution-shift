# Verification Status

## Frozen manuscript
**Status: frozen.** The project manuscript PDF and RMarkdown source are included under `manuscript/`.

## Empirical analysis
The manuscript contains the empirical analysis code used for the paper. Re-running it requires the
original `Loan_default.csv` file with the checksum recorded in `data/DATA_MANIFEST.json`.

## Monte Carlo simulations
**Status: reconstructed, awaiting execution verification in R.**

The original standalone Monte Carlo script was not preserved. `scripts/02_run_simulations.R`
reconstructs the experiments from the paper's documented:

- data-generating mechanisms,
- sample sizes,
- shift grids,
- threshold grid,
- 500-replication design,
- seed 1998,
- estimands and performance metrics.

The frozen manuscript summaries are stored in `results/frozen/`.

After running the reconstructed simulations, execute:

`Rscript scripts/03_verify_against_frozen.R`

The verifier compares rerun summaries with the frozen results using Monte Carlo-error-aware tolerances.

This package deliberately does **not** claim bit-for-bit reproduction until that verification has been run.
