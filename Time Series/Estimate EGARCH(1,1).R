# Estimate EGARCH(1,1) without using packages.
# Ruey S. Tsay. Analysis of Financial Time Series, 3th, p.145. Example 3.8.3
# Estimate ----------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
da=read.table('m-ibmvwew2697.txt',header = T, na.strings = '.') %>% 
  as_tibble() %>% 
  mutate(date=ymd(date)) %>% 
  filter(!is.na(ibm))
rtn=da$ibm
loglik <- function(para) {
  glk=0
  N=length(rtn)
  h=c(NA,var(rtn[1:40]))
  a=c(NA,rtn[2]-para[1]-para[2]*rtn[1])
  for (t in as.integer(3:N)){
    a_t=rtn[t]-para[1]-para[2]*rtn[t-1L]
    a=c(a,a_t)
    ep_t_1=a[t-1L]/sqrt(h[t-1L])
    theta <- para[3]
    gam <- para[4]
    g_t_1 = theta*ep_t_1 + gam*(abs(ep_t_1) - sqrt(2/pi))
    alpha <- para[5]
    alpha0 <- para[6]
    lnh_t = (1-alpha)*alpha0 + g_t_1 + alpha*log(h[t-1L])
    h_t = exp((1-alpha)*alpha0 + g_t_1)*h[t-1L]^alpha
    h=c(h,h_t)
    glk = glk + 0.5*(lnh_t + a_t^2/h_t)
  }
  h_series <<- h
  a_series <<- a
  cat('const= ' ,para[1],"\n")
  cat('ar1= '   ,para[2],"\n")
  cat('theta= ' ,para[3],"\n")
  cat('gamma= ' ,para[4],"\n")
  cat('alpha= ' ,para[5],"\n")
  cat('alpha0= ',para[6],"\n")
  print('*************************************')
  return(glk)
}
init_value=c(mean(rtn)*(1-0.1), 0.1, -0.1, 0.1, 0.1, 0.1)
S=1e-4
low=c(-1, -1, -1, S, S, -10)
upp=c( 1,  1, -S, 1, 1,  10)
mm=optim(init_value,loglik,method="L-BFGS-B",hessian=T,lower=low,upper=upp)
pp=mm$par
names(pp) <- c('const','ar1','theta','gamma','alpha','alpha0')
round(pp,4)
# Forecast out-of-sample volatility ----------------------------------------------------------------
alpha0 <- pp[['alpha0']]
alpha1 <- pp[['alpha']]
theta <- pp[['theta']]
gam <- pp[['gamma']]
sigma_h_sq <- tail(h_series,1)
epsi_h <- tail(a_series,1)/sqrt(sigma_h_sq)
g <- function(epsi) theta*epsi + gam*(abs(epsi) - sqrt(2/pi))
# forecast sigma^2(h+1); h is forecast origin
sigma_h_1_sq <- sigma_h_sq^alpha1*exp((1-alpha1)*alpha0)*exp(g(epsi_h))
# forecast sigma^2(h+2)
w = (1-alpha1)*alpha0 - gam*sqrt(2/pi)
sigma_h_2_sq <- sigma_h_1_sq^alpha1*exp(w)*(
  exp((theta+gam)^2/2)*pnorm(theta+gam) + exp((theta-gam)^2/2)*pnorm(gam-theta)
  )
cat('last volatility estimated from data',sqrt(sigma_h_sq),'\n')
cat('one-step ahead forecast volatility',sqrt(sigma_h_1_sq),'\n')
cat('two-step ahead forecast volatility',sqrt(sigma_h_2_sq),'\n')
# Use RATS ------------------------------------------------------------------------------------------------------------
end(reset)
OPEN DATA "C:\Users\Jimmy\Desktop\ibm2697.csv"
DATA(FORMAT=PRN,NOLABELS,ORG=COLUMNS,TOP=2,LEFT=2,RIGHT=2) 1 862 IBM
nonlin c ar1 a0 a1 theta gam
linreg(noprint) ibm / u
# constant ibm{1}
set logh = log(%seesq)
*
compute c=%beta(1), ar1=%beta(2), a0= -5.0, a1= -0.9, theta= -0.1, gam=0.2
frml at    = ibm-c-ar1*ibm{1}
frml e     = at/sqrt(exp(logh))
frml g     = theta*(e) + gam*(abs(e)-sqrt(2./%pi))
frml loghf = (1-a1)*a0 + g{1} + a1*logh{1}
frml logl  = u=at,logh=loghf,-0.5*logh-0.5*e^2
maximize(method=bhhh) logl 3 *
set h = exp(logh)
