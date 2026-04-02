# ── tidy.avlm ─────────────────────────────────────────────────────────────────

test_that("tidy.avlm p-values match summary.avlm coefficients", {
  std_fit <- lm(mpg ~ wt + hp, data = mtcars)
  av_fit <- av(std_fit, g = 1)
  tidy_pvals <- tidy(av_fit)$p.value
  summ_pvals <- summary(av_fit)$coefficients[, 4]
  expect_equal(tidy_pvals, unname(summ_pvals))
})

test_that("tidy.avlm default CIs match confint.avlm", {
  std_fit <- lm(mpg ~ wt + hp, data = mtcars)
  av_fit <- av(std_fit, g = 1)
  tidy_ci <- tidy(av_fit, conf.int = TRUE)
  conf_ci <- confint(av_fit)
  expect_equal(tidy_ci$conf.low, unname(conf_ci[, 1]))
  expect_equal(tidy_ci$conf.high, unname(conf_ci[, 2]))
})

test_that("tidy.avlm respects conf.level argument", {
  std_fit <- lm(mpg ~ wt + hp, data = mtcars)
  av_fit <- av(std_fit, g = 1)
  tidy_ci_90 <- tidy(av_fit, conf.int = TRUE, conf.level = 0.90)
  conf_ci_90 <- confint(av_fit, level = 0.90)
  expect_equal(tidy_ci_90$conf.low, unname(conf_ci_90[, 1]))
  expect_equal(tidy_ci_90$conf.high, unname(conf_ci_90[, 2]))
  # 0.90 CI bounds must differ from 0.95 bounds (guards against silent no-op)
  tidy_ci_95 <- tidy(av_fit, conf.int = TRUE, conf.level = 0.95)
  expect_false(isTRUE(all.equal(tidy_ci_90$conf.low, tidy_ci_95$conf.low)))
})

test_that("tidy.avlm p-values are more conservative than standard lm p-values", {
  for (g_val in c(1, 2, 5)) {
    std_fit <- lm(mpg ~ wt + hp, data = mtcars)
    std_pvals <- summary(std_fit)$coefficients[, 4]
    av_fit <- av(std_fit, g = g_val)
    av_pvals <- tidy(av_fit)$p.value
    for (i in seq_along(std_pvals)) {
      expect_gte(av_pvals[i], std_pvals[i])
    }
  }
})

test_that("tidy.avlm CIs are supersets of standard lm CIs", {
  for (g_val in c(1, 2, 5)) {
    for (level_val in c(0.90, 0.95, 0.99)) {
      std_fit <- lm(mpg ~ wt + hp, data = mtcars)
      std_ci <- confint(std_fit, level = level_val)
      av_fit <- av(std_fit, g = g_val)
      tidy_ci <- tidy(av_fit, conf.int = TRUE, conf.level = level_val)
      for (i in seq_len(nrow(std_ci))) {
        expect_lte(tidy_ci$conf.low[i], std_ci[i, 1])
        expect_gte(tidy_ci$conf.high[i], std_ci[i, 2])
      }
    }
  }
})

# ── tidy.avaov ────────────────────────────────────────────────────────────────

test_that("tidy.avaov p-values match summary.avaov p-values", {
  std_aov <- aov(Sepal.Length ~ Species, data = iris)
  av_aov <- av(std_aov, g = 1)
  tidy_pvals <- tidy(av_aov)$p.value
  summ_pvals <- summary(av_aov)[[1]]$`Pr(>F)`
  non_na <- !is.na(summ_pvals)
  expect_equal(tidy_pvals[non_na], summ_pvals[non_na])
})

test_that("tidy.avaov p-values are more conservative than standard aov p-values", {
  for (g_val in c(1, 2, 5)) {
    std_aov <- aov(Sepal.Length ~ Species, data = iris)
    std_pvals <- summary(std_aov)[[1]]$`Pr(>F)`
    av_aov <- av(std_aov, g = g_val)
    av_pvals <- tidy(av_aov)$p.value
    non_na <- !is.na(std_pvals)
    for (i in which(non_na)) {
      expect_gte(av_pvals[i], std_pvals[i])
    }
  }
})

# ── av_tidy ───────────────────────────────────────────────────────────────────

test_that("av_tidy p-values match tidy(av(model)) p-values", {
  skip_if_not_installed("broom")
  std_fit <- lm(mpg ~ wt + hp, data = mtcars)
  av_fit <- av(std_fit, g = 1)
  pvals_av_tidy <- av_tidy(std_fit, g = 1)$p.value
  pvals_tidy_av <- tidy(av_fit)$p.value
  expect_equal(pvals_av_tidy, pvals_tidy_av)
})

test_that("av_tidy p-values are more conservative than standard p-values", {
  skip_if_not_installed("broom")
  for (g_val in c(1, 2, 5)) {
    std_fit <- lm(mpg ~ wt + hp, data = mtcars)
    std_pvals <- summary(std_fit)$coefficients[, 4]
    av_pvals <- av_tidy(std_fit, g = g_val)$p.value
    for (i in seq_along(std_pvals)) {
      expect_gte(av_pvals[i], std_pvals[i])
    }
  }
})

test_that("av_tidy CIs are supersets of standard lm CIs", {
  skip_if_not_installed("broom")
  for (g_val in c(1, 2, 5)) {
    for (level_val in c(0.90, 0.95, 0.99)) {
      std_fit <- lm(mpg ~ wt + hp, data = mtcars)
      std_ci <- confint(std_fit, level = level_val)
      av_tidied <- av_tidy(std_fit, g = g_val, alpha = 1 - level_val, conf.int = TRUE)
      for (i in seq_len(nrow(std_ci))) {
        expect_lte(av_tidied$conf.low[i], std_ci[i, 1])
        expect_gte(av_tidied$conf.high[i], std_ci[i, 2])
      }
    }
  }
})

# ── av.slopes ─────────────────────────────────────────────────────────────────

test_that("av.slopes p-values are more conservative than standard slopes p-values", {
  skip_if_not_installed("marginaleffects")
  std_fit <- lm(mpg ~ wt + hp, data = mtcars)
  slopes_fit <- marginaleffects::slopes(std_fit)
  av_slopes_fit <- av(slopes_fit, g = 1)
  std_pvals <- slopes_fit$p.value
  av_pvals <- av_slopes_fit$p.value
  for (i in seq_along(std_pvals)) {
    expect_gte(av_pvals[i], std_pvals[i])
  }
})

test_that("av.slopes CIs are supersets of standard slopes CIs", {
  skip_if_not_installed("marginaleffects")
  for (g_val in c(1, 2, 5)) {
    std_fit <- lm(mpg ~ wt + hp, data = mtcars)
    slopes_fit <- marginaleffects::slopes(std_fit)
    av_slopes_fit <- av(slopes_fit, g = g_val)
    expect_true(all(av_slopes_fit$conf.low <= slopes_fit$conf.low))
    expect_true(all(av_slopes_fit$conf.high >= slopes_fit$conf.high))
  }
})
