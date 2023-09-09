# Smooth Transition AR (STAR) Model
# Ruey S. Tsay, Analysis of Financial Time Series, 3th, p.185
# This script includes:
#  1. nlminb
#     No need too much carefulness in log likelihood function.
#     Can't get Hessian matrix and thus can't get standard errors. So, I calculate numerical Hessian by myself.
#     The result is the same with the text.
#  2. optim L-BFGS-B
#     Need some carefulness in log likelihood function.
#     Negative variance results in NA of log likelihood function and stops optimization.
#     The result is a little different from the text.
#  3. optim Nelder-Mead with nlminb Start Values
#     Can get Hessian matrix and thus can get standard errors.
#     The result is the same with the text.
#  4. RATS program (much simpler)
# nlminb ---------------------------------------------------------------------------------------------------
# nlminb: BFGS Trust Region Quasi Newton Method
cat("\014")
rm(list=ls())
library(magrittr)
rtn=read.table('m-3m4608.txt', header = T)[,2]
N=length(rtn)
mu=mean(rtn)
sig2=var(rtn)
at=rtn[1:2]-mu
h=rep(sig2,2)
cnt=0
star <- function(par){
  cnt <<- cnt + 1
  f = 0
  for (t in as.integer(3:N)){
    resi = rtn[t]-par[1]
    at=c(at,resi)
    sig=par[2]+par[3]*at[t-1]^2+par[4]*at[t-2]^2
    sig1=par[5]+par[6]*at[t-1]^2
    ht=sig+sig1/(1+exp(-1000*at[t-1]))
    h=c(h,ht)
    epsi2 = resi^2/ht
    f=f+0.5*log(ht)+0.5*epsi2
  }
  cat(cnt,'************************************************\n')
  cat('par[2] = ',par[2],'\n')
  cat('par[3] = ',par[3],'\n')
  cat('par[4] = ',par[4],'\n')
  cat('par[5] = ',par[5],'\n')
  cat('par[6] = ',par[6],'\n')
  cat('ht = ',ht,'\n')
  cat('negative log likelihood = ',f,'\n')
  return(f)
}
par=c(mu,0.1*sig2,0.1,0.1,0.1,0.1)
S = 1e-6
mm=nlminb(start = par,
          objective=star,
          lower = c(-10*abs(mu),          S,  S,  S,-5,-5),
          upper = c( 10*abs(mu),100*abs(mu),1-S,1-S, 5, 5))
mm$convergence
mm$par %>% round(3)
param=mm$par
# numerical Hessian
cat("\014")
rm(list=setdiff(ls(),'param'))
rtn=read.table('m-3m4608.txt', header = T)[,2]
N=length(rtn)
mu=mean(rtn)
sig2=var(rtn)
at=rtn[1:2]-mu
h=rep(sig2,2)
star <- function(par){
  f = 0
  for (t in as.integer(3:N)){
    resi = rtn[t]-par[1]
    at=c(at,resi)
    sig=par[2]+par[3]*at[t-1]^2+par[4]*at[t-2]^2
    sig1=par[5]+par[6]*at[t-1]^2
    ht=sig+sig1/(1+exp(-1000*at[t-1]))
    h=c(h,ht)
    epsi2 = resi^2/ht
    f=f+0.5*log(ht)+0.5*epsi2
  }
  f
}
cat('numerical Hessian\n')
npar = length(param)
epsilon = 0.0001*param
Hessian = matrix(0, ncol = npar, nrow = npar)
for (i in 1L:npar) {
  for (j in 1L:npar) {
    x1 = x2 = x3 = x4 = param
    x1[i] = x1[i] + epsilon[i]; x1[j] = x1[j] + epsilon[j]
    x2[i] = x2[i] + epsilon[i]; x2[j] = x2[j] - epsilon[j]
    x3[i] = x3[i] - epsilon[i]; x3[j] = x3[j] + epsilon[j]
    x4[i] = x4[i] - epsilon[i]; x4[j] = x4[j] - epsilon[j]
    Hessian[i, j] = (star(x1)-star(x2)-star(x3)+star(x4))/(4*epsilon[i]*epsilon[j])
  }
}
# print coeftable
cat("Maximized log-likehood: ",-star(param),"\n")
names(param)=c('mu','c','a1','a2','sc','sa1')
se.coef = sqrt(diag(solve(Hessian)))
tval = param/se.coef
matcoef = cbind(param, se.coef, tval, 2*(1-pnorm(abs(tval))))
dimnames(matcoef) = list(names(tval),
                         c("Estimate","Std. Error","t value","Pr(>|t|)"))
