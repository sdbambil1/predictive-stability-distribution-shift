# ============================================================
# PUBLICATION EXTENSION:
# Adaptation After Distribution Shift
#
# Research question:
# Once distribution shift occurs, which corrective action
# repairs probability estimation, calibration, ranking,
# and/or the operating threshold?
#
# Existing frozen manuscript is NOT modified.
# ============================================================

set.seed(1998)

# ------------------------------------------------------------
# 1. DESIGN
# ------------------------------------------------------------

R <- 500
n_train <- 5000
n_adapt <- 5000
n_test  <- 5000
n_val   <- 5000

threshold_grid <- seq(0.01, 0.50, by = 0.005)

beta <- c(0.8, -0.6, 0.4)

# Baseline intercept used in the established reconstruction
beta0 <- -2.3871388

# Strong misspecification condition for the covariate-shift
# adaptation experiment
beta4_cov <- 0.50
beta0_cov <- -3.0140474

delta_grid <- c(0, 0.5, 1, 1.5, 2)
gamma_grid <- c(0, 0.25, 0.50, 0.75, 1)
kappa_grid <- c(0, 0.4, 0.8, 1.2, 1.6)

out_dir <- "results/publication_extension"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

eps <- 1e-12


# ------------------------------------------------------------
# 2. BASIC FUNCTIONS
# ------------------------------------------------------------

clip_prob <- function(p) {
  pmin(pmax(p, eps), 1 - eps)
}

logit <- function(p) {
  p <- clip_prob(p)
  log(p / (1 - p))
}

log_loss <- function(y, p) {
  p <- clip_prob(p)
  -mean(y * log(p) + (1 - y) * log(1 - p))
}

brier <- function(y, p) {
  mean((y - p)^2)
}

auc_rank <- function(y, p) {
  
  n1 <- sum(y == 1)
  n0 <- sum(y == 0)
  
  if (n1 == 0 || n0 == 0)
    return(NA_real_)
  
  r <- rank(p, ties.method = "average")
  
  (sum(r[y == 1]) - n1 * (n1 + 1) / 2) /
    (n1 * n0)
}

balanced_accuracy <- function(y, p, threshold) {
  
  pred <- as.integer(p >= threshold)
  
  tp <- sum(pred == 1 & y == 1)
  fn <- sum(pred == 0 & y == 1)
  
  tn <- sum(pred == 0 & y == 0)
  fp <- sum(pred == 1 & y == 0)
  
  sensitivity <- if ((tp + fn) == 0) NA_real_ else tp / (tp + fn)
  specificity <- if ((tn + fp) == 0) NA_real_ else tn / (tn + fp)
  
  mean(c(sensitivity, specificity), na.rm = TRUE)
}

optimal_threshold <- function(y, p) {
  
  ba <- vapply(
    threshold_grid,
    function(t)
      balanced_accuracy(y, p, t),
    numeric(1)
  )
  
  threshold_grid[which.max(ba)]
}


# ------------------------------------------------------------
# 3. FAST LOGISTIC FITTING
# ------------------------------------------------------------

fit_logistic <- function(X, y, weights = NULL) {
  
  Xmat <- cbind(1, as.matrix(X))
  
  if (is.null(weights))
    weights <- rep(1, length(y))
  
  fit <- suppressWarnings(
    glm.fit(
      x = Xmat,
      y = y,
      weights = weights,
      family = binomial()
    )
  )
  
  list(
    coefficients = fit$coefficients
  )
}

predict_logistic <- function(fit, X) {
  
  Xmat <- cbind(1, as.matrix(X))
  
  eta <- drop(Xmat %*% fit$coefficients)
  
  plogis(eta)
}


# ------------------------------------------------------------
# 4. RECALIBRATION METHODS
# ------------------------------------------------------------

intercept_recalibration <- function(y, p) {
  
  lp <- logit(p)
  
  fit <- suppressWarnings(
    glm(
      y ~ 1 + offset(lp),
      family = binomial()
    )
  )
  
  as.numeric(coef(fit)[1])
}

predict_intercept_recal <- function(p, a) {
  plogis(a + logit(p))
}


logistic_recalibration <- function(y, p) {
  
  lp <- logit(p)
  
  fit <- suppressWarnings(
    glm(
      y ~ lp,
      family = binomial()
    )
  )
  
  c(
    intercept = as.numeric(coef(fit)[1]),
    slope = as.numeric(coef(fit)[2])
  )
}

