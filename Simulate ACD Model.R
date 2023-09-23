# Simulate Autoregressive Conditional Duration Model
# Engle and Russell (1998). Autoregressive conditional duration: A new model for irregularly spaced transaction data. Econometrica
# Notations follow Ruey S. Tsay, Analysis of Financial Time Series, 3th, p.255
#   WACD(1,1): standardized weibull
#   EACD(1,1): standard exponential
#   GACD(1,1): standardized generalized gamma
# Simulate WACD(1,1) -----------------------------------------------------------------------
# Epsilon follows standardized weibull distribution.
cat("\014")
rm(list=ls())
w0=0.3; gam=0.2; w1=0.7
alpha=1.5
beta=1/gamma(1+1/alpha)
N=500L
# shape a alpha
# scale sigma beta
epsi=rweibull(N, shape=alpha, scale=beta) # Mean=1
Meanx=Meanpsi=w0/(1-(gam+w1))
psi=vector(mode = 'double',length = N)
x=vector(mode = 'double',length = N)
psi[1]=Meanpsi
x[1]=Meanx
for (t in 2L:N) {
  psi[t] = w0 + gam*x[t-1L] + w1*psi[t-1L]
  x[t] = psi[t]*epsi[t]
}
df=data.frame(t=1:500,x.weibull=x)
# Simulate EACD(1,1) -----------------------------------------------------------------------
# Epsilon follows standard exponential distribution.
cat("\014")
rm(list=base::setdiff(ls(),'df'))
w0=0.3; gam=0.2; w1=0.7
N=500L
# have time-invariant unconditional variance?
(2*gam^2 + w1^2 + 2*gam*w1) < 1
epsi=rexp(N)
Meanx=Meanpsi=w0/(1-(gam+w1))
psi=vector(mode = 'double',length = N)
x=vector(mode = 'double',length = N)
psi[1]=Meanpsi
x[1]=Meanx
for (t in 2L:N) {
  psi[t] = w0 + gam*x[t-1L] + w1*psi[t-1L]
  x[t] = psi[t]*epsi[t]
}
df$x.exp=x
# Simulate GACD(1,1) -----------------------------------------------------------------------
# Epsilon follows standardized generalized gamma distribution.
cat("\014")
rm(list=base::setdiff(ls(),'df'))
w0=0.3; gam=0.2; w1=0.7
N=500L
k=1.5; alpha=0.5
beta=1/gamma(k+1/alpha)*gamma(k)
qggamma <- function(p, theta, kappa, delta){
  out <- qgamma(p, shape = kappa/delta, scale = theta^delta)^(1/delta)
  return(out)
}
epsi=qggamma(runif(N), theta=beta, kappa=k*alpha, delta=alpha)
Meanx=Meanpsi=w0/(1-(gam+w1))
psi=vector(mode = 'double',length = N)
x=vector(mode = 'double',length = N)
psi[1]=Meanpsi
x[1]=Meanx
for (t in 2L:N) {
  psi[t] = w0 + gam*x[t-1L] + w1*psi[t-1L]
  x[t] = psi[t]*epsi[t]
}
df$x.ggamma=x
# plot --------------------------------------------------------------------
head(df)
library(tidyverse)
df <- df %>% 
  as_tibble() %>% 
  rename_with(~sub("x.", "", .x)) %>%
  rename(Weibull = weibull,
         Exponential = exp,
         `Generalized Gamma`= ggamma) %>% 
  pivot_longer(-t,
               names_to = "distribution",
               values_to = "x")
library(ggh4x)
mycolor = c("red","aquamarine","orange")
ggplot(df, aes(t,x,color=distribution)) +
  geom_line() +
  scale_colour_manual(values = mycolor) +
  ggh4x::facet_wrap2(vars(distribution),3,scales = 'free',
                     strip = 
                       ggh4x::strip_themed(background_x = 
                       elem_list_rect(fill=mycolor))) +
  theme(legend.position = "none") +
  labs(y = 'Duration')
