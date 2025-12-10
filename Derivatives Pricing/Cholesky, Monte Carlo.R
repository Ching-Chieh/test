# Generate a 3-dim multivariate normal random sample
# method 1
cat("\014")
rm(list=ls())
set.seed(1)
c12 <- 0.3   # set correlation
c23 <- 0.4   # set correlation
c13 <- 0.5   # set correlation
c12^2+c23^2+c13^2-2*c12*c23*c13
v1 <- c(c12,c23,c13)
m1 <- matrix(c(1,0,0,
               c12, sqrt(1-c12^2), 0,
               c13, (c23-c12*c13)/sqrt(1-c12^2),
               sqrt(-sum(v1^2)+1+2*prod(v1))/sqrt(1-c12^2)),
             3, 3, byrow = T)
v2 <- as.matrix(c(rnorm(3)),3)
m1%*%v2
# method 2
N <- 3
vv1 <- c(c12,c13,c23)
m2 <- diag(x = 1, nrow=N)
m2[upper.tri(m2)] <- vv1
m2[lower.tri(m2)] <- vv1
t(chol(m2))%*%v2
# Simulate GBM stock price -------------------------------------------------------------------------
cat("\014")
rm(list=ls())
S0 = 20
M = 15    # path
N = 50    # step
T = 2
mu = 0.1
sig = 0.2
r=0.5
dt = T/N
S <- (r-0.5*sig*sig)*dt+sig*matrix(rnorm(M*N),M,N)*sqrt(dt)
S <- S0*exp(t(apply(S,1,cumsum)))
# plot method 1
matplot(t(S), type = "l")
# plot method 2
library(reshape2)
df <- as_tibble(t(S)) |> mutate(t=c(1:50)*2/50) |> select(t,everything())
df |> 
  reshape2::melt(id.vars = 't') |> 
  ggplot(aes(t, value, col=variable)) + 
  geom_line() +
  theme(legend.position='none')
# Calculate call price using Monte Carlo simulation ----------------------------------------------------------
cat("\014")
rm(list=ls())
M <- 10000
N <- 100
S0 <- 42
K=40
r=0.1
T=0.5
sig=0.2
dt=T/N
cc1 <- c()
for(i in 1:20){
  S <- (r-0.5*sig*sig)*dt+sig*matrix(rnorm(M*N),M,N)*sqrt(dt)
  S <- S0*exp(t(apply(S,1,cumsum)))
  c1 <- mean(purrr::map_dbl(S[,N]-K, max, 0))*exp(-r*T)
  # c1 <- mean(sapply((S[,N]-K), function(x) max(x,0)))*exp(-r*T)
  cc1 <- c(cc1,c1)
}
round(cc1,3)
# 2 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
set.seed(0)
M=100 # time intervals
I=50000 # paths

S0 = 36.
T = 1.
r = 0.06
sigma = 0.2
dt = T / M

rn=matrix(rnorm((M+1)*I), M+1)
rn[1,] = 0
N = matrix(0:M, M+1, I)
S=exp(log(S0) + (r-0.5*sigma^2) * N * dt + sigma * sqrt(dt) * apply(rn, 2, cumsum))
K=40
exp(-r*T)*mean(pmax(K-S[M+1,], 0))
# BS
q=0
d1 = (log(S0/K) + (r-q+0.5*sigma^2)*T)/(sigma*sqrt(T))
d2 = d1 - sigma*sqrt(T)
K*exp(-r*T)*pnorm(-d2) - S0*exp(-q*T)*pnorm(-d1)