predict_logistic_recal <- function(p, pars) {
  
  plogis(
    pars["intercept"] +
      pars["slope"] * logit(p)
  )
}


# ------------------------------------------------------------
# 5. CALIBRATION DIAGNOSTIC
# ------------------------------------------------------------

calibration_stats <- function(y, p) {
  
  lp <- logit(p)
  
  fit <- suppressWarnings(
    glm(
      y ~ lp,
      family = binomial()
    )
  )
  
  c(
    cal_intercept = as.numeric(coef(fit)[1]),
    cal_slope = as.numeric(coef(fit)[2])
  )
}


# ------------------------------------------------------------
# 6. METRIC COLLECTOR
# ------------------------------------------------------------

evaluate_probabilities <- function(y, p) {
  
  cal <- calibration_stats(y, p)
  
  data.frame(
    log_loss = log_loss(y, p),
    brier = brier(y, p),
    auc = auc_rank(y, p),
    cal_intercept = cal["cal_intercept"],
    cal_slope = cal["cal_slope"]
  )
}


# ------------------------------------------------------------
# 7. DATA GENERATORS
# ------------------------------------------------------------

generate_baseline <- function(n) {
  
  X <- data.frame(
    X1 = rnorm(n),
    X2 = rnorm(n),
    X3 = rnorm(n)
  )
  
  eta <- beta0 +
    beta[1] * X$X1 +
    beta[2] * X$X2 +
    beta[3] * X$X3
  
  p <- plogis(eta)
  y <- rbinom(n, 1, p)
  
  list(X = X, y = y, p = p)
}


generate_covariate <- function(n, delta) {
  
  X <- data.frame(
    X1 = rnorm(n, mean = delta, sd = 1),
    X2 = rnorm(n),
    X3 = rnorm(n)
  )
  
  eta <- beta0_cov +
    beta[1] * X$X1 +
    beta[2] * X$X2 +
    beta[3] * X$X3 +
    beta4_cov * X$X1^2
  
  p <- plogis(eta)
  y <- rbinom(n, 1, p)
  
  list(X = X, y = y, p = p)
}


generate_covariate_train <- function(n) {
  
  X <- data.frame(
    X1 = rnorm(n),
    X2 = rnorm(n),
    X3 = rnorm(n)
  )
  
  eta <- beta0_cov +
    beta[1] * X$X1 +
    beta[2] * X$X2 +
    beta[3] * X$X3 +
    beta4_cov * X$X1^2
  
  p <- plogis(eta)
  y <- rbinom(n, 1, p)
  
  list(X = X, y = y, p = p)
}


generate_intercept_shift <- function(n, gamma) {
  
  X <- data.frame(
    X1 = rnorm(n),
    X2 = rnorm(n),
    X3 = rnorm(n)
  )
  
  eta <- beta0 +
    gamma +
    beta[1] * X$X1 +
    beta[2] * X$X2 +
    beta[3] * X$X3
  
  p <- plogis(eta)
  y <- rbinom(n, 1, p)
  
  list(X = X, y = y, p = p)
}


# ------------------------------------------------------------
# 8. SLOPE-SHIFT INTERCEPT CALIBRATION
#    Keep deployment prevalence near 12%
# ------------------------------------------------------------

expected_prevalence <- function(intercept, beta1) {
  
  variance <-
    beta1^2 +
    beta[2]^2 +
    beta[3]^2
  
  f <- function(z) {
    
    plogis(
      intercept +
        sqrt(variance) * z
    ) * dnorm(z)
  }
  
  integrate(
    f,
    lower = -8,
    upper = 8,
    subdivisions = 200L
  )$value
}

slope_intercept <- function(beta1) {
  
  uniroot(
    function(a)
      expected_prevalence(a, beta1) - 0.12,
    interval = c(-8, 2)
  )$root
}

beta1_values <- beta[1] - kappa_grid

slope_intercepts <- vapply(
  beta1_values,
  slope_intercept,
  numeric(1)
)

names(slope_intercepts) <- as.character(kappa_grid)


