# Simulate Vasicek -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(yuima)
set.seed(123)
true_parms = list(a=0.21,b=0.04,sigma=0.0072)
vasicek <- setModel(drift="a*(b-r)",diffusion="sigma",solve.variable='r')
sim1 <- simulate(vasicek,
                 sampling = setSampling(n=520, delta = 1/52),
                 true.parameter = true_parms)
r=as.numeric(get.zoo.data(sim1)[[1]]) # r=as.numeric(sim1@data@zoo.data[[1]])
# Estimate real-world parameters -----------------------------------------------------
# Method 1: Regression
m1=lm(diff(r)~r[-length(r)])
(a <- 52*(-coef(m1)[[2]]))
(b <- 52*coef(m1)[[1]]/a)
(sigma <- sqrt(52)*sqrt(vcov(m1)[2,2]))
rm(list = c('a','b','sigma'))
# Method 2: MLE
logl <- function(parm){
  a=parm[1]; b=parm[2]; sigma=parm[3]
  dt=1/52
  ll=sum(-log(sigma^2*dt)-(diff(r)-a*(b-r[-length(r)])*dt)^2/(sigma^2*dt))
  -ll
}
init_values=c(a=0.2,b=0.04,sigma=0.008)
S=1e-6
mm=optim(init_values,logl,method = 'L-BFGS-B',lower = c(S,S,S))
mm$convergence # 0 is successful
round(mm$par,3)
# Short rate distribution -------------------------------------------------
cat("\014")
rm(list=ls())
library(yuima)
true_parms = list(a=0.21,b=0.04,sigma=0.0072)
vasicek <- setModel(drift="a*(b-r)",
                    diffusion="sigma",
                    solve.variable='r')
# Short rate should be normally distributed.
# mean = exp(-a*t)*r(0) + b*(1-exp(-a*t))
# variance = sigma^2/(2*a)*(1-exp(-2*a*t))
# pick t = 0 + 1/52*10
a=true_parms[['a']]
b=true_parms[['b']]
sigma=true_parms[['sigma']]
target=10L
t=0+target/52
r0=0
Mean=exp(-a*t)*r0 + b*(1-exp(-a*t))
Var=sigma^2/(2*a)*(1-exp(-2*a*t))
r=NULL
for (i in 1:500) {
  sim1 <- simulate(vasicek,
                   sampling = setSampling(n=520, delta = 1/52),
                   true.parameter = true_parms)
  r=c(r,as.numeric(get.zoo.data(sim1)[[1]])[target])
}
library(ggplot2)
ggplot(data.frame(r=r), aes(r)) +
  geom_density() +
  geom_function(aes(colour = "normal"), fun = dnorm,
                args = list(mean=Mean,sd=sqrt(Var))) +
  labs(x = "short rate", y = "") +
  theme(legend.position = "none")
