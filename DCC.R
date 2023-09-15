# This script estimates the Dynamic Conditional Correlation Model using Engle's two-step procedure.
# 1. Use R to manipulat data and use RATS to estimate.
# 2. All use R
# data -----------------------------------------------------------------------------------------------------------
# data from Cappiello, Engle & Sheppard (2006) Asymmetric Dynamics in the Correlations of Global Equity and Bond Returns
cat("\014")
rm(list=ls())
library(tidyverse)
read_excel("g.xlsx") %>% 
  rename_with(tolower) %>% 
  mutate(across(everything(),~100*log(.x/dplyr::lag(.x)))) %>% 
  slice(-1) %>% 
  write_csv('g1.csv')
# RATS program ----------------------------------------------------------------------------------------------------
end(reset)
OPEN DATA "C:\Users\Jimmy\Desktop\g1.csv"
DATA(FORMAT=PRN,NOLABELS,ORG=COLUMNS,TOP=2) 1 1866 y1 y2 y3 y4 y5
*
compute n=5
dec vect[series] y(n)
do i=1,n
   set y(i) = ([series]i)
end do i
garch(mv=dcc,dcc=correlation) / y
*
dec vect[series] u(n) h(n) eps(n)
do i=1,n
   garch(p=1,q=1,hseries=h(i),resids=u(i),noprint) / y(i)
   set eps(i) = u(i)/sqrt(h(i))
end do i
vcv(noprint,matrix=qbar)
# eps
*
nonlin a b
dec frml[symm] qf
dec series[symm] q ee hh
*
gset q  = qbar
gset ee = qbar
gset hh = qbar
gset ee 2 * = %outerxx(%xt(eps,t))
*
frml qf   = (1-a-b)*qbar + a*ee{1} + b*q{1}
frml logl = (q=qf),hh=%corrtocv(%cvtocorr(q),%xt(h,t)),%logdensity(hh,%xt(u,t))
compute a=0.01, b=0.5
maximize logl 2 *
# R ------------------------------------------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(readxl)
library(mvtnorm)
g <- read_excel("g.xlsx") %>% 
  rename_with(tolower) %>% 
  mutate(across(everything(),~100*log(.x/dplyr::lag(.x)))) %>% 
  slice(-1)
