rolling_skew <- function(x, n) {
  rollapply(x, FUN=kurtosis, width=n)
}
