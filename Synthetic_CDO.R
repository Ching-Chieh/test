# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.610 Example 25.2
# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
m = 20
tau = seq(0.25, 5, 0.25)
rho = 0.15
R = 0.4
aL = 0.03
aH = 0.06
n = 125
nL = aL*n/(1-R)
nH = aH*n/(1-R)
mnL = ceiling(nL)
mnH = ceiling(nH)
r = 0.035
s = 0.005
# lambda
f1 <- function(h){
  t = seq(0.25, 5, 0.25)
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
# Method 1 -----------------------------------------------------------------------
Af1 <- function(f) {
  dnorm(f)*Af(f)
}
Bf1 <- function(f) {
  dnorm(f)*Bf(f)
}
Cf1 <- function(f) {
  dnorm(f)*Cf(f)
}
A = integrate(Af1, -Inf, Inf)$value
B = integrate(Bf1, -Inf, Inf)$value
C = integrate(Cf1, -Inf, Inf)$value
(spread = C/(A+B))
# Method 2 Gauss-Hermite quadrature -----------------------------------------------------------------------
gauher <- function(n) {
  EPS <- 1.0e-14
  PIM4 <- 0.7511255444649425
  MAXIT <- 10
  m <- (n + 1) / 2
  x <- numeric(n)
  w <- numeric(n)
  for (i in 1:m) {
    if (i == 1) {
      z <- sqrt(2 * n + 1) - 1.85575 * (2 * n + 1) ^ (-0.16667)
    } else if (i == 2) {
      z <- z - 1.14 * n ^ 0.426 / z
    } else if (i == 3) {
      z <- 1.86 * z - 0.86 * x[1]
    } else if (i == 4) {
      z <- 1.91 * z - 0.91 * x[2]
    } else {
      z <- 2.0 * z - x[i - 2]
    }
    its <- 0
    while (its < MAXIT) {
      p1 <- PIM4
      p2 <- 0.0
      for (j in 1:n) {
        p3 <- p2
        p2 <- p1
        p1 <- z * sqrt(2.0 / j) * p2 - sqrt((j - 1) / j) * p3
      }
      pp <- sqrt(2 * n) * p2
      z1 <- z
      z <- z1 - p1 / pp
      if (abs(z - z1) <= EPS) break
      its <- its + 1
    }
    if (its >= MAXIT) stop("Too many iterations in gauher")
    x[i] <- z
    x[n - i + 1] <- -z
    w[i] <- 2.0 / (pp * pp)
    w[n - i + 1] <- w[i]
  }
  list("x" = x, "w" = w)
}
cat("\014")
M <- 60
result <- gauher(M)
x = result$x*sqrt(2)
w = result$w/sqrt(pi)
A = sum(w*sapply(x, Af))
B = sum(w*sapply(x, Bf))
C = sum(w*sapply(x, Cf))
(spread = C/(A+B))