N = nrow(g)
num = ncol(g)
garch11Fit = function(x)
{
  Mean = mean(x); Var = var(x); S = 1e-6
  params = c(mu = Mean, omega = 0.1*Var, alpha = 0.1, beta = 0.8)
  lowerBounds = c(mu = -10*abs(Mean), omega = S^2, alpha = S, beta = S)
  upperBounds = c(mu = 10*abs(Mean), omega = 100*Var, alpha = 1-S, beta = 1-S)
  garchDist = function(z, hh) { dnorm(x = z/hh)/hh }
  garchLLH = function(parm) {
    mu = parm[1]; omega = parm[2]; alpha = parm[3]; beta = parm[4]
    z = (x-mu); Mean = mean(z^2)
    e = omega + alpha * c(Mean, z[-length(x)]^2)
    h = as.numeric(stats::filter(e, beta, "r", init = Mean))
    hh = sqrt(abs(h))
    llh = -sum(log(garchDist(z, hh)))
    llh
  }
  fit = nlminb(start = params, objective = garchLLH,
               lower = lowerBounds, upper = upperBounds)
  mu = fit$par[['mu']]; omega = fit$par[['omega']]; alpha = fit$par[['alpha']]; beta = fit$par[['beta']]
  z = (x-mu); Mean = mean(z^2)
  e = omega + alpha * c(Mean, z[-length(x)]^2)
  h = as.numeric(stats::filter(e, beta, "r", init = Mean))
  eps = z/sqrt(h)
  epsilon = 0.0001*fit$par
  Hessian = matrix(0, ncol = 4, nrow = 4)
  for (i in 1:4) {
    for (j in 1:4) {
      x1 = x2 = x3 = x4 = fit$par
      x1[i] = x1[i] + epsilon[i]; x1[j] = x1[j] + epsilon[j]
      x2[i] = x2[i] + epsilon[i]; x2[j] = x2[j] - epsilon[j]
      x3[i] = x3[i] - epsilon[i]; x3[j] = x3[j] + epsilon[j]
      x4[i] = x4[i] - epsilon[i]; x4[j] = x4[j] - epsilon[j]
      Hessian[i, j] = (garchLLH(x1)-garchLLH(x2)-garchLLH(x3)+garchLLH(x4))/
        (4*epsilon[i]*epsilon[j])
    }
  }
  se.coef = sqrt(diag(solve(Hessian)))
  garchresult = list(par=fit$par,
                     se.coef=se.coef,
                     h=h,
                     at=z,
                     eps=eps)
  garchresult
}
garch=sapply(g,garch11Fit)
eps = matrix(unlist(garch['eps',]),ncol=num)
colnames(eps) = paste0('eps',1:num)
h = matrix(unlist(garch['h',]),ncol=num)
colnames(h) = paste0('h',1:num)
at = matrix(unlist(garch['at',]),ncol=num)
colnames(at) = paste0('at',1:num)
qbar=crossprod(eps)/N
logl <- function(parms){
  a=parms[1]; b=parms[2]
  q = hh = array(qbar,c(num,num,N))
  for (i in 2:N) {
    q[,,i]=(1-a-b)*qbar + a*eps[(i-1),]%o%eps[(i-1),] + b*q[,,(i-1)]
  }
  for (i in 1:N) {
    hh[,,i]= diag(sqrt(h[i,]))%*%cov2cor(q[,,i])%*%diag(sqrt(h[i,]))
  }
  -sum(log(sapply(1:N,\(x) mvtnorm::dmvnorm(at[x,], sigma = hh[,,x]))))
}
init_values=c(0.03,0.95)
S=1e-6
mm=nlminb(init_values,logl,lower = c(S,S),upper = c(1-S,1-S))
coef.dcc=mm$par
names(coef.dcc)=c('dcc.a','dcc.b')
epsilon = 0.0001*mm$par
Hessian = matrix(0, ncol = 2, nrow = 2)
for (i in 1:2) {
  for (j in 1:2) {
    x1 = x2 = x3 = x4 = mm$par
    x1[i] = x1[i] + epsilon[i]; x1[j] = x1[j] + epsilon[j]
    x2[i] = x2[i] + epsilon[i]; x2[j] = x2[j] - epsilon[j]
    x3[i] = x3[i] - epsilon[i]; x3[j] = x3[j] + epsilon[j]
    x4[i] = x4[i] - epsilon[i]; x4[j] = x4[j] - epsilon[j]
    Hessian[i, j] = (logl(x1)-logl(x2)-logl(x3)+logl(x4))/
      (4*epsilon[i]*epsilon[j])
  }
}
se.dcc = sqrt(diag(solve(Hessian)))
coef.names.garch=c('mu','omega','alpha','beta')
for (i in seq_along(coef.names.garch)) {
  assign(coef.names.garch[i], purrr::map_dbl(garch['par',],coef.names.garch[i]))
  assign(coef.names.garch[i],
         stats::setNames(get(coef.names.garch[i]),paste0(coef.names.garch[i],1:num)))
}
se.garch=NULL
for (i in seq_along(coef.names.garch)) {
  se.garch=c(se.garch,purrr::map_dbl(garch['se.coef',],i))
}
std.error=unname(c(se.garch,se.dcc))
data.frame(term=c(paste0(rep(coef.names.garch,each=5),1:5),names(coef.dcc)),
           estimate=unname(c(mu,omega,alpha,beta,coef.dcc)),
           std.error=std.error) %>%
  as_tibble() %>% 
  mutate(
    statistic=estimate/std.error,
    p.value=2*(1-pnorm(abs(statistic))),
    signif = case_when(
      p.value <= 0.01 ~ "  *** ",
      (p.value > 0.01 & p.value <= 0.05) ~ "   ** ",
      (p.value > 0.05 & p.value <= 0.1) ~ "    * ",
      p.value > 0.1 ~ " ")) %>% 
  mutate(across(-c(term,signif), ~num(.x,digits = 4))) %>% 
  print(n=Inf)
