# Asian Options
# geometric average of stock prices ---------------------------------------
cat("\014")
rm(list=ls())
S0=K=50
r=0.1
q=0
sigma=0.4
tau=1
#
a = 0.5*(r-q-sigma^2/6)
sigma_G = sigma/sqrt(3)
d1 = (log(S0/K)+(a+0.5*sigma_G^2)*tau)/(sigma_G*sqrt(tau))
d2 = d1-sigma_G*sqrt(tau)
call_price = exp(-r*tau)*(S0*exp(a*tau)*pnorm(d1) - K*pnorm(d2))
call_price
# arithmetic average of stock prices --------------------------------------
cat("\014")
rm(list=ls())
S0=K=50
r=0.1
q=0
sigma=0.4
tau=1
# average is calculated continuously
M1=(exp((r-q)*tau)-1)/((r-q)*tau)*S0
M2=(2*exp((2*(r-q)+sigma^2)*tau)*S0^2)/((r-q+sigma^2)*(2*r-2*q+sigma^2)*tau^2)+
  2*S0^2/((r-q)*tau^2)*(1/(2*(r-q)+sigma^2)-exp((r-q)*tau)/(r-q+sigma^2))
F0=M1
sigma=sqrt(1/tau*log(M2/M1^2))
d1=(log(F0/K)+sigma^2*tau/2)/(sigma*sqrt(tau))
d2=d1-sigma*sqrt(tau)
call_price=exp(-r*tau)*(F0*pnorm(d1)-K*pnorm(d2))
put_price=exp(-r*tau)*(K*pnorm(-d2)-F0*pnorm(-d1))
round(F0,2)
cat(100*round(sigma,4),'%\n',sep = '')
round(call_price,2)
