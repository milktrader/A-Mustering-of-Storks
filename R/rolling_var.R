rolling_var <- function(x, n) {
  foo = rollapply(x, FUN=var, width=n)
  bar = cbind(foo, index(x))
  colnames(bar) = paste("var", n, sep=".")
  bar
}
