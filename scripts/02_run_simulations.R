# Reconstructed Monte Carlo simulation engine
# Paper: Predictive Stability Under Distribution Shift
#
# IMPORTANT PROVENANCE NOTE:
# The original interactive Monte Carlo source was not preserved as a standalone
# script. This file reconstructs the simulation from the frozen manuscript's
# documented DGP, sample sizes, grids, seed, and reported estimands.
# It is intended to reproduce the paper's results within Monte Carlo tolerance,
# not to claim bit-for-bit identity with the lost original source.

set.seed(1998)

R <- 500L
n_train <- 5000L
n_eval <- 5000L

beta <- c(x1 = 0.8, x2 = -0.6, x3 = 0.4)
beta0_linear <- -2.3871388

# Intercepts calibrated to approximately 12% prevalence at delta = 0.
# These constants are deterministic design values, not empirical estimates.
beta0_by_beta4 <- c(`0` = -2.3871388, `0.25` = -2.6828861, `0.5` = -3.0140474)

clip_prob <- function(p, eps = 1e-12) pmin(pmax(p, eps), 1 - eps)
inv_logit <- function(x) plogis(x)

log_loss <- function(y, p) {
  p <- clip_prob(p)
  -mean(y * log(p) + (1 - y) * log(1 - p))
}

brier <- function(y, p) mean((y - p)^2)

