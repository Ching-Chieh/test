# Time-Varying Correlation Model
# Ruey S. Tsay, Analysis of Financial Time Series, 3th p.527
# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
da=read.table('m-ibmspln.dat',header = T)
ibm=da$ibm
sp500=da$sp
N=nrow(da)
###
y=ibm
y1=dplyr::lag(y)[-(1:2)]
x2=dplyr::lag(sp500,2)[-(1:2)]
y=y[-(1:2)]
m1=lm(y~y1+x2)
ibm.coef=unname(coef(m1))
h10=stats::sigma(m1)^2
u1=resid(m1)[[1]]
#
h20=var(sp500)
u2=(sp500-mean(sp500))[1:3]
rm(list=c('m1','y','y1','x2'))
###
logl <- function(parm) {
  p10=parm[1]; p11=parm[2]; p12=parm[3]
  p20=parm[4]
  c1=parm[5];    c2=parm[6]
  a11=parm[7];  a21=parm[8];  a22=parm[9]
  b11=parm[10]; b12=parm[11]; b21=parm[12]; b22=parm[13]
  q0=parm[14];   q1=parm[15];  q2=parm[16]
  #
  a1=c(0,0,u1,rep(0,N-3))
  a2=c(u2,rep(0,N-3))
  h1=c(rep(h10,3),rep(0,N-3))
  h2=c(rep(h20,3),rep(0,N-3))
  rho=c(rep(0.6,3),rep(0,N-3))
  q=rep(0,N)
  for (t in 4:N) {
    a1[t]=ibm[t]-p10-p11*ibm[t-1]-p12*sp500[t-2]
    a2[t]=sp500[t]-p20
    # h1[t]=c1+a11*a1[t-1]^2              +b11*h1[t-1]+b12*h2[t-1]
    # h2[t]=c2+a21*a1[t-1]^2+a22*a2[t-1]^2+b21*h1[t-1]+b22*h2[t-1]
    h1[t]=abs(c1+a11*a1[t-1]^2              +b11*h1[t-1]+b12*h2[t-1])
    h2[t]=abs(c2+a21*a1[t-1]^2+a22*a2[t-1]^2+b21*h1[t-1]+b22*h2[t-1])
    q[t]=q0+q1*rho[t-1]+q2*a1[t-1]*a2[t-1]/sqrt(h1[t-1]*h2[t-1])
    rho[t]=exp(q[t])/(1+exp(q[t]))
  }
  # negative log likelihood
  sum(0.5*(log(h1)+log(h2)+log(1-rho^2)+
             1/(1-rho^2)*(a1^2/h1+a2^2/h2-2*rho*a1*a2/sqrt(h1*h2))))
}
params = c(p10=ibm.coef[1], p11=ibm.coef[2], p12=ibm.coef[3],
           p20=mean(sp500),
           c1=2.8, c2=1.7,
           a11=0.084, a21=0.037, a22=0.054,
           b11=0.864, b12=-0.02, b21=-0.058, b22=0.914,
           q0=-2, q1=4, q2=0.088)
S = 1e-6
lowerBounds = c(
  p10 = -5*abs(ibm.coef[1]), p11 = -5*abs(ibm.coef[2]), p12 = -5*abs(ibm.coef[3]),
  p20 = -5*abs(mean(sp500)),
  c1 = S, c2 = S,
  a11 = S, a21 = -3, a22 = S,
  b11 = S, b12 = -3, b21 = -3, b22 = S,
  q0 = -5, q1 = -5, q2 = -5)
upperBounds = c(
  p10 = 5*abs(ibm.coef[1]), p11 = 5*abs(ibm.coef[2]), p12 = 5*abs(ibm.coef[3]),
  p20 = 5*abs(mean(sp500)),
  c1 = 5, c2 = 5,
  a11 = 1-S, a21 = 3, a22 = 1-S,
  b11 = 1-S, b12 = 3, b21 = 3, b22 = 1-S,
  q0 = 5, q1 = 5, q2 = 5)
fit=nlminb(params,logl, lower = lowerBounds, upper = upperBounds)
fit$convergence
pp=fit$par
# display coefficients
pp1=round(pp,3)
pp1[1:3]
pp1[4]
pp1[5:6]
matrix(c(pp1[7:8],0,pp1[9]),2,byrow = T)
matrix(c(pp1[10:13]),2,byrow = T)
pp1[14:16]
# 2 -----------------------------------------------------------------------
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
