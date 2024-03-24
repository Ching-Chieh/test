# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.613
# Base correlations ---------------------------------------------------------
cat("\014")
varlist = ls()
varlist = varlist[varlist!='implied_cor']
rm(list=varlist)
rho = as.numeric(implied_cor)
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
A = c()
B = c()
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
  Af1 <- function(f) {
    dnorm(f)*Af(f)
  }
  Bf1 <- function(f) {
    dnorm(f)*Bf(f)
  }
  Cf1 <- function(f) {
    dnorm(f)*Cf(f)
  }
  A = c(A, integrate(Af1, -Inf, Inf)$value)
  B = c(B, integrate(Bf1, -Inf, Inf)$value)
  C = c(C, integrate(Cf1, -Inf, Inf)$value)
}
round(C,5)*100 # expected loss (%)
round(A+B,4)   # PV of payments
#
base_cor = c()
for (i in 1:5) {
  cat('i = ', i, '\n', sep = '')
  Cvalue = sum(C[1:i]*diff(a)[1:i])/a[i+1]
  aL = 0
  aH = a[i+1]
  nL = aL*n/(1-R)
  nH = aH*n/(1-R)
  mnL = floor(nL) + 1
  mnH = floor(nH) + 1
  f3 <- function(rho) {
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
    integrate(Cf1, -Inf, Inf)$value - Cvalue
  }
  base_cor = c(base_cor, uniroot(f3, c(0,0.9))$root)
}
formattable::percent(base_cor, digits = 1)