auc_rank <- function(y, score) {
  y <- as.integer(y)
  n1 <- sum(y == 1L)
  n0 <- sum(y == 0L)
  if (n1 == 0L || n0 == 0L) return(NA_real_)
  r <- rank(score, ties.method = "average")
  (sum(r[y == 1L]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

calibration_stats <- function(y, p) {
  lp <- qlogis(clip_prob(p, 1e-8))
  fit <- suppressWarnings(glm(y ~ lp, family = binomial()))
  c(intercept = unname(coef(fit)[1]), slope = unname(coef(fit)[2]))
}

balanced_accuracy <- function(y, p, threshold) {
  pred <- as.integer(p >= threshold)
  tp <- sum(pred == 1L & y == 1L)
  fn <- sum(pred == 0L & y == 1L)
  tn <- sum(pred == 0L & y == 0L)
  fp <- sum(pred == 1L & y == 0L)
  sens <- if ((tp + fn) > 0) tp / (tp + fn) else NA_real_
  spec <- if ((tn + fp) > 0) tn / (tn + fp) else NA_real_
  (sens + spec) / 2
}

best_threshold <- function(y, p, grid = seq(0.01, 0.50, by = 0.005)) {
  ba <- vapply(grid, function(t) balanced_accuracy(y, p, t), numeric(1))
  # deterministic tie handling: choose the smallest threshold among maxima
  grid[which.max(ba)]
}

generate_xyz <- function(n, delta = 0) {
  data.frame(
    x1 = rnorm(n, mean = delta, sd = 1),
    x2 = rnorm(n),
    x3 = rnorm(n)
  )
}

true_probability <- function(x, beta0, beta4 = 0, beta1 = 0.8) {
  inv_logit(beta0 + beta1*x$x1 - 0.6*x$x2 + 0.4*x$x3 + beta4*x$x1^2)
}

fit_working_logistic <- function(x, y) {
  glm(y ~ x1 + x2 + x3, data = cbind(x, y = y), family = binomial())
}

predict_prob <- function(fit, x) as.numeric(predict(fit, newdata = x, type = "response"))

mcse <- function(x) sd(x, na.rm = TRUE) / sqrt(sum(is.finite(x)))

summarise_mean <- function(df, group_cols, value_cols) {
  split_key <- interaction(df[group_cols], drop = TRUE, lex.order = TRUE)
  groups <- split(df, split_key)
  out <- lapply(groups, function(g) {
    keys <- g[1, group_cols, drop = FALSE]
    vals <- as.data.frame(lapply(g[value_cols], mean, na.rm = TRUE))
    cbind(keys, vals)
  })
  do.call(rbind, out)
}

# -------------------------------------------------------------------
# 0. Coefficient-recovery sanity check
# -------------------------------------------------------------------
coef_rows <- vector("list", R)
for (r in seq_len(R)) {
  x <- generate_xyz(n_train)
  p <- true_probability(x, beta0_linear, beta4 = 0)
  y <- rbinom(n_train, 1, p)
  fit <- fit_working_logistic(x, y)
  b <- coef(fit)
  coef_rows[[r]] <- data.frame(
    rep = r,
    intercept = b[1],
    x1 = b[2],
    x2 = b[3],
    x3 = b[4]
  )
}
coef_raw <- do.call(rbind, coef_rows)
coef_recovery <- data.frame(
  parameter = c("Intercept","X1","X2","X3"),
  true_value = c(beta0_linear,0.8,-0.6,0.4),
  mean_estimate = c(mean(coef_raw$intercept),mean(coef_raw$x1),
                    mean(coef_raw$x2),mean(coef_raw$x3))
)
coef_recovery$bias <- coef_recovery$mean_estimate - coef_recovery$true_value
write.csv(coef_recovery, "results/rerun/coefficient_recovery.csv", row.names = FALSE)

# -------------------------------------------------------------------
# 1. Covariate shift x misspecification
# -------------------------------------------------------------------
beta4_grid <- c(0, 0.25, 0.50)
delta_grid <- c(0, 0.5, 1, 1.5, 2)

cov_rows <- vector("list", R * length(beta4_grid) * length(delta_grid))
k <- 1L

for (b4 in beta4_grid) {
  b0 <- unname(beta0_by_beta4[as.character(b4)])
  for (r in seq_len(R)) {
    xtr <- generate_xyz(n_train, delta = 0)
    ptr <- true_probability(xtr, b0, beta4 = b4)
    ytr <- rbinom(n_train, 1, ptr)
    fit <- fit_working_logistic(xtr, ytr)

    for (delta in delta_grid) {
      xte <- generate_xyz(n_eval, delta = delta)
      ptrue <- true_probability(xte, b0, beta4 = b4)
      yte <- rbinom(n_eval, 1, ptrue)
      phat <- predict_prob(fit, xte)
      cal <- calibration_stats(yte, phat)

      cov_rows[[k]] <- data.frame(
        beta4 = b4, delta = delta, rep = r,
        event_rate = mean(yte),
        model_log_loss = log_loss(yte, phat),
        oracle_log_loss = log_loss(yte, ptrue),
        excess_log_loss = log_loss(yte, phat) - log_loss(yte, ptrue),
        model_brier = brier(yte, phat),
        oracle_brier = brier(yte, ptrue),
        excess_brier = brier(yte, phat) - brier(yte, ptrue),
        probability_mse = mean((phat - ptrue)^2),
        model_auc = auc_rank(yte, phat),
        oracle_auc = auc_rank(yte, ptrue),
        auc_gap = auc_rank(yte, ptrue) - auc_rank(yte, phat),
        cal_intercept = cal["intercept"],
        cal_slope = cal["slope"]
      )
      k <- k + 1L
    }
  }
}
cov_raw <- do.call(rbind, cov_rows)
write.csv(cov_raw, "results/rerun/covariate_shift_raw.csv", row.names = FALSE)

cov_summary <- aggregate(
  cbind(event_rate, model_log_loss, oracle_log_loss, excess_log_loss,
        model_brier, oracle_brier, excess_brier, probability_mse,
        model_auc, oracle_auc, auc_gap, cal_intercept, cal_slope) ~ beta4 + delta,
  data = cov_raw, FUN = mean
)
write.csv(cov_summary, "results/rerun/covariate_shift_summary.csv", row.names = FALSE)

# -------------------------------------------------------------------
# 1b. Decision-threshold stability under covariate shift
# -------------------------------------------------------------------
threshold_rows <- vector("list", R * length(beta4_grid) * length(delta_grid))
k <- 1L

for (b4 in beta4_grid) {
  b0 <- unname(beta0_by_beta4[as.character(b4)])
  for (r in seq_len(R)) {
    xtr <- generate_xyz(n_train, 0)
    ptr <- true_probability(xtr, b0, beta4 = b4)
    ytr <- rbinom(n_train, 1, ptr)
    fit <- fit_working_logistic(xtr, ytr)

    xval <- generate_xyz(n_eval, 0)
    pval_true <- true_probability(xval, b0, beta4 = b4)
    yval <- rbinom(n_eval, 1, pval_true)
    pval <- predict_prob(fit, xval)
    baseline_t <- best_threshold(yval, pval)

    for (delta in delta_grid) {
      # Independent adaptation sample
      xadapt <- generate_xyz(n_eval, delta)
      padapt_true <- true_probability(xadapt, b0, beta4 = b4)
      yadapt <- rbinom(n_eval, 1, padapt_true)
      padapt <- predict_prob(fit, xadapt)
      shifted_t <- best_threshold(yadapt, padapt)

      # Independent evaluation sample
      xte <- generate_xyz(n_eval, delta)
      pte_true <- true_probability(xte, b0, beta4 = b4)
      yte <- rbinom(n_eval, 1, pte_true)
      pte <- predict_prob(fit, xte)

      frozen_ba <- balanced_accuracy(yte, pte, baseline_t)
      adapted_ba <- balanced_accuracy(yte, pte, shifted_t)

      threshold_rows[[k]] <- data.frame(
        beta4 = b4, delta = delta, rep = r,
        baseline_threshold = baseline_t,
        shifted_threshold = shifted_t,
        threshold_change = shifted_t - baseline_t,
        abs_change = abs(shifted_t - baseline_t),
        frozen_BA = frozen_ba,
        adapted_BA = adapted_ba,
        BA_gain = adapted_ba - frozen_ba
      )
      k <- k + 1L
    }
  }
}
threshold_raw <- do.call(rbind, threshold_rows)
write.csv(threshold_raw, "results/rerun/threshold_stability_raw.csv", row.names = FALSE)

threshold_summary <- do.call(rbind, lapply(
  split(threshold_raw, interaction(threshold_raw$beta4, threshold_raw$delta, drop=TRUE)),
  function(g) data.frame(
    beta4 = g$beta4[1], delta = g$delta[1],
    baseline_threshold = mean(g$baseline_threshold),
    shifted_threshold = mean(g$shifted_threshold),
    threshold_change = mean(g$threshold_change),
    abs_change = mean(g$abs_change),
    frozen_BA = mean(g$frozen_BA),
    adapted_BA = mean(g$adapted_BA),
    BA_gain = mean(g$BA_gain),
    sd_threshold_change = sd(g$threshold_change),
    mcse_threshold_change = mcse(g$threshold_change),
    sd_BA_gain = sd(g$BA_gain),
    mcse_BA_gain = mcse(g$BA_gain)
  )
))
write.csv(threshold_summary, "results/rerun/threshold_stability.csv", row.names = FALSE)

# -------------------------------------------------------------------
# 2. Intercept outcome shift
# -------------------------------------------------------------------
gamma_grid <- c(0, .25, .50, .75, 1)
intercept_rows <- vector("list", R * length(gamma_grid))
k <- 1L

for (r in seq_len(R)) {
  xtr <- generate_xyz(n_train)
  ptr <- true_probability(xtr, beta0_linear, beta4 = 0)
  ytr <- rbinom(n_train, 1, ptr)
  fit <- fit_working_logistic(xtr, ytr)

  for (gamma in gamma_grid) {
    xte <- generate_xyz(n_eval)
    ptrue <- inv_logit(beta0_linear + gamma + .8*xte$x1 - .6*xte$x2 + .4*xte$x3)
    yte <- rbinom(n_eval, 1, ptrue)
    phat <- predict_prob(fit, xte)
    cal <- calibration_stats(yte, phat)

    intercept_rows[[k]] <- data.frame(
      gamma = gamma, rep = r, event_rate = mean(yte),
      model_auc = auc_rank(yte, phat),
      oracle_auc = auc_rank(yte, ptrue),
      auc_gap = auc_rank(yte, ptrue) - auc_rank(yte, phat),
      cal_intercept = cal["intercept"],
      cal_slope = cal["slope"],
      prob_mse = mean((phat - ptrue)^2),
      excess_log_loss = log_loss(yte, phat) - log_loss(yte, ptrue),
      excess_brier = brier(yte, phat) - brier(yte, ptrue)
    )
    k <- k + 1L
  }
}
intercept_raw <- do.call(rbind, intercept_rows)
write.csv(intercept_raw, "results/rerun/intercept_outcome_shift_raw.csv", row.names = FALSE)

intercept_summary <- do.call(rbind, lapply(split(intercept_raw, intercept_raw$gamma), function(g) {
  data.frame(
    gamma = g$gamma[1], R = nrow(g), event_rate = mean(g$event_rate),
    model_auc = mean(g$model_auc), oracle_auc = mean(g$oracle_auc),
    auc_gap = mean(g$auc_gap),
    mean_cal_intercept = mean(g$cal_intercept),
    sd_cal_intercept = sd(g$cal_intercept),
    mcse_cal_intercept = mcse(g$cal_intercept),
    mean_cal_slope = mean(g$cal_slope),
    sd_cal_slope = sd(g$cal_slope),
    mcse_cal_slope = mcse(g$cal_slope),
    mean_prob_mse = mean(g$prob_mse),
    mcse_prob_mse = mcse(g$prob_mse),
    mean_excess_log_loss = mean(g$excess_log_loss),
    mcse_excess_log_loss = mcse(g$excess_log_loss),
    mean_excess_brier = mean(g$excess_brier),
    mcse_excess_brier = mcse(g$excess_brier)
  )
}))
write.csv(intercept_summary, "results/rerun/intercept_outcome_shift.csv", row.names = FALSE)

# -------------------------------------------------------------------
# 3. Slope outcome shift
# -------------------------------------------------------------------
kappa_grid <- c(0, .4, .8, 1.2, 1.6)

# For a linear logistic model with X~N(0,I), choose intercept by numerical
# integration so deployment prevalence remains approximately 12%.
calibrate_linear_intercept <- function(beta1, target = 0.12) {
  sigma <- sqrt(beta1^2 + 0.6^2 + 0.4^2)
  f <- function(b0) {
    integrate(function(z) plogis(b0 + sigma*z) * dnorm(z),
              lower = -8, upper = 8, rel.tol = 1e-10)$value - target
  }
  uniroot(f, c(-8, 2), tol = 1e-10)$root
}

slope_rows <- vector("list", R * length(kappa_grid))
k <- 1L

for (r in seq_len(R)) {
  xtr <- generate_xyz(n_train)
  ptr <- true_probability(xtr, beta0_linear, beta4 = 0)
  ytr <- rbinom(n_train, 1, ptr)
  fit <- fit_working_logistic(xtr, ytr)

  for (kap in kappa_grid) {
    b1_deploy <- 0.8 - kap
    b0_deploy <- calibrate_linear_intercept(b1_deploy)

    xte <- generate_xyz(n_eval)
    ptrue <- inv_logit(b0_deploy + b1_deploy*xte$x1 - .6*xte$x2 + .4*xte$x3)
    yte <- rbinom(n_eval, 1, ptrue)
    phat <- predict_prob(fit, xte)
    cal <- calibration_stats(yte, phat)

    slope_rows[[k]] <- data.frame(
      kappa = kap, beta1_deploy = b1_deploy, rep = r,
      event_rate = mean(yte),
      model_auc = auc_rank(yte, phat),
      oracle_auc = auc_rank(yte, ptrue),
      auc_gap = auc_rank(yte, ptrue) - auc_rank(yte, phat),
      cal_intercept = cal["intercept"],
      cal_slope = cal["slope"],
      prob_mse = mean((phat - ptrue)^2),
      excess_log_loss = log_loss(yte, phat) - log_loss(yte, ptrue),
      excess_brier = brier(yte, phat) - brier(yte, ptrue)
    )
    k <- k + 1L
  }
}
slope_raw <- do.call(rbind, slope_rows)
write.csv(slope_raw, "results/rerun/slope_outcome_shift_raw.csv", row.names = FALSE)

slope_summary <- do.call(rbind, lapply(split(slope_raw, slope_raw$kappa), function(g) {
  data.frame(
    kappa = g$kappa[1], beta1_deploy = g$beta1_deploy[1], R = nrow(g),
    event_rate = mean(g$event_rate),
    model_auc = mean(g$model_auc),
    sd_model_auc = sd(g$model_auc),
    mcse_model_auc = mcse(g$model_auc),
    oracle_auc = mean(g$oracle_auc),
    auc_gap = mean(g$auc_gap),
    sd_auc_gap = sd(g$auc_gap),
    mcse_auc_gap = mcse(g$auc_gap),
    cal_intercept = mean(g$cal_intercept),
    mcse_cal_intercept = mcse(g$cal_intercept),
    cal_slope = mean(g$cal_slope),
    mcse_cal_slope = mcse(g$cal_slope),
    prob_mse = mean(g$prob_mse),
    mcse_prob_mse = mcse(g$prob_mse),
    excess_log_loss = mean(g$excess_log_loss),
    mcse_excess_log_loss = mcse(g$excess_log_loss),
    excess_brier = mean(g$excess_brier),
    mcse_excess_brier = mcse(g$excess_brier)
  )
}))
write.csv(slope_summary, "results/rerun/slope_outcome_shift.csv", row.names = FALSE)

cat("\nSimulation rerun complete. Outputs written to results/rerun/.\n")
cat("Now run: Rscript scripts/03_verify_against_frozen.R\n")
