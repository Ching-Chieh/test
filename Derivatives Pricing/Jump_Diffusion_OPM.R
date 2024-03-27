# Kou, S. (2002). A jump diffusion model for option pricing. Management Science
# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
S0 <- 80
K <- 81
tau <- 0.25
r <- 0.08
sig <- 0.2
lambda <- 10
kappa <- -0.02
eta <- 0.02

psi <- exp(kappa) / (1 - eta^2) - 1
hp <- (log(S0 / K) + (r + sig^2 / 2 - lambda * psi) * tau) / (sig * sqrt(tau))
hm <- (log(S0 / K) + (r - sig^2 / 2 - lambda * psi) * tau) / (sig * sqrt(tau))

cgeo <- exp(-lambda * tau) * (S0 * exp(-lambda * psi * tau) * pnorm(hp) - K * exp(-r * tau) * pnorm(hm))
cat("Price due to the geometric part: ", round(cgeo,2), "\n")

bp <- function(n) hp + n * kappa / (sig * sqrt(tau))
bm <- function(n) hm + n * kappa / (sig * sqrt(tau))
omega <- function(n) log(K / S0) + lambda * psi * tau - (r - sig^2 / 2) * tau - n * kappa
cp <- function(n) sig * sqrt(tau) / eta + omega(n) / (sig * sqrt(tau))
cm <- function(n) sig * sqrt(tau) / eta - omega(n) / (sig * sqrt(tau))

coef1 <- function(n,j) {
  exp(-lambda * tau) * 
  (lambda^n * tau^n / factorial(n)) * 
  (2^j / 2^(2 * n - 1)) * 
  choose(2 * n - j - 1, n - 1)
}
hh <- function(n,x) {
  if (n == -1) return(exp(-x^2/2))
  else if (n == 0) return(sqrt(2*pi)*pnorm(-x))
  else {
    h1 <- exp(-x^2/2)
    h2 <- sqrt(2*pi)*pnorm(-x)
    i <- 1
    while (i <= n) {
      h3 <- (h1 - x*h2) / i
      h1 <- h2
      h2 <- h3
      i <- i + 1
    }
    return(h3)
  }
}
# hh <-  function(n,x) {
#   if (n == -1) return(exp(-x^2/2))
#   else if (n == 0) return(sqrt(2*pi)*pnorm(-x))
#   else {
#     h <- rep(0, n+2)
#     h[1] <- exp(-x^2/2)
#     h[2] <- sqrt(2*pi)*pnorm(-x)
#     for (i in 3:(n+2)) {
#       h[i] = (h[i-2] - x*h[i-1]) / (i-2)
#     }
#     return(tail(h,1))
#   }
# }
a1 <- function(n,j) {
  S0 * exp(-lambda * psi * tau + n * kappa) / 2 *
  (1 / (1 - eta)^j + 1 / (1 + eta)^j) * pnorm(bp(n)) - exp(-r * tau) * K * pnorm(bm(n))
}
a2 <- function(n,j) {
  a22 <- exp(-r * tau - omega(n) / eta + sig^2 * tau / (2 * eta^2)) * K / 2
  sum0 = 0
  for (i in 0:(j-1)) {
    sum0 = sum0 + 
      (1 / (1 - eta)^(j - i) - 1) *
      (sig * sqrt(tau) / eta)^i /
      sqrt(2 * pi) *
      hh(i, cm(n))
  }
  a22*sum0
}
a3 <- function(n,j) {
  a33 <- exp(-r * tau + omega(n) / eta + sig^2 * tau / (2 * eta^2)) * K / 2
  sum0 = 0
  for (i in 0:(j-1)) {
    sum0 = sum0 + 
      (1 - 1 / (1 + eta)^(j - i)) *
      (sig * sqrt(tau) / eta)^i /
      sqrt(2 * pi) *
      hh(i, cp(n))
  }
  a33*sum0
}

nterm <- 10
cj <- 0
for (n in 1:nterm) {
  for (j in 1:n) {
    cj = cj + coef1(n,j) * (a1(n,j) + a2(n,j) + a3(n,j))
  }
}
c = cgeo + cj
cat("Price of a call: ", round(c,2), "\n")
p <- c + K * exp(-r * tau) - S0
cat("Price of a put: ", round(p,2), "\n")
