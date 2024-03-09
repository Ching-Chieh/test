# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.570 Example 24.2
# Example 24.2 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
r = 0.05
y = c(0.065,0.068,0.0695)
rf_price <- function(t) {
  tt = seq(0.5,t,0.5)
  cf = rep(4, 2*t)
  cf[length(cf)] = cf[length(cf)] + 100
  sum(cf*exp(-r*tt))
}
price <- function(t) {
  tt = seq(0.5,t,0.5)
  cf = rep(4, 2*t)
  cf[length(cf)] = cf[length(cf)] + 100
  sum(cf*exp(-y[t]*tt))
}
brf = map_dbl(1:3, rf_price)
b = map_dbl(1:3, price)
round(b,2)
round(brf,2)
default_loss = brf - b
NDV <- function(t) {
  rev(accumulate(rep(4*exp(-r*0.25),t*2-1), ~.x*exp(-r*0.5) + .y, .init = 104*exp(-r*0.25)))
}
tf <- function(t) seq(0.25, by = 0.5, length.out = 2*t)
pvloss = map(1:3, ~(NDV(.x) - 40)*exp(-r*tf(.x)))
##
lambda <- c(0.02, 0.03, 0.05)
for (i in 1:3) {
  f <- function(lamb) {
    lambda[i] <- lamb
    lambda = rep(lambda, each = 2)
    ps = cumprod(exp(-0.5*lambda))   # purrr::accumulate(lambda, ~.x*exp(-0.5*.y), .init = 1)[-1]
    pd = c(1 - ps[1], -diff(ps))
    expect_loss = function(t){
      sum(pvloss[[t]]*pd[1:(2*t)])
    }
    EL = map_dbl(1:3, expect_loss)  
    default_loss[i] - EL[i]
  }
  lambda[i] <- uniroot(f, interval = c(0,1))$root
}
round(lambda*100,2)
