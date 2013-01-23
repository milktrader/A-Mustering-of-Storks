pretty_returns <- function(returns,  xlab="", up.col='springgreen3', dn.col='skyblue3', main='System Returns'){

  RET   = na.omit(returns)
  ups   = nrow(RET[RET > 0])
  downs = nrow(RET) - ups

  ret_mean = format(mean(returns),digits = 3, scientific=FALSE)
  ret_var  = format(var(returns), digits = 3, scientific=FALSE)
  ret_skew = format(skewness(returns), digits = 3, scientific=FALSE)
  ret_kurt = format(kurtosis(returns), digits = 3, scientific=FALSE)
  
  mean_str = sprintf("mean:       %s ", ret_mean)
  var_str  = sprintf("var:            %s ", ret_var)
  skew_str = sprintf("skew:         %s ", ret_skew)
  kurt_str = sprintf("kurtosis:     %s ", ret_kurt)
  
  dens  =  density(RET)
  x1    =  min(which(dens$x >= 0))
  x2    =  max(which(dens$x <  1))
  x3    =  min(which(dens$x >= -1))
  x4    =  max(which(dens$x <  0))

  #png("1.png")
  #pdf("1.pdf")
  plot(dens, xlab=xlab, ylab="", main=main, yaxt="n")
  with(dens, polygon(x=c(x[c(x1,x1:x2,x2)]), y= c(0, y[x1:x2], 0), col=up.col))
  with(dens, polygon(x=c(x[c(x3,x3:x4,x4)]), y= c(0, y[x3:x4], 0), col=dn.col))
  legend("topleft", inset=.01, legend=c(ups,downs), fill=c(up.col, dn.col), cex=.8, bty='n')
#  legend("topright", inset=.01, legend=c(ret_mean, ret_var, ret_skew, ret_kurt), title="Moments", cex=.8, bty='n')
  legend("topright",  legend=c(mean_str, var_str, skew_str, kurt_str),  cex=.8, bty='n')

}
