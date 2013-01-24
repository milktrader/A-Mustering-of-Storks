rolling_skew <- function(x, n) {
  foo = rollapply(x, FUN=skewness, width=n)
  bar = cbind(foo, index(x))
  colnames(bar) = paste("sk", n, sep=".")
  bar
}