cat("\nCoefficient(s):\n")
printCoefmat(matcoef, digits = 6, signif.stars = TRUE)

# optim L-BFGS-B ----------------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(magrittr)
rtn=read.table('m-3m4608.txt',header = T)[,2]
N=length(rtn)
mu=mean(rtn)
sig2=var(rtn)
at=rtn[1:2]-mu
h=rep(sig2,2)
cnt = 0
star <- function(par){
  cnt <<- cnt + 1
  f = 0
  ht_negative = FALSE
  for (t in as.integer(3:N)){
    resi = rtn[t]-par[1]
    at=c(at,resi)
    sig=par[2]+par[3]*at[t-1]^2+par[4]*at[t-2]^2
    sig1=par[5]+par[6]*at[t-1]^2
    ht=sig+sig1/(1+exp(-1000*at[t-1]))
    if(ht <= 0) {
      ht_negative = TRUE
      break
    }
    h=c(h,ht)
    epsi2 = resi^2/ht
    f=f+0.5*log(ht)+0.5*epsi2
  }
  cat(cnt,'************************************************\n')
  cat('par[2] = ',par[2],'\n')
  cat('par[3] = ',par[3],'\n')
  cat('par[4] = ',par[4],'\n')
  cat('par[5] = ',par[5],'\n')
  cat('par[6] = ',par[6],'\n')
  cat('ht = ',ht,'\n')
  if (ht_negative) f = 1e8
  cat('negative log likelihood = ',f,'\n')
  return(f)
}
par=c(mu,0.1*sig2,0.1,0.1,0.1,0.1)
S = 1e-6
mm=optim(par,
         star,
         method = "L-BFGS-B",
         lower = c(-10*abs(mu),          S,  S,  S,-5,-5),
         upper = c( 10*abs(mu),100*abs(mu),1-S,1-S, 5, 5),
         control = list(maxit=500),
         hessian = T)
mm$convergence
mm$par %>% round(3)
standard_error = sqrt(diag(solve(mm$hessian)))
param=mm$par
# print coeftable
names(param)=c('mu','c','a1','a2','sc','sa1')
se.coef = standard_error
tval = param/se.coef
matcoef = cbind(param, se.coef, tval, 2*(1-pnorm(abs(tval))))
dimnames(matcoef) = list(names(tval),
                         c("Estimate","Std. Error","t value","Pr(>|t|)"))
cat("\nCoefficient(s):\n")
printCoefmat(matcoef, digits = 6, signif.stars = TRUE)
# Nelder-Mead with nlminb Start Values -------------------------------------------------------------------------------
# Step 1: Use nlminb to get start values
cat("\014")
rm(list=ls())
library(magrittr)
rtn=read.table('m-3m4608.txt', header = T)[,2]
N=length(rtn)
mu=mean(rtn)
sig2=var(rtn)
at=rtn[1:2]-mu
h=rep(sig2,2)
cnt=0
star <- function(par){
  cnt <<- cnt + 1
  f = 0
  for (t in as.integer(3:N)){
    resi = rtn[t]-par[1]
    at=c(at,resi)
    sig=par[2]+par[3]*at[t-1]^2+par[4]*at[t-2]^2
    sig1=par[5]+par[6]*at[t-1]^2
    ht=sig+sig1/(1+exp(-1000*at[t-1]))
    h=c(h,ht)
    epsi2 = resi^2/ht
    f=f+0.5*log(ht)+0.5*epsi2
  }
  cat(cnt,'************************************************\n')
  cat('par[2] = ',par[2],'\n')
  cat('par[3] = ',par[3],'\n')
  cat('par[4] = ',par[4],'\n')
  cat('par[5] = ',par[5],'\n')
  cat('par[6] = ',par[6],'\n')
  cat('ht = ',ht,'\n')
  cat('negative log likelihood = ',f,'\n')
  return(f)
}
par=c(mu,0.1*sig2,0.1,0.1,0.1,0.1)
S = 1e-6
mm=nlminb(start = par,
          objective=star,
          lower = c(-10*abs(mu),          S,  S,  S,-5,-5),
          upper = c( 10*abs(mu),100*abs(mu),1-S,1-S, 5, 5))
