cat("\014")
rm(list=ls())
library(quantmod)
da = quantmod::getSymbols('^SP100',
                     from = '1986-01-02', to = '1989-12-15', auto.assign = FALSE)
r = diff(log(as.numeric(da$SP100.Close)))
rf = 0
N = length(r)
h = rep(0,N)
h[1] = var(r)
negativelogl <- function(parms) {
  omega = parms[1]; alpha = parms[2]; beta = parms[3]; lambda = parms[4]
  e = rep(0,N)
  for (t in 2:N) {
    e[t-1] = r[t-1] - rf + 0.5*h[t-1] - lambda*sqrt(h[t-1])
    h[t] = omega + alpha*e[t-1]^2 + beta*h[t-1]
  }
  e[N] = r[N] - rf + 0.5*h[N] - lambda*sqrt(h[N])
  logl = -sum(log(h) + e^2/h)
  cat(logl, omega, alpha, beta, lambda, '\n')
  return(-logl)
}
parms = c(0.000015, 0.19, 0.72, 0.007)
S = 1e-6
# mm=optim(parms, negativelogl, lower = rep(S,4), method = 'L-BFGS-B')
mm=nlminb(parms, negativelogl, lower = rep(S,4))
round(mm$par,4)
