# Ruey S. Tsay. Analysis of Financial Time Series, 3th, p.144. Alternative Model Form
cat("\014")
rm(list=ls())
a0= -0.5975; a=0.213; gam= -0.4355; b=0.9196
N=1000L
e=rnorm(N)
h=vector(mode = 'double',length = N)
u=vector(mode = 'double',length = N)
h[1]=0.005
u[1]=sqrt(h[1])*e[1]
for (t in 2L:N) {
  ln_h = a0 + a*(abs(e[t-1L]) - gam*e[t-1L]) + b*log(h[t-1L])
  h[t] = exp(ln_h)
  u[t] = sqrt(h[t])*e[t]
}
h |> head(10)
u |> head(10)
par(mfrow=c(2,1))
plot(1L:N,u,type = 'l',xlab = 'T')
plot(1L:N,h,type = 'l',xlab = 'T')
