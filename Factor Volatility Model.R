# Factor Volatility Model
# Ruey S. Tsay, Analysis of Financial Time Series, 3th p.544
# data -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
da=read.table('m-ibmspln.dat',header = T)
ibm=da$ibm
sp500=da$sp
N=nrow(da)
# VAR(3) ------------------------------------------------------------------
library(vars)
m1=vars::VAR(da, p = 3)
restrict <- matrix(c(0, 1, 0, 0, 0, 1, 1,
                     0, 1, 0, 0, 0, 1, 1),nrow=2, byrow=TRUE)
m2=restrict(m1,method ="manual",resmat=restrict)
sm2=summary(m2)
sigma.var=sm2$covres
e1=eigen(sigma.var)
cat('First principal component explains ',
    round(e1$values[1]/sum(e1$values)*100,1),
    "% of \n the variance of residuals\n",
    sep = "")
evect=-e1$vectors[,1]
cat('First principal component: x = ',
    round(evect[1],3),"*a1 + ",round(evect[2],3),'*a2\n',sep = "")
rm(list=c('m1','m2','sm2','e1','evect','restrict','sigma.var'))
# PCA ---------------------------------------------------------------------
e2=eigen(cov(da))
evect2=e2$vectors
rm(list=c('e2'))
# GARCH(1,1) --------------------------------------------------------------
x=(-evect2[1])*ibm+(-evect2[2])*sp500
library(rugarch)
garchSpec <- ugarchspec(
  mean.model=list(armaOrder=c(1,0)),
  variance.model=list(garchOrder=c(1,1)))
garchFit <- ugarchfit(spec=garchSpec, data=x)
h=garchFit@fit$sigma^2
rm(list=c('x','garchSpec','garchFit','evect2'))
# Factor Volatility Model -------------------------------------------------
da1 <- da %>% 
  as_tibble() %>% 
  mutate(ibm.L1 = dplyr::lag(ibm),
         ibm.L2 = dplyr::lag(ibm,2),
         sp500.L1 = dplyr::lag(sp500))
m3=lm(ibm~ibm.L1+ibm.L2+sp500.L1,da1)
ibm.coef=unname(coef(m3))
h10=stats::sigma(m3)^2
u1=resid(m3)[[1]]
h20=stats::sigma(lm(sp500~1,da))^2
u2=(sp500-mean(sp500))[1:3]
rm(list=c('da1','m3'))
logl <- function(parm){
  p10=parm[1]; p11=parm[2]; p12=parm[3]; p13=parm[4]
  p20=parm[5]
  c1=parm[6]; c2=parm[7]
  a11=parm[8]
  b1=parm[9]; b2=parm[10]
  q0=parm[11]; q1=parm[12]; q2=parm[13]
  #
  a1=c(0,0,u1,rep(0,N-3))
  a2=c(u2,rep(0,N-3))
  h1=c(rep(h10,3),rep(0,N-3))
  h2=c(rep(h20,3),rep(0,N-3))
  rho=c(rep(0.6,3),rep(0,N-3))
  q=rep(0,N)
  for (t in 4:N) {
    a1[t]=ibm[t]-p10-p11*ibm[t-1]-p12*ibm[t-2]-p13*sp500[t-2]
    a2[t]=sp500[t]-p20
    
    h1[t]=c1+a11*a1[t-1]^2+b1*h[t]
    h2[t]=c2              +b2*h[t]
    q[t]=q0+q1*rho[t-1]+q2*a1[t-1]*a2[t-1]/sqrt(h1[t-1]*h2[t-1])
    rho[t]=exp(q[t])/(1+exp(q[t]))
  }
  # negative log likelihood
  sum(0.5*(log(h1)+log(h2)+log(1-rho^2)+
             1/(1-rho^2)*(a1^2/h1+a2^2/h2-2*rho*a1*a2/sqrt(h1*h2))))
}
params = c(p10=ibm.coef[1], p11=ibm.coef[2], p12=ibm.coef[3], p13=ibm.coef[4],
           p20=mean(sp500),
           c1=20, c2=-5.62,
           a11=0.098,
           b1=0.333, b2=0.596,
           q0=-2.1, q1=4.12, q2=0.078)
S = 1e-6
lowerBounds = c(
  p10 = -5*abs(ibm.coef[1]), p11 = -5*abs(ibm.coef[2]), p12 = -5*abs(ibm.coef[3]),
  p13 = -5*abs(ibm.coef[4]),
  p20 = -5*abs(mean(sp500)),
  c1 = -30, c2 = -30,
  a11 = S,
  b1 = S, b2 = S,
  q0 = -5, q1 = -5, q2 = -5)
upperBounds = c(
  p10 = 5*abs(ibm.coef[1]), p11 = 5*abs(ibm.coef[2]), p12 = 5*abs(ibm.coef[3]),
  p13 = 5*abs(ibm.coef[4]),
  p20 = -5*abs(mean(sp500)),
  c1 = 30, c2 = 30,
  a11 = 1-S,
  b1 = 1-S, b2 = 1-S,
  q0 = 5, q1 = 5, q2 = 5)
fit=nlminb(params,logl, lower = lowerBounds, upper = upperBounds)
fit$convergence
pp=fit$par
# display coefficients
pp1=round(pp,3)
pp1[1:4]
pp1[5]
pp1[6:7]
pp1[8:9]
pp1[10]
pp1[11:13]
# Hessian, result -----------------------------------------------------------------
epsilon = 0.0001*fit$par
npar=length(params)
Hessian = matrix(0, ncol = npar, nrow = npar)
for (i in seq_along(npar)) {
  for (j in seq_along(npar)) {
    x1 = x2 = x3 = x4 = fit$par
    x1[i] = x1[i] + epsilon[i]; x1[j] = x1[j] + epsilon[j]
    x2[i] = x2[i] + epsilon[i]; x2[j] = x2[j] - epsilon[j]
    x3[i] = x3[i] - epsilon[i]; x3[j] = x3[j] + epsilon[j]
    x4[i] = x4[i] - epsilon[i]; x4[j] = x4[j] - epsilon[j]
    Hessian[i, j] = (logl(x1)-logl(x2)-logl(x3)+logl(x4))/
      (4*epsilon[i]*epsilon[j])
  }
}
# Hessian = stats::optimHess(params,logl)
stderr = sqrt(diag(solve(Hessian)))
data.frame(
  term=names(params),
  estimate= unname(pp),
  std.error = stderr) %>% 
  as_tibble() %>% 
  mutate(statistic=estimate/std.error,
         p.value=2*(1-pnorm(abs(statistic)))) %>% 
  mutate(across(-term,~num(.x, digits = 3)))
