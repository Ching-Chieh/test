# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.6117 Example 25.3
# pracma -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
t=1:5
t1 = seq(0.5, by = 1, length.out = 5)
lambda = 0.02
rho = 0.3
R = 0.4
r = 0.05
Q = function(f) pnorm((qnorm(1-exp(-lambda*t))-sqrt(rho)*f)/sqrt(1-rho))
p = function(f) {
  p1 = 1-pbinom(2,10,Q(f))
  c(p1[1], diff(p1))
}
Cf = function(f) sum(p(f)*(1-R)*exp(-r*t1))
Af = function(f) sum(pbinom(2,10,Q(f))*exp(-r*t))
Bf = function(f) sum(0.5*p(f)*exp(-r*t1))
f = -1.0104
round(c(Cf(f),Af(f),Bf(f)),4)
rm(list=c('f'))
Cf1 = function(f) dnorm(f)*Cf(f)
Af1 = function(f) dnorm(f)*Af(f)
Bf1 = function(f) dnorm(f)*Bf(f)
library(pracma)
C = pracma::integral(Cf1, -Inf, Inf) # Using stats::integrate() or Gauss-Hermite quadrature approximation will yield wrong answer.
A = pracma::integral(Af1, -Inf, Inf)
B = pracma::integral(Bf1, -Inf, Inf)
round(C,4)
round(A,4)
round(B,4)
spread = C/(A+B)
round(spread,4)
