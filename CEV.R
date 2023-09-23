# Constant Elasticity of Variance (CEV) Model ------------------------------------
cat("\014")
rm(list=ls())
library(yuima)
# dS= (r-q)Sdt + sigma * S^alpha *dz
T1=5
q=0
S0=50
K=50
true_parms = list(r=0.05,sigma=0.01,alpha=0.5)
CEV <- setModel(drift="r*S",diffusion="sigma*S^alpha",solve.variable='S')
S=NULL
for (i in 1:500) {
  sim1 <- simulate(CEV,
                   sampling = setSampling(n=T1*252, delta = 1/252),
                   true.parameter = true_parms,
                   xinit = S0)
  S=c(S,tail(as.numeric(get.zoo.data(sim1)[[1]]),1))
}
max(mean(S-K),0) # call
# max(mean(K-S),0) # put
# closed form solution -------------
r=true_parms[['r']]
alpha=true_parms[['alpha']]
sigma=true_parms[['sigma']]
v=sigma^2/(2*(r-q)*(alpha-1))*(exp(2*(r-q)*(alpha-1)*T1)-1)
a=(K*exp(-(r-q)*T1))^(2*(1-alpha))/((1-alpha)^2*v)
b=1/(1-alpha)
c=S0^(2*(1-alpha))/((1-alpha)^2*v)
call_price=S0*exp(-q*T1)*(1-pchisq(a,b+2,c)) - K*exp(-r*T1)*pchisq(c,b,a)
# put_price=K*exp(-r*T1)*(1-pchisq(c,b,a)) - S0*exp(-q*T1)*pchisq(a,b+2,c)
call_price
# put_price
