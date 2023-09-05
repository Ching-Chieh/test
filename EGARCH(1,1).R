cat("\014")
rm(list=ls())
# Ruey S. Tsay. An Introduction to Analysis of Financial Data with R. p.218
# Ruey S. Tsay. Analysis of Financial Time Series, 3th, p.144. Alternative Model Form 
rtn=log(read.table("m-ibmsp6709.txt",header=T)$ibm+1)
loglik <- function(par) {
  glk=0
  N=length(rtn)
  h=var(rtn[1:40]) # h1
  a=rtn[1]-par[1]  # a1
  for (t in as.integer(2:N)){
    a_t=rtn[t]-par[1]
    a=c(a,a_t)
    ep_t_1=a[t-1L]/sqrt(h[t-1L])  # ep(t-1)
    lnh_t=par[2]+par[3]*(abs(ep_t_1)+par[4]*ep_t_1)+par[5]*log(h[t-1L])
    h_t=exp(lnh_t)
    h=c(h,h_t)
    glk=glk + (lnh_t + a_t^2/h_t)
  }
  h_series <<- h
  a_series <<- a
  return(glk)
}
mu=mean(rtn)
init_value=c(mu,0.1,0.1,0.1,0.7)
low=c(-10, -5,0,-1,0)
upp=c( 10,  5,1, 0,1)
mm=optim(init_value,loglik,method="L-BFGS-B",hessian=T,lower=low,upper=upp)
round(mm$par,4)
h_series %>% head(20) %>% round(3)
a_series %>% head(20) %>% round(3)
