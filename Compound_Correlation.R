# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.613
# Compound correlations -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
m = 20
tau = seq(0.25, 5, 0.25)
R = 0.4
n = 125
r = 0.03
s = 0.0023
# lambda
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
(lambda = uniroot(f1, interval = c(0,1))$root)
#
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
    # library(pracma)
    # A = pracma::integral(Af1, -Inf, Inf)
    # B = pracma::integral(Bf1, -Inf, Inf)
    # C = pracma::integral(Cf1, -Inf, Inf)
    A = integrate(Af1, -Inf, Inf)$value
    B = integrate(Bf1, -Inf, Inf)$value
    C = integrate(Cf1, -Inf, Inf)$value
    if (i == 1) return (C - 0.05*(A+B) - tranche_quote[i])
    else return(C/(A+B) - tranche_quote[i])
  }
  implied_cor = c(implied_cor, uniroot(f2, interval = c(0, 0.9))$root)
  # rho upper bound should not set as 1. Q(t|F) will fail
}
names(implied_cor) = c('0-3%','3-6%','6-9%','9-12%','12-22%')
# paste0(round(implied_cor*100,1),'%')
# scales::label_percent(accuracy = 0.1)(implied_cor)
formattable::percent(implied_cor, digits = 1)