generate_slope_shift <- function(n, kappa) {
  
  b1 <- beta[1] - kappa
  b0 <- slope_intercepts[as.character(kappa)]
  
  X <- data.frame(
    X1 = rnorm(n),
    X2 = rnorm(n),
    X3 = rnorm(n)
  )
  
  eta <- b0 +
    b1 * X$X1 +
    beta[2] * X$X2 +
    beta[3] * X$X3
  
  p <- plogis(eta)
  y <- rbinom(n, 1, p)
  
  list(X = X, y = y, p = p)
}


# ------------------------------------------------------------
# 9. STORAGE
# ------------------------------------------------------------

prob_results <- list()
threshold_results <- list()

prob_counter <- 1
threshold_counter <- 1


# ============================================================
# 10. EXPERIMENT A:
#     COVARIATE SHIFT + MISSPECIFICATION
#
# Compare:
#   - No adaptation
#   - Intercept recalibration
#   - Intercept + slope recalibration
#   - Importance-weighted refit
#   - Deployment refit
#
# Threshold experiment:
#   - Frozen baseline threshold
#   - Deployment-adapted threshold
# ============================================================

cat("\nStarting covariate-shift adaptation experiment...\n")

for (r in seq_len(R)) {
  
  train <- generate_covariate_train(n_train)
  val   <- generate_covariate_train(n_val)
  
  old_fit <- fit_logistic(train$X, train$y)
  
  p_val <- predict_logistic(old_fit, val$X)
  
  baseline_threshold <-
    optimal_threshold(val$y, p_val)
  
  for (delta in delta_grid) {
    
    adapt <- generate_covariate(n_adapt, delta)
    test  <- generate_covariate(n_test, delta)
    
    p_adapt_old <- predict_logistic(old_fit, adapt$X)
    p_test_old  <- predict_logistic(old_fit, test$X)
    
    # -----------------------------------
    # Intercept-only recalibration
    # -----------------------------------
    
    a_int <-
      intercept_recalibration(
        adapt$y,
        p_adapt_old
      )
    
    p_test_int <-
      predict_intercept_recal(
        p_test_old,
        a_int
      )
    
    # -----------------------------------
    # Intercept + slope recalibration
    # -----------------------------------
    
    recal_par <-
      logistic_recalibration(
        adapt$y,
        p_adapt_old
      )
    
    p_test_recal <-
      predict_logistic_recal(
        p_test_old,
        recal_par
      )
    
    # -----------------------------------
    # Importance weighting
    #
    # q(x1)/p(x1) for
    # N(delta,1) relative to N(0,1)
    # -----------------------------------
    
    iw <- exp(
      delta * train$X$X1 -
        0.5 * delta^2
    )
    
    # Stabilize extreme finite-sample weights
    cap <- quantile(iw, 0.99)
    
    iw <- pmin(iw, cap)
    iw <- iw / mean(iw)
    
    iw_fit <-
      fit_logistic(
        train$X,
        train$y,
        weights = iw
      )
    
    p_test_iw <-
      predict_logistic(
        iw_fit,
        test$X
      )
    
    # -----------------------------------
    # Full deployment refit
    # Same linear model class, but using
    # fresh labeled deployment observations
    # -----------------------------------
    
    deploy_fit <-
      fit_logistic(
        adapt$X,
        adapt$y
      )
    
    p_test_refit <-
      predict_logistic(
        deploy_fit,
        test$X
      )
    
    # -----------------------------------
    # Probability results
    # -----------------------------------
    
    method_predictions <- list(
      none = p_test_old,
      intercept_recal = p_test_int,
      intercept_slope_recal = p_test_recal,
      importance_weighted_refit = p_test_iw,
      deployment_refit = p_test_refit
    )
    
    for (method in names(method_predictions)) {
      
      met <-
        evaluate_probabilities(
          test$y,
          method_predictions[[method]]
        )
      
      prob_results[[prob_counter]] <-
        data.frame(
          replication = r,
          shift_type = "covariate_misspecified",
          shift_value = delta,
          method = method,
          event_rate = mean(test$y),
          met
        )
      
      prob_counter <- prob_counter + 1
    }
    
    # -----------------------------------
    # Threshold-only adaptation
    # -----------------------------------
    
    shifted_threshold <-
      optimal_threshold(
        adapt$y,
        p_adapt_old
      )
    
    frozen_BA <-
      balanced_accuracy(
        test$y,
        p_test_old,
        baseline_threshold
      )
    
    adapted_BA <-
      balanced_accuracy(
        test$y,
        p_test_old,
        shifted_threshold
      )
    
    threshold_results[[threshold_counter]] <-
      data.frame(
        replication = r,
        shift_type = "covariate_misspecified",
        shift_value = delta,
        baseline_threshold = baseline_threshold,
        adapted_threshold = shifted_threshold,
        threshold_change =
          shifted_threshold - baseline_threshold,
        frozen_BA = frozen_BA,
        adapted_BA = adapted_BA,
        BA_gain = adapted_BA - frozen_BA
      )
    
    threshold_counter <- threshold_counter + 1
  }
  
  if (r %% 25 == 0)
    cat("Covariate shift:", r, "of", R, "replications complete\n")
}


