# EACD(1,1) -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
da=read.table('d-aapl9907.txt',header = T)
range=log(da$high/da$low)
N=length(range)
psi=c(mean(range),rep(0,N-1))
logl <- function(parm) {
  alpha0=parm[1]
  alpha1=parm[2]
  beta1=parm[3]
  for (t in 2:N) {
    psi[t]=alpha0 + alpha1*range[t-1] + beta1*psi[t-1]
  }
  ll=sum(-log(psi)-range/psi)
  -ll
}
S=1e-6
init_values=c(alpha0=mean(range),alpha1=0.5,beta1=0.4)
mm=optim(init_values,logl,method = 'L-BFGS-B',
         lower = c(S,S,S),
         upper = c(5*mean(range),1-S,1-S),
         control = list(maxit=500))
mm$convergence
round(mm$par,3)
# WACD(1,1) -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
da=read.table('d-aapl9907.txt',header = T)
range=log(da$high/da$low)
N=length(range)
psi=c(mean(range),rep(0,N-1))
logl <- function(parm) {
  alpha0=parm[1]
  alpha1=parm[2]
  beta1=parm[3]
  alpha=parm[4]
  for (t in 2:N) {
    psi[t]=alpha0 + alpha1*range[t-1] + beta1*psi[t-1]
  }
  gma=log(gamma(1+1/alpha))
  eta=psi/exp(gma)
  ll=sum(log(alpha)+(alpha-1)*log(range)-alpha*log(eta)-(range/eta)^alpha)
  -ll
}
S=1e-6
init_values=c(alpha0=mean(range),alpha1=0.3,beta1=0.2,alpha=1)
mm=optim(init_values,logl,method = 'L-BFGS-B',
         lower = c(S,S,S,S),
         upper = c(5*mean(range),1-S,1-S,10),
         control = list(maxit=500))
mm$convergence
round(mm$par,3)
# GACD(1,1) -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
da=read.table('d-aapl9907.txt',header = T)
range=log(da$high/da$low)
N=length(range)
psi=c(mean(range),rep(0,N-1))
logl <- function(parm) {
  alpha0=parm[1]
  alpha1=parm[2]
  beta1=parm[3]
  alpha=parm[4]
  kappa=parm[5]
  for (t in 2:N) {
    psi[t]=alpha0 + alpha1*range[t-1] + beta1*psi[t-1]
  }
  lma=log(gamma(kappa+1/alpha))-log(gamma(kappa))
  eta=psi/exp(lma)
  ll=sum(log(alpha)+
           (kappa*alpha-1)*log(range)-
           kappa*alpha*log(eta)-
           log(gamma(kappa))-
           (range/eta)^alpha)
  -ll
}
S=1e-6
init_values=c(alpha0=mean(range),alpha1=S,beta1=S,
              alpha=1,kappa=1)
mm=optim(init_values,logl,method = 'L-BFGS-B',
         lower = rep(S,5),
         upper = c(5*mean(range),1-S,1-S,10,10),
         control = list(maxit=500))
mm$convergence
round(mm$par,5)