nlminb_init_values = mm$par
## Step 2: Use Nelder-Mead Algorithm with nlminb start values
cat("\014")
rm(list=setdiff(ls(),'nlminb_init_values'))
library(magrittr)
rtn=read.table('m-3m4608.txt',header = T)[,2]
N=length(rtn)
mu=mean(rtn)
sig2=var(rtn)
at=rtn[1:2]-mu
h=rep(sig2,2)
cnt = 0
star <- function(par){
  cnt <<- cnt + 1
  f = 0
  ht_negative = FALSE
  for (t in as.integer(3:N)){
    resi = rtn[t]-par[1]
    at=c(at,resi)
    sig=par[2]+par[3]*at[t-1]^2+par[4]*at[t-2]^2
    sig1=par[5]+par[6]*at[t-1]^2
    ht=sig+sig1/(1+exp(-1000*at[t-1]))
    if(ht <= 0) {
      ht_negative = TRUE
      break
    }
    h=c(h,ht)
    epsi2 = resi^2/ht
    f=f+0.5*log(ht)+0.5*epsi2
  }
  cat(cnt,'************************************************\n')
  cat('par[2] = ',par[2],'\n')
  cat('par[3] = ',par[3],'\n')
  cat('par[4] = ',par[4],'\n')
  cat('par[5] = ',par[5],'\n')
  cat('par[6] = ',par[6],'\n')
  cat('ht = ',ht,'\n')
  if (ht_negative) f = 1e8
  cat('negative log likelihood = ',f,'\n')
  return(f)
}
par=nlminb_init_values
# S = 1e-6
mm=optim(par,
         star,
         method = 'Nelder-Mead',
         hessian = T)
mm$convergence
print('nlminb: ')
nlminb_init_values %>% round(3)
print('Nelder-Mead: ')
mm$par %>% round(3)
param=mm$par
standard_error = sqrt(diag(solve(mm$hessian)))
# print coeftable
names(param)=c('mu','c','a1','a2','sc','sa1')
se.coef = standard_error
tval = param/se.coef
matcoef = cbind(param, se.coef, tval, 2*(1-pnorm(abs(tval))))
dimnames(matcoef) = list(names(tval),
                         c("Estimate","Std. Error","t value","Pr(>|t|)"))
cat("\nCoefficient(s):\n")
printCoefmat(matcoef, digits = 6, signif.stars = TRUE)
# RATS program --------------------------------------------------------------------------------------------------------------
end(reset)
OPEN DATA "C:\Users\Jimmy\Desktop\m-3m4608.txt"
DATA(FORMAT=PRN,NOLABELS,ORG=COLUMNS,TOP=2,LEFT=2) 1 755 RTN
*
nonlin(parm=meanparms) mu
nonlin(parm=garchparms) c a1 a2
nonlin(parm=starparms) sc sa1
linreg(noprint) rtn / u
# constant
set uu = %seesq
set h  = %seesq
compute mu=%beta(1),c=%seesq,a1=a2=.01,sc=0.0,sa1=0.0
*
frml resid = rtn-mu
frml hf    = (c+a1*uu{1}+a2*uu{2})+(sc+sa1*uu{1})/(1+exp(-1000*u{1}))
frml logl  = (u=resid),(uu=u^2),(h=hf),%logdensity(h,u)
maximize(parmset=meanparms+garchparms+starparms) logl 3 *