# ============================================================
# 11. EXPERIMENT B:
#     INTERCEPT OUTCOME SHIFT
# ============================================================

cat("\nStarting intercept-shift adaptation experiment...\n")

for (r in seq_len(R)) {
  
  train <- generate_baseline(n_train)
  val   <- generate_baseline(n_val)
  
  old_fit <- fit_logistic(train$X, train$y)
  
  p_val <- predict_logistic(old_fit, val$X)
  
  baseline_threshold <-
    optimal_threshold(val$y, p_val)
  
  for (gamma in gamma_grid) {
    
    adapt <-
      generate_intercept_shift(
        n_adapt,
        gamma
      )
    
    test <-
      generate_intercept_shift(
        n_test,
        gamma
      )
    
    p_adapt_old <-
      predict_logistic(
        old_fit,
        adapt$X
      )
    
    p_test_old <-
      predict_logistic(
        old_fit,
        test$X
      )
    
    # Intercept recalibration
    
    a_int <-
      intercept_recalibration(
        adapt$y,
        p_adapt_old
      )
    
    p_test_int <-
      predict_intercept_recal(
        p_test_old,
        a_int
      )
    
    # Intercept + slope recalibration
    
    recal_par <-
      logistic_recalibration(
        adapt$y,
        p_adapt_old
      )
    
    p_test_recal <-
      predict_logistic_recal(
        p_test_old,
        recal_par
      )
    
    # Full deployment refit
    
    deploy_fit <-
      fit_logistic(
        adapt$X,
        adapt$y
      )
    
    p_test_refit <-
      predict_logistic(
        deploy_fit,
        test$X
      )
    
    method_predictions <- list(
      none = p_test_old,
      intercept_recal = p_test_int,
      intercept_slope_recal = p_test_recal,
      deployment_refit = p_test_refit
    )
    
    for (method in names(method_predictions)) {
      
      met <-
        evaluate_probabilities(
          test$y,
          method_predictions[[method]]
        )
      
      prob_results[[prob_counter]] <-
        data.frame(
          replication = r,
          shift_type = "intercept_shift",
          shift_value = gamma,
          method = method,
          event_rate = mean(test$y),
          met
        )
      
      prob_counter <- prob_counter + 1
    }
    
    shifted_threshold <-
      optimal_threshold(
        adapt$y,
        p_adapt_old
      )
    
    frozen_BA <-
      balanced_accuracy(
        test$y,
        p_test_old,
        baseline_threshold
      )
    
    adapted_BA <-
      balanced_accuracy(
        test$y,
        p_test_old,
        shifted_threshold
      )
    
    threshold_results[[threshold_counter]] <-
      data.frame(
        replication = r,
        shift_type = "intercept_shift",
        shift_value = gamma,
        baseline_threshold = baseline_threshold,
        adapted_threshold = shifted_threshold,
        threshold_change =
          shifted_threshold - baseline_threshold,
        frozen_BA = frozen_BA,
        adapted_BA = adapted_BA,
        BA_gain = adapted_BA - frozen_BA
      )
    
    threshold_counter <- threshold_counter + 1
  }
  
  if (r %% 25 == 0)
    cat("Intercept shift:", r, "of", R, "replications complete\n")
}


# ============================================================
# 12. EXPERIMENT C:
#     SLOPE OUTCOME SHIFT
# ============================================================

cat("\nStarting slope-shift adaptation experiment...\n")

