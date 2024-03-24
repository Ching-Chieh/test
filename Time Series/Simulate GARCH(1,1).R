# simulate GARCH(1,1) -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
a0=0.5; a=0.19; b=0.8
N=1000L
e=rnorm(N)
h=vector(mode = 'double',length = N)
u=vector(mode = 'double',length = N)
h[1]=a0/(1-a-b)         # u's unconditional variance; var(u)=E(u^2)=a0/(1-a-b)
u[1]=sqrt(a0/(1-a-b))   # E(u^2)=a0/(1-a-b); set u^2=a0/(1-a-b); u=sqrt(a0/(1-a-b))
for (t in 2L:N) {
  h[t] = a0 + a*u[t-1L]^2 + b*h[t-1L]
  u[t] = sqrt(h[t])*e[t]
}
h |> head(10)
u |> head(10)
par(mfrow=c(2,1))
plot(1L:N,u,type = 'l',xlab = 'T')
plot(1L:N,h,type = 'l',xlab = 'T')
