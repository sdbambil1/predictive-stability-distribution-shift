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
- `manuscript/supplementary_material.pdf` and `.Rmd` - supplied publication supplement.
- `manuscript/references_publication_v5.bib` - bibliography required by the source.
- `manuscript/data/` - bundled summary data and recorded environments from the revision package; no individual loan records.
- `manuscript/verification/` - supplied checks and sensitivity notes.
- `scripts/05_render_publication.R` and `scripts/07_render_supplement.R` - render the publication and supplement.
- `scripts/06_adaptation_after_shift.R` - recovered original 500-replication adaptation script.
- `verification/MANUSCRIPT_FILE_AUDIT.md` - manuscript-to-file checks, corrections, and remaining gaps.
- `analysis/empirical_pipeline.Rmd` - earlier empirical analysis pipeline retained as supporting code, not the publication manuscript.
- `scripts/01_render_empirical_paper.R` - rerun the supporting empirical pipeline with separately obtained row-level inputs.
- `scripts/02_run_simulations.R` and `scripts/03_verify_against_frozen.R` - reconstructed initial simulation engine and original frozen-reference verifier; these do not rerun every later adaptation experiment.
- `results/frozen/` - historical initial simulation reference summaries.
- `results/empirical/` - earlier empirical outputs; see its provenance README.
- `figures/` - exact extracts of publication Figures 1-3.
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

## File consistency audit

See [the audit report](verification/MANUSCRIPT_FILE_AUDIT.md). The principal empirical and adaptation values match the publication manuscript. The deposit remains partial: full supporting scripts/raw records and an actual renv lockfile are not all present. The manuscript availability text also predates this upload and needs updating before final archival.