for (r in seq_len(R)) {
  
  train <- generate_baseline(n_train)
  val   <- generate_baseline(n_val)
  
  old_fit <- fit_logistic(train$X, train$y)
  
  p_val <- predict_logistic(old_fit, val$X)
  
  baseline_threshold <-
    optimal_threshold(val$y, p_val)
  
  for (kappa in kappa_grid) {
    
    adapt <-
      generate_slope_shift(
        n_adapt,
        kappa
      )
    
    test <-
      generate_slope_shift(
        n_test,
        kappa
      )
    
    p_adapt_old <-
      predict_logistic(
        old_fit,
        adapt$X
      )
    
    p_test_old <-
      predict_logistic(
        old_fit,
        test$X
      )
    
    # Intercept-only recalibration
    
    a_int <-
      intercept_recalibration(
        adapt$y,
        p_adapt_old
      )
    
    p_test_int <-
      predict_intercept_recal(
        p_test_old,
        a_int
      )
    
    # Intercept + slope recalibration
    
    recal_par <-
      logistic_recalibration(
        adapt$y,
        p_adapt_old
      )
    
    p_test_recal <-
      predict_logistic_recal(
        p_test_old,
        recal_par
      )
    
    # Full deployment refit
    
    deploy_fit <-
      fit_logistic(
        adapt$X,
        adapt$y
      )
    
    p_test_refit <-
      predict_logistic(
        deploy_fit,
        test$X
      )
    
    method_predictions <- list(
      none = p_test_old,
      intercept_recal = p_test_int,
      intercept_slope_recal = p_test_recal,
      deployment_refit = p_test_refit
    )
    
    for (method in names(method_predictions)) {
      
      met <-
        evaluate_probabilities(
          test$y,
          method_predictions[[method]]
        )
      
      prob_results[[prob_counter]] <-
        data.frame(
          replication = r,
          shift_type = "slope_shift",
          shift_value = kappa,
          method = method,
          event_rate = mean(test$y),
          met
        )
      
      prob_counter <- prob_counter + 1
    }
    
    shifted_threshold <-
      optimal_threshold(
        adapt$y,
        p_adapt_old
      )
    
    frozen_BA <-
      balanced_accuracy(
        test$y,
        p_test_old,
        baseline_threshold
      )
    
    adapted_BA <-
      balanced_accuracy(
        test$y,
        p_test_old,
        shifted_threshold
      )
    
    threshold_results[[threshold_counter]] <-
      data.frame(
        replication = r,
        shift_type = "slope_shift",
        shift_value = kappa,
        baseline_threshold = baseline_threshold,
        adapted_threshold = shifted_threshold,
        threshold_change =
          shifted_threshold - baseline_threshold,
        frozen_BA = frozen_BA,
        adapted_BA = adapted_BA,
        BA_gain = adapted_BA - frozen_BA
      )
    
    threshold_counter <- threshold_counter + 1
  }
  
  if (r %% 25 == 0)
    cat("Slope shift:", r, "of", R, "replications complete\n")
}


# ------------------------------------------------------------
# 13. COMBINE RAW RESULTS
# ------------------------------------------------------------

prob_raw <- do.call(
  rbind,
  prob_results
)

threshold_raw <- do.call(
  rbind,
  threshold_results
)

rownames(prob_raw) <- NULL
rownames(threshold_raw) <- NULL


# ------------------------------------------------------------
# 14. SUMMARIZE PROBABILITY ADAPTATION
# ------------------------------------------------------------

metric_names <- c(
  "log_loss",
  "brier",
  "auc",
  "cal_intercept",
  "cal_slope"
)

prob_groups <- split(
  prob_raw,
  list(
    prob_raw$shift_type,
    prob_raw$shift_value,
    prob_raw$method
  ),
  drop = TRUE
)

prob_summary_list <- lapply(
  prob_groups,
  function(d) {
    
    out <- data.frame(
      shift_type = d$shift_type[1],
      shift_value = d$shift_value[1],
      method = d$method[1],
      R = nrow(d),
      event_rate = mean(d$event_rate)
    )
    
    for (m in metric_names) {
      
      vals <- d[[m]]
      
      out[[paste0("mean_", m)]] <-
        mean(vals, na.rm = TRUE)
      
      out[[paste0("sd_", m)]] <-
        sd(vals, na.rm = TRUE)
      
      out[[paste0("mcse_", m)]] <-
        sd(vals, na.rm = TRUE) /
        sqrt(sum(!is.na(vals)))
    }
    
    out
  }
)

prob_summary <- do.call(
  rbind,
  prob_summary_list
)

