rolling_kurt <- function(x, n) {
  foo = rollapply(x, FUN=kurtosis, width=n)
  bar = cbind(foo, index(x))
  colnames(bar) = paste("kurt", n, sep=".")
  bar
}
