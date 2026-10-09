# Compare reconstructed simulation rerun with frozen manuscript summaries.
#
# Because the original standalone Monte Carlo source was not preserved, this
# verification is statistical rather than bit-for-bit. A rerun passes when
# differences are small relative to the frozen Monte Carlo uncertainty or to
# a conservative absolute tolerance where frozen MCSE is unavailable.

read_frozen <- function(name) read.csv(file.path("results","frozen",name), check.names = FALSE)
read_rerun  <- function(name) read.csv(file.path("results","rerun",name), check.names = FALSE)

fail <- FALSE

check_table <- function(label, frozen, rerun, keys, mappings, abs_tol = 0.005, mcse_multiplier = 4) {
  m <- merge(frozen, rerun, by = keys, suffixes = c("_frozen","_rerun"))
  cat("\n---", label, "---\n")
  for (item in mappings) {
    fcol <- item$frozen
    rcol <- item$rerun
    mcse_col <- item$mcse
    fv <- m[[paste0(fcol,"_frozen")]]
    rv <- m[[paste0(rcol,"_rerun")]]
    d <- abs(rv - fv)

    if (!is.null(mcse_col) && paste0(mcse_col,"_frozen") %in% names(m)) {
      tol <- pmax(abs_tol, mcse_multiplier * m[[paste0(mcse_col,"_frozen")]])
    } else {
      tol <- rep(abs_tol, length(d))
    }

    ok <- d <= tol
    cat(sprintf("%-28s max |diff| = %.6g ; allowed max = %.6g ; %s\n",
                fcol, max(d, na.rm=TRUE), max(tol, na.rm=TRUE),
                if (all(ok, na.rm=TRUE)) "PASS" else "CHECK"))
    if (!all(ok, na.rm=TRUE)) fail <<- TRUE
  }
}

# Coefficient recovery
if (file.exists("results/rerun/coefficient_recovery.csv")) {
  f <- read_frozen("coefficient_recovery.csv")
  r <- read_rerun("coefficient_recovery.csv")
  check_table("Coefficient recovery", f, r, "parameter",
              list(list(frozen="mean_estimate",rerun="mean_estimate",mcse=NULL)),
              abs_tol=0.02)
}

# Threshold stability
f <- read_frozen("threshold_stability.csv")
r <- read_rerun("threshold_stability.csv")
check_table("Threshold stability", f, r, c("beta4","delta"),
  list(
    list(frozen="threshold_change",rerun="threshold_change",mcse="mcse_threshold_change"),
    list(frozen="BA_gain",rerun="BA_gain",mcse="mcse_BA_gain"),
    list(frozen="frozen_BA",rerun="frozen_BA",mcse=NULL),
    list(frozen="adapted_BA",rerun="adapted_BA",mcse=NULL)
  ), abs_tol=0.01)

# Intercept shift
f <- read_frozen("intercept_outcome_shift.csv")
r <- read_rerun("intercept_outcome_shift.csv")
check_table("Intercept outcome shift", f, r, "gamma",
  list(
    list(frozen="event_rate",rerun="event_rate",mcse=NULL),
    list(frozen="model_auc",rerun="model_auc",mcse=NULL),
    list(frozen="mean_cal_intercept",rerun="mean_cal_intercept",mcse="mcse_cal_intercept"),
    list(frozen="mean_cal_slope",rerun="mean_cal_slope",mcse="mcse_cal_slope"),
    list(frozen="mean_prob_mse",rerun="mean_prob_mse",mcse="mcse_prob_mse"),
    list(frozen="mean_excess_log_loss",rerun="mean_excess_log_loss",mcse="mcse_excess_log_loss")
  ), abs_tol=0.006)

# Slope shift
f <- read_frozen("slope_outcome_shift.csv")
r <- read_rerun("slope_outcome_shift.csv")
check_table("Slope outcome shift", f, r, "kappa",
  list(
    list(frozen="event_rate",rerun="event_rate",mcse=NULL),
    list(frozen="model_auc",rerun="model_auc",mcse="mcse_model_auc"),
    list(frozen="auc_gap",rerun="auc_gap",mcse="mcse_auc_gap"),
    list(frozen="cal_intercept",rerun="cal_intercept",mcse="mcse_cal_intercept"),
    list(frozen="cal_slope",rerun="cal_slope",mcse="mcse_cal_slope"),
    list(frozen="prob_mse",rerun="prob_mse",mcse="mcse_prob_mse"),
    list(frozen="excess_log_loss",rerun="excess_log_loss",mcse="mcse_excess_log_loss")
  ), abs_tol=0.006)

cat("\n")
if (fail) {
  cat("VERIFICATION STATUS: CHECK REQUIRED\n")
  cat("At least one reconstructed result differs more than the declared tolerance.\n")
  quit(status = 1)
} else {
  cat("VERIFICATION STATUS: PASS\n")
  cat("Reconstructed simulations agree with frozen manuscript summaries within the declared Monte Carlo tolerances.\n")
}
