# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.638
# up-and-out call
# Table 26.1 ----------------------------------------------------------------------
cat("\014")
rm(list=ls())
BS <- function(type,S0,K,T1,t,sig,r) {
  d1 = (log(S0/K) + (r+0.5*sig^2)*(T1-t))/(sig*sqrt(T1-t))
  d2 = d1 - sig*sqrt(T1-t)
  if (type =='c') return(S0*pnorm(d1) - K*exp(-r*(T1-t))*pnorm(d2))
  else return(K*exp(-r*(T1-t))*pnorm(-d2) - S0*pnorm(-d1))
}
r = 0.1
sig = 0.3
S0 = 50
S = 60
TT = 0.75
steps = 3
dt = TT/steps
t = seq(TT-dt, 0, -dt)
K = c(50,60,60,60)
T1 = c(0.75,0.75,0.5,0.25)
p = c(1,0,0,0)
for (i in seq_along(t)) {
  port_value = 0
  for (j in 1:i) port_value = port_value + BS('c',S,K[j],T1[j],t[i],sig,r)*p[j]
  p[i+1] = -port_value/BS('c',S,K[i+1],T1[i+1],t[i],sig,r)
}
round(p,2)
round(BS('c',S0,K,T1,0,sig,r)*p,2)
# analytic formula ---------------------------------------------------------
cat("\014")
rm(list=ls())
BS <- function(type, S0, K, T1, t, sig, r, q) {
  tau = T1-t
  d1 = (log(S0/K) + (r-q+0.5*sig^2)*tau)/(sig*sqrt(tau))
  d2 = d1 - sig*sqrt(tau)
  if (type =='c')
    return(S0*exp(-q*tau)*pnorm(d1) - K*exp(-r*tau)*pnorm(d2))
  else return(K*exp(-r*tau)*pnorm(-d2) - S0*exp(-q*tau)*pnorm(-d1))
}
barrier_options <- function(H, S0, K, T1, t, sig, r, q) {
  tau = T1 - t
  d1 = (log(S0/K) + (r-q+0.5*sig^2)*tau)/(sig*sqrt(tau))
  d2 = d1 - sig*sqrt(tau)
  call_price = S0*exp(-q*tau)*pnorm(d1) - K*exp(-r*tau)*pnorm(d2)
  put_price = K*exp(-r*tau)*pnorm(-d2) - S0*exp(-q*tau)*pnorm(-d1)
  
  lambda = (r-q+0.5*sig^2)/sig^2
  y = log(H^2/(S0*K))/(sig*sqrt(tau)) + lambda*sig*sqrt(tau)
  x1 = log(S0/H)/(sig*sqrt(tau)) + lambda*sig*sqrt(tau)
  y1 = log(H/S0)/(sig*sqrt(tau)) + lambda*sig*sqrt(tau)
  if (H <= K) {
    call_di = S0*exp(-q*tau)*(H/S0)^(2*lambda)*pnorm(y) - K*exp(-r*tau)*(H/S0)^(2*lambda-2)*pnorm(y - sig*sqrt(tau))
    call_do = call_price - call_di
  }
  else {
    call_do = S0*pnorm(x1)*exp(-q*tau) - K*exp(-r*tau)*pnorm(x1 - sig*sqrt(tau)) -
      S0*exp(-q*tau)*(H/S0)^(2*lambda)*pnorm(y1) + K*exp(-r*tau)*(H/S0)^(2*lambda-2)*pnorm(y1-sig*sqrt(tau))
    call_di = call_price - call_do
  }
  if (H <= K) {
    call_uo = 0
    call_ui = call_price
  }
  else {
    call_ui = S0*pnorm(x1)*exp(-q*tau) - K*exp(-r*tau)*pnorm(x1 - sig*sqrt(tau)) -
      S0*exp(-q*tau)*(H/S0)^(2*lambda)*(pnorm(-y)-pnorm(-y1)) + 
      K*exp(-r*tau)*(H/S0)^(2*lambda-2)*(pnorm(-y + sig*sqrt(tau)) - pnorm(-y1 + sig*sqrt(tau)))
    call_uo = call_price - call_ui
  }
  if (H >= K) {
    put_ui = -S0*exp(-q*tau)*(H/S0)^(2*lambda)*pnorm(-y) + K*exp(-r*tau)*(H/S0)^(2*lambda-2)*pnorm(-y + sig*sqrt(tau))
    put_uo = put_price - put_ui
  }
  else {
    put_uo = -S0*pnorm(-x1)*exp(-q*tau) + K*exp(-r*tau)*pnorm(-x1 + sig*sqrt(tau)) + 
      S0*exp(-q*tau)*(H/S0)^(2*lambda)*pnorm(-y1) - K*exp(-r*tau)*(H/S0)^(2*lambda-2)*pnorm(-y1 + sig*sqrt(tau))
    put_ui = put_price - put_uo
  }
  if (H >= K) {
    put_do = 0
    put_di = put_price - put_do
  }
  else {
    put_di = -S0*pnorm(-x1)*exp(-q*tau) + K*exp(-r*tau)*pnorm(-x1 + sig*sqrt(tau)) + 
      S0*exp(-q*tau)*(H/S0)^(2*lambda)*(pnorm(y) - pnorm(y1)) - 
      K*exp(-r*tau)*(H/S0)^(2*lambda-2)*(pnorm(y - sig*sqrt(tau)) - pnorm(y1 - sig*sqrt(tau)))
    put_do = put_price - put_di
  }
  return(list(
    call_ui = call_ui,
    call_uo = call_uo,
    call_di = call_di,
    call_do = call_do,
    put_ui = put_ui,
    put_uo = put_uo,
    put_di = put_di,
    put_do = put_do))
}
round(barrier_options(60,50,50,0.75,0,0.3,0.1,0)[['call_uo']],2)
# steps = 3, 18, 100 -----------------------------------------------------------------
# cat("\014")
# rm(list=ls())
call_uo_replication <- function(steps) {
  BS <- function(type,S0,K,T1,t,sig,r) {
    d1 = (log(S0/K) + (r+0.5*sig^2)*(T1-t))/(sig*sqrt(T1-t))
    d2 = d1 - sig*sqrt(T1-t)
    if (type =='c') return(S0*pnorm(d1) - K*exp(-r*(T1-t))*pnorm(d2))
    else return(K*exp(-r*(T1-t))*pnorm(-d2) - S0*pnorm(-d1))
  }
  r = 0.1
  sig = 0.3
  S0 = 50
  S = 60
  TT = 0.75
  dt = TT/steps
  t = seq(TT-dt, 0, -dt)
  K = c(50, rep(60,steps))
  T1 = c(TT, seq(TT, dt, -dt)) # options' maturities
  p = c(1,rep(0,steps))        # options' positions
  for (i in seq_along(t)) {
    port_value = 0
    for (j in 1:i) port_value = port_value + BS('c',S,K[j],T1[j],t[i],sig,r)*p[j]
    p[i+1] = -port_value/BS('c',S,K[i+1],T1[i+1],t[i],sig,r)
  }
  sum(BS('c',S0,K,T1,0,sig,r)*p)
}
round(sapply(c(3,18,100), call_uo_replication),2)
