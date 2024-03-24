# Gibbs Sampling for parameters of linear regression with AR(2) errors
# Ruey S. Tsay, Analysis of Financial Time Series, 3th p.627
# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
da=read.table('w-gs1n3c.txt',header = T)
c1t=da$c1t
c3t=da$c3t
N=nrow(da)
m1=arima(c3t,c(2,0,0),xreg = c1t,include.mean = F) # method = "CSS-ML"
m1
sqrt(m1$sigma2)
#
m2=lm(c3t~c1t-1)
z=resid(m2)
#
z1=dplyr::lag(z)[-(1:2)]
z2=dplyr::lag(z,2)[-(1:2)]
z=z[-(1:2)]
m3=lm(z~z1+z2-1)
phi1=coef(m3)[[1]]
phi2=coef(m3)[[2]]
sigmasq=stats::sigma(m3)^2
#
hbeta0=0.25
hphi0=diag(c(1/0.25,1/0.16))
lambda=0.05
v=10
ndraws=2100L
beta1.draw=NULL
phi1.draw=NULL
phi2.draw=NULL
sigmasq.draw=NULL
for (i in 1:ndraws) {
  # beta
  c3tf = c3t[-(1:2)]-phi1*dplyr::lag(c3t)[-(1:2)]-phi2*dplyr::lag(c3t,2)[-(1:2)]
  c1tf = c1t[-(1:2)]-phi1*dplyr::lag(c1t)[-(1:2)]-phi2*dplyr::lag(c1t,2)[-(1:2)]
  vbeta=1/(hbeta0+sum(c1tf^2)/sigmasq)   # variance
  betam=vbeta*sum(c1tf*c3tf)/sigmasq     # mean
  beta1=betam+rnorm(1,sd = sqrt(vbeta))
  # phi
  z = c3t-beta1*c1t
  z1 = dplyr::lag(z)[-(1:2)]
  z2 = dplyr::lag(z,2)[-(1:2)]
  z = z[-(1:2)]
  Z=matrix(c(z1,z2,z),ncol=3)
  ZZ=crossprod(Z)
  vphi=solve(hphi0+ZZ[1:2,1:2]/sigmasq)   # covariance matrix
  phim=vphi%*%ZZ[1:2,3]/sigmasq           # mean vector
  phidraw= phim+t(chol(vphi))%*%rnorm(2)
  phi1=phidraw[1,1]
  phi2=phidraw[2,1]
  # sigma^2
  z = c3t-beta1*c1t
  z1 = dplyr::lag(z)[-(1:2)]
  z2 = dplyr::lag(z,2)[-(1:2)]
  z = z[-(1:2)]
  at = z-phi1*z1-phi2*z2
  rss=sum(at^2)
  sigmasq=(lambda*v+rss)/rchisq(1,v+length(at))
  #
  beta1.draw=c(beta1.draw,beta1)
  phi1.draw=c(phi1.draw,phi1)
  phi2.draw=c(phi2.draw,phi2)
  sigmasq.draw=c(sigmasq.draw,sigmasq)
}
beta1.draw=beta1.draw[101:ndraws]
phi1.draw=phi1.draw[101:ndraws]
phi2.draw=phi2.draw[101:ndraws]
sigmasq.draw=sigmasq.draw[101:ndraws]
tibble(term=c('Mean','Std.Error'),
       b1=c(mean(beta1.draw),sd(beta1.draw)),
       phi1=c(mean(phi1.draw),sd(phi1.draw)),
       phi2=c(mean(phi2.draw),sd(phi2.draw)),
       sigmasq=c(mean(sigmasq.draw),sd(sigmasq.draw))) %>% 
  mutate(across(-c(term,sigmasq),~num(.x, digits = 3))) |> 
  mutate(sigmasq = num(sigmasq, digits = 5))
