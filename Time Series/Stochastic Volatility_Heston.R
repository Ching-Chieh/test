# Heston -----------------------------------------------------------------------
#  dS = mu*S*dt + sqrt(V)*S*dzs
#  dV = a(VL-V)dt + xi*sqrt(V)*dzv   (Variance rate)
cat("\014")
rm(list=ls())
library(yuima)
Sigma <- matrix(c(0.5, 0.8, 0.8, 2), 2) # rho = 0.8
L <- t(chol(Sigma))
L
set.seed(123)
drift <- c("mu*S", "a*(VL-V)")
diffusion <- matrix(c("c11*S*sqrt(V)", "0",
                      "c21*xi*sqrt(V)", "c22*xi*sqrt(V)"),
                    2, byrow = T)
heston <- setModel(drift=drift, diffusion=diffusion, state.var=c("S","V"))
sim1 <- simulate(heston, true.par=list(mu=1.2, a=2, VL=0.5, xi=0.2,
                                       c11=L[1,1], c21=L[2,1], c22=L[2,2]),
                 xinit=c(100,0.5))
plot(sim1)
# Rough volatility model: rough Heston -----------------------------------------------------------------------
#  dS = mu*S*dt + sqrt(V)*S*(rho*dz + sqrt(1-rho^2)*dw)
#  dV = a(VL-V)dt + xi*sqrt(V)*dz   (Variance rate)
#  dz and dw are uncorrelated
cat("\014")
rm(list=ls())
library(yuima)
set.seed(123)
drift <- c("mu*S", "a*(VL-V)")
diffusion <- matrix(c(sqrt(V)*S*rho, sqrt(V)*S*sqrt(1-rho^2),
                      xi*sqrt(V), 0),
                    2, byrow = T)
heston <- setModel(drift=drift, diffusion=diffusion, state.var=c("S","V"))
sim1 <- simulate(heston,
                 true.par=list(mu=1.2, a=2, VL=0.5, xi=0.2, rho=-0.1),
                 xinit=c(100,0.5))
