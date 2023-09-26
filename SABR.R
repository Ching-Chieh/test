# Black's Model for valuing European futures options
d1 = (log(F0/K) + sigma^2*tau/2)/(sigma*sqrt(tau))
d2 = d1 - sigma*sqrt(tau)
call_price = exp(-r*tau)*(F0*pnorm(d1)-K*pnorm(d2))
put_price = exp(-r*tau)*(K*pnorm(-d2)-F0*pnorm(-d1))
# SABR's approximate Black-model implied volatility for a European option
# The SABR Model:
#    dF = sigma* F^beta * dz
#    d(sigma) = v*sigma*dw
x = (F0*K)^(0.5*(1-beta))
y = (1-beta)*log(F0/K)
A = sigma0/(x*(1 + y^2/24 + y^4/1920))
B = 1+(((1-beta)^2*sigma0^2)/(24*x^2) + (rho*beta*v*sigma0)/(4*x) + (2-3*rho^2)/24*v^2)*tau
phi = v*x/sigma0*log(F0/K)
X = log((sqrt(1-2*rho*phi+phi^2)+phi-rho)/(1-rho))
impvol = A*B*phi/X