rownames(prob_summary) <- NULL

prob_summary <- prob_summary[
  order(
    prob_summary$shift_type,
    prob_summary$shift_value,
    prob_summary$method
  ),
]


# ------------------------------------------------------------
# 15. SUMMARIZE THRESHOLD ADAPTATION
# ------------------------------------------------------------

threshold_groups <- split(
  threshold_raw,
  list(
    threshold_raw$shift_type,
    threshold_raw$shift_value
  ),
  drop = TRUE
)

threshold_summary_list <- lapply(
  threshold_groups,
  function(d) {
    
    data.frame(
      shift_type = d$shift_type[1],
      shift_value = d$shift_value[1],
      R = nrow(d),
      
      mean_baseline_threshold =
        mean(d$baseline_threshold),
      
      mean_adapted_threshold =
        mean(d$adapted_threshold),
      
      mean_threshold_change =
        mean(d$threshold_change),
      
      mcse_threshold_change =
        sd(d$threshold_change) /
        sqrt(nrow(d)),
      
      mean_frozen_BA =
        mean(d$frozen_BA),
      
      mean_adapted_BA =
        mean(d$adapted_BA),
      
      mean_BA_gain =
        mean(d$BA_gain),
      
      mcse_BA_gain =
        sd(d$BA_gain) /
        sqrt(nrow(d))
    )
  }
)

threshold_summary <- do.call(
  rbind,
  threshold_summary_list
)

rownames(threshold_summary) <- NULL

threshold_summary <- threshold_summary[
  order(
    threshold_summary$shift_type,
    threshold_summary$shift_value
  ),
]


# ------------------------------------------------------------
# 16. SAVE EVERYTHING
# ------------------------------------------------------------

write.csv(
  prob_raw,
  file.path(
    out_dir,
    "adaptation_probability_raw.csv"
  ),
  row.names = FALSE
)

write.csv(
  prob_summary,
  file.path(
    out_dir,
    "adaptation_probability_summary.csv"
  ),
  row.names = FALSE
)

write.csv(
  threshold_raw,
  file.path(
    out_dir,
    "adaptation_threshold_raw.csv"
  ),
  row.names = FALSE
)

write.csv(
  threshold_summary,
  file.path(
    out_dir,
    "adaptation_threshold_summary.csv"
  ),
  row.names = FALSE
)


# ------------------------------------------------------------
# 17. PUBLICATION-FOCUSED ENDPOINT TABLE
# ------------------------------------------------------------

endpoint_conditions <- (
  prob_summary$shift_type == "covariate_misspecified" &
    prob_summary$shift_value == 2
) |
  (
    prob_summary$shift_type == "intercept_shift" &
      prob_summary$shift_value == 1
  ) |
  (
    prob_summary$shift_type == "slope_shift" &
      prob_summary$shift_value == 1.6
  )

endpoint_table <-
  prob_summary[
    endpoint_conditions,
    c(
      "shift_type",
      "shift_value",
      "method",
      "event_rate",
      "mean_log_loss",
      "mcse_log_loss",
      "mean_brier",
      "mean_auc",
      "mcse_auc",
      "mean_cal_intercept",
      "mean_cal_slope"
    )
  ]

write.csv(
  endpoint_table,
  file.path(
    out_dir,
    "adaptation_endpoint_comparison.csv"
  ),
  row.names = FALSE
)


# ------------------------------------------------------------
# 18. PRINT RESULTS
# ------------------------------------------------------------

cat("\n\n====================================================\n")
cat("ADAPTATION EXPERIMENT COMPLETE\n")
cat("====================================================\n\n")

cat("Strongest-shift probability comparison:\n\n")

print(
  endpoint_table,
  row.names = FALSE,
  digits = 5
)

cat("\n\nThreshold adaptation summary:\n\n")

print(
  threshold_summary,
  row.names = FALSE,
  digits = 5
)

cat("\n\nFiles written to:\n")
cat(out_dir, "\n")

cat("\nMain files:\n")
cat("  adaptation_probability_summary.csv\n")
cat("  adaptation_threshold_summary.csv\n")
cat("  adaptation_endpoint_comparison.csv\n")

cat("\nSimulation seed:", 1998, "\n")
cat("Monte Carlo replications:", R, "\n")
cat("Sample size per train/adaptation/test sample:", n_train, "\n")
cat("\nDONE.\n")