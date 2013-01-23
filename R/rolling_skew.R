rolling_skew <- function(x, n) {
  rollapply(x, FUN=skewness, width=n)
}
