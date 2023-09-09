# Smooth Transition AR (STAR) Model
# Ruey S. Tsay, Analysis of Financial Time Series, 3th, p.185
# nlminb (Same with the text) -----------------------------------------------------------------------
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
# optim L-BFGS-B (different from the text) ------------------------------------------------------------
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
# Nelder-Mead with nlminb Start Values (Same with nlminb and can get Hessian matrix) -----------------------------------------------------------------------
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







