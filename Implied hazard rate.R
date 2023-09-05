# Calculate implied hazard rate from market CDS spread
# 
rm(list=ls())
f <- function(h)
{
  r <- 0.05
  s <- 0.01
  rec <- 0.4
  sur <- sapply(1:5, function(x) exp(-h*x))
  def <- c(1-sur[1], -diff(sur))
  t <- seq(0.5,4.5,1)
  sum1 <- sum(sur*s*exp(-r*c(1:5)))
  sum2 <- sum(def*(1-rec)*exp(-r*t))
  sum3 <- sum(def*0.5*s*exp(-r*t))
  return(sum1+sum3-sum2)
}
result <- uniroot(f, c(0,2), tol = 1e-10)
result$root
