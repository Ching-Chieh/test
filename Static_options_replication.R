# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.638
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
