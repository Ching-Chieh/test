# Heston (1993) A Closed-Form Solution for Options with Stochastic Volatility
# with Applications to Bonds and Currency options. RFS
# Heston call -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
Heston_f <- function(phi, S, tau, r, v0, kappa, theta, sigma, rho, j){
  if (j == 1){
    u = 0.5
    b = kappa - rho*sigma
  }
  else{
    u = -0.5
    b = kappa
  }
  a = kappa*theta
  d = sqrt((rho*sigma*phi*1i - b)^2 - sigma^2*(2*u*phi*1i - phi^2))
  g = (b - rho*sigma*phi*1i + d)/(b - rho*sigma*phi*1i - d)
  C = r*phi*1i*tau + a/sigma^2*(
    (b - rho*sigma*phi*1i + d)*tau - 2*log((1-g*exp(d*tau))/(1-g))
  )
  D = (b - rho*sigma*phi*1i + d)/sigma^2*((1-exp(d*tau))/(1-g*exp(d*tau)))
  return(exp(C + D*v0 + 1i*phi*log(S)))
}
Heston_P_integrand <- function(phi, S, K, tau, r, v0, kappa, theta, sigma, rho, j){
  Re(exp(-1i*phi*log(K))*
       Heston_f(phi, S, tau, r, v0, kappa, theta, sigma, rho, j)/
       (1i*phi)
  )
}
Heston_P <- function(S, K, tau, r, v0, kappa, theta, sigma, rho, j){
  0.5 + 1/pi*
    integrate(Heston_P_integrand, lower = 0, upper = Inf, 
              S, K, tau, r, v0, kappa, theta, sigma, rho, j)$value
}
Heston_call <- function(S, K, tau, r, v0, kappa, theta, sigma, rho){
  S*Heston_P(S, K, tau, r, v0, kappa, theta, sigma, rho, 1) -
    K*exp(-r*tau)*Heston_P(S, K, tau, r, v0, kappa, theta, sigma, rho, 2)
}
###
S = 100
K = 110
tau = 0.2
r = 0.03
v0 = 0.2
kappa = 1
theta = 0.2
sigma = 0.6
rho = -0.7
Heston_call(S, K, tau, r, v0, kappa, theta, sigma, rho)
