# Compound correlations -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
m = 20
tau = seq(0.25, 5, 0.25)
R = 0.4
n = 125
r = 0.03
s = 0.0023
f1 <- function(h){
  t = tau
  t1 = seq(0.125, by = 0.25, length.out = 20)
  ps = exp(-h*t)
  pd = c(1-ps[1], -diff(ps))
  s = s/4
  PV_expected_payment = sum(ps*s*exp(-r*t))
  PV_expected_payoff = sum(pd*(1-R)*exp(-r*t1))
  PV_expected_accrual_payment = sum(pd*0.125*s*exp(-r*t1))
  PV_expected_payment + PV_expected_accrual_payment - PV_expected_payoff
}
lambda = uniroot(f1, interval = c(0,1))$root
a = c(0,3,6,9,12,22)*0.01
tranche_quote = c(0.1034,
                  41.59*0.0001,
                  11.95*0.0001,
                  5.6*0.0001,
                  2*0.0001)
implied_cor = c()
for (i in 1:5) {
  cat('i = ', i , '\n', sep = "")
  f2 <- function(rho) {
    aL = a[i]
    aH = a[i+1]
    nL = aL*n/(1-R)
    nH = aH*n/(1-R)
    mnL = floor(nL) + 1
    mnH = floor(nH) + 1
    P <- function(k, t, f){
      Q = pnorm((qnorm(1-exp(-lambda*t))-sqrt(rho)*f)/sqrt(1-rho))
      dbinom(k, n, Q)
    }
    E <- function(t, f) {
      sum0 = 0
      for (k in 0:(mnL-1)) {
        sum0 = sum0 + P(k, t, f)
      }
      for (k in mnL:(mnH-1)) {
        sum0 = sum0 + P(k, t, f)*(aH-k*(1-R)/n)/(aH-aL)
      }
      sum0
    }
    Af <- function(f) {
      sum0 = tau[1]*E(tau[1], f)*exp(-r*tau[1])      # j = 1
      for (j in 2:m) {
        sum0 = sum0 + (tau[j]-tau[j-1])*E(tau[j], f)*exp(-r*tau[j])
      }
      sum0
    }
    Bf <- function(f) {
      sum0 = 0.5*tau[1]*(1 - E(tau[1], f))*exp(-r*0.5*tau[1])
      for (j in 2:m) {
        sum0 = sum0 + 0.5*
          (tau[j]-tau[j-1])*
          (E(tau[j-1], f) - E(tau[j], f))*
          exp(-r*0.5*(tau[j-1] + tau[j]))
      }
      sum0
    }
    Cf <- function(f) {
      sum0 = (1 - E(tau[1], f))*exp(-r*0.5*tau[1])
      for (j in 2:m) {
        sum0 = sum0 +
          (E(tau[j-1], f) - E(tau[j], f))*
          exp(-r*0.5*(tau[j-1] + tau[j]))
      }
      sum0
    }
    Af1 <- function(f) dnorm(f)*Af(f)
    Bf1 <- function(f) dnorm(f)*Bf(f)
    Cf1 <- function(f) dnorm(f)*Cf(f)
    A = integrate(Af1, -Inf, Inf)$value
    B = integrate(Bf1, -Inf, Inf)$value
    C = integrate(Cf1, -Inf, Inf)$value
    if (i == 1) return (C - 0.05*(A+B) - tranche_quote[i])
    else return(C/(A+B) - tranche_quote[i])
  }
  implied_cor = c(implied_cor, uniroot(f2, interval = c(0, 0.9))$root)
}
names(implied_cor) = c('0-3%','3-6%','6-9%','9-12%','12-22%')
formattable::percent(implied_cor, digits = 1)
# PV of expected loss ---------------------------------------------------------
cat("\014")
varlist = ls()
varlist = varlist[!(varlist %in% c('lambda','implied_cor'))]
rm(list=varlist)
rho = as.numeric(implied_cor)
m = 20
tau = seq(0.25, 5, 0.25)
R = 0.4
n = 125
r = 0.03
s = 0.0023
C = c()
a = c(0, 0.03, 0.06, 0.09, 0.12, 0.22)
for (i in 1:5) {
  aL = a[i]
  aH = a[i+1]
  nL = aL*n/(1-R)
  nH = aH*n/(1-R)
  mnL = floor(nL) + 1
  mnH = floor(nH) + 1
  P <- function(k, t, f){
    Q = pnorm((qnorm(1-exp(-lambda*t))-sqrt(rho[i])*f)/sqrt(1-rho[i]))
    dbinom(k, n, Q)
  }
  E <- function(t, f) {
    sum0 = 0
    for (k in 0:(mnL-1)) {
      sum0 = sum0 + P(k, t, f)
    }
    for (k in mnL:(mnH-1)) {
      sum0 = sum0 + P(k, t, f)*(aH-k*(1-R)/n)/(aH-aL)
    }
    sum0
  }
  Cf <- function(f) {
    sum0 = (1 - E(tau[1], f))*exp(-r*0.5*tau[1])
    for (j in 2:m) {
      sum0 = sum0 +
        (E(tau[j-1], f) - E(tau[j], f))*
        exp(-r*0.5*(tau[j-1] + tau[j]))
    }
    sum0
  }
  Cf1 <- function(f) dnorm(f)*Cf(f)
  C = c(C, integrate(Cf1, -Inf, Inf)$value)
}
C
PVEL = c(0,cumsum(C))
# Table 25.6 doesn't have the quote for tranche 22%-100%.
# X = 100% can't be plot.
library(ggplot2)
library(scales)
ggplot(data.frame(X=a, y=PVEL), aes(X,y)) +
  geom_point(shape = 18) +
  geom_line() +
  labs(y = "PV of expected loss") +
  scale_x_continuous(breaks = seq(0, 0.25, 0.05), labels = scales::percent)
