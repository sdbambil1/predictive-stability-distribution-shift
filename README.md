# Predictive Stability and Adaptation Under Distribution Shift

**Calibration, Discrimination, and Decision Thresholds in Credit-Risk Modeling**

Author: Silas Bambil

## Publication manuscript

[Read the publication manuscript](manuscript/paper.pdf)

The main PDF is the 17-page publication manuscript supplied on October 5, 2026 (`paper_publication_FINAL_VERIFIED(20261005-151516).pdf`). Its supplied R Markdown source is `paper_publication_FINAL_VERIFIED(4).Rmd`, stored here as `manuscript/paper.Rmd`. These replace the earlier 36-page project manuscript previously uploaded to these paths. The repository does not assert journal acceptance or publication.

The paper combines a loan-default baseline with controlled distribution-shift experiments and compares recalibration, refitting, and threshold revision. It separates probability accuracy, calibration, discrimination, and classification decisions.

## Files

- `manuscript/paper.pdf` - publication manuscript.
- `manuscript/paper.Rmd` - supplied publication source.
- `manuscript/references_publication_v5.bib` - bibliography required by the source.
- `manuscript/data/` - bundled summary data and recorded environments from the revision package; no individual loan records.
- `manuscript/verification/` - supplied checks and sensitivity notes.
- `scripts/05_render_publication.R` - render the publication source from its bundled summary data.
- `analysis/empirical_pipeline.Rmd` - earlier empirical analysis pipeline retained as supporting code, not the publication manuscript.
- `scripts/01_render_empirical_paper.R` - rerun the supporting empirical pipeline with separately obtained row-level inputs.
- `scripts/02_run_simulations.R` and `scripts/03_verify_against_frozen.R` - reconstructed initial simulation engine and original frozen-reference verifier; these do not rerun every later adaptation experiment.
- `results/frozen/` - historical initial simulation reference summaries.
- `results/empirical/` - earlier empirical outputs; see its provenance README.
- `figures/` - extracts from the earlier project PDF, retained as supporting empirical figures; publication figures are generated within the publication source.
- `data/` - original input instructions, checksum, and data dictionary.
- `environment/` - supplied session record and instructions for capturing an actual `renv.lock`.
- `CITATION.cff` and `.zenodo.json` - citation and archive metadata.

The poster is excluded.

## Render the publication manuscript

With R, ggplot2, knitr, rmarkdown, Pandoc and XeLaTeX available, run from the repository root:

```sh
Rscript scripts/05_render_publication.R
```

The supplied summary CSVs and bibliography must remain beside the manuscript source in the directory structure shown above. The pre-rendered PDF is included. No R execution or fresh PDF knitting was performed during this upload.

## Reproducibility status

Distinguish supplied manuscript results, retained summaries, reconstructed initial simulation code, and later adaptation evidence. See the manuscript's reproducibility section, `manuscript/verification/`, and `VERIFICATION_STATUS.md`. The archive includes the matching summary inputs needed to render the publication source; it does not claim that all simulation scripts or original model-development inputs are present.

The main empirical CSV and row-level validation file are not redistributed. An original `renv.lock` was not located; the session listing is supplied, with a script to capture a lockfile in the original R environment.

## Citation and archive

See `CITATION.cff`. The existing repository license is MIT. Zenodo archival and DOI assignment remain pending; no verified DOI is available yet.
