# Heston -----------------------------------------------------------------------
# dS = mu*dt + sqrt(V)*dzs
# dV = a(VL-V)dt + xi*sqrt(V)*dzv
cat("\014")
rm(list=ls())
library(yuima)
Sigma <- matrix(c(0.5, 0.8, 0.8, 2), 2) # rho = 0.8
L <- t(chol(Sigma))
L
set.seed(123)
drift <- c("mu*S", "a*(VL-V)")
diffusion <- matrix(c("c11*sqrt(V)*S", "0",
                      "c21*sqrt(V)*xi", "c22*sqrt(V)*xi"),
                    2, byrow = T)
heston <- setModel(drift=drift, diffusion=diffusion, state.var=c("S","V"))
sim1 <- simulate(heston, true.par=list(mu=1.2, a=2, VL=0.5, xi=0.2,
                                       c11=L[1,1], c21=L[2,1], c22=L[2,2]),
                 xinit=c(100,0.5))
plot(sim1)
