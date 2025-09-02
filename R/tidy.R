#' @importFrom generics tidy
#' @export
generics::tidy

tidy.avlm <- function(x, conf.int = FALSE, conf.level = 0.95, exponentiate = FALSE, ...) {
  ret <- tibble::as_tibble(summary(x)$coefficients, rownames = "term")
  colnames(ret) <- c("term", "estimate", "std.error", "statistic", "p.value")
  coefs <- stats::coef(x)
  if (length(coefs) != nrow(ret)) {
    coefs <- tibble::enframe(coefs, name = "term", value = "estimate")
    ret <- dplyr::left_join(coefs, ret, by = c("term", "estimate"))
  }
  if (conf.int) {
    ci <- suppressMessages(confint.avlm(x, ...))
    if (is.null(dim(ci))) {
        ci <- matrix(ci, nrow = 1)
        rownames(ci) <- names(coef(x))[1]
    }
    ci <- tibble::as_tibble(ci, rownames = "term", .name_repair = "minimal")
    names(ci) <- c("term", "conf.low", "conf.high")
    ret <- dplyr::left_join(ret, ci, by = "term")
  }
  if (exponentiate) {
    ret <- dplyr::mutate(ret, "estimate" = exp(get("estimate")))
    if ("conf.low" %in% colnames(ret)) {
        ret <- dplyr::mutate(ret, dplyr::across(c("conf.low", "conf.high"), exp))
    }
  }
  ret
}

tidy.avaov <- function(x, intercept = FALSE, ...) {
  aov_summary <- tibble::as_tibble(
    summary(x, intercept = intercept, ...)[[1]],
    rownames = "term"
  )
  aov_summary$term <- trimws(aov_summary$term)
  dplyr::rename(
    aov_summary,
    df = "Df",
    sumsq = "Sum Sq",
    meansq = "Mean Sq",
    statistic = "F value", 
    p.value = "Pr(>F)"
  )
}
