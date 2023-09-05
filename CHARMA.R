* R program
* Conditional Heteroscedastic ARMA model
* Ruey S. Tsay, Analysis of Financial Time Series, 3th p.152
cat("\014")
rm(list=ls())
ret <- scan("sp500.dat")
loglik <- function(par){
  mu <- par[1]
  a0 <- par[2]
  a1 <- par[3]
  a12 <- par[4]
  a2 <- par[5]
  a3 <- par[6]
  loglik = 0
  T = length(ret)
  a = ret[1:3]-par[1]
  for (i in 4:T){
    at <- ret[i] - mu
    a <- c(a, at)
    h <- abs(a0 + a1*a[i-1]^2 + 2*a12*a[i-1]*a[i-2] + a2*a[i-2]^2 + a3*a[i-3]^2)
    loglik <- loglik - 0.5*(log(h) + at^2/h)
  }
  return(-loglik)
}
par_init <- c(mu=mean(ret), a0=var(ret),
              a1=abs(runif(1)), a12=runif(1), a2=abs(runif(1)), a3=abs(runif(1))) |> unname()
library(MASS)
library(NlcOptim)
confun <- function(x){
  f=NULL
  S=1e-6
  f=rbind(f,-x[2]+S) # a0 > 0
  f=rbind(f,-x[3]+S) # a1 > 0
  f=rbind(f,-x[5]+S) # a2 > 0
  f=rbind(f,-x[6]+S) # a3 > 0
  f=rbind(f, x[4]/sqrt(x[3]*x[5])-1) # constraint: rho12^2 <= 1
  return(list(ceq=NULL,c=f))
}
fit <- NlcOptim::solnl(X = par_init, objfun = loglik, confun = confun)
fit$par |> round(5)
sqrt(diag(solve(fit$hessian)))[3:6] |> round(4)
