# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(maxLik)
head(rtn) # rtn is a matrix of assets returns.
N = nrow(rtn)
sigma0 = crossprod(rtn-matrix(1,N,1)%*%apply(rtn,2,mean))/N
mu1=mean(rtn[,1]); mu2=mean(rtn[,2])
a11= 0.227; a12= 0.044
a21= 0.097; a22= 0.165
b11= 0.909; b12= 0.0005
b21=-0.053; b22= 0.989
parms = c(mu1,mu2,0,0,0,a11,a21,a12,a22,b11,b21,b12,b22) # 13 parameters
A = matrix(parms[6:9],2)
B = matrix(parms[10:13],2)
# Ruey S. Tsay, Multivariate Time Series Analysis: With R, p.417 (7.25)
# Use A and B matrix to determine the initial values of C matrix's parameters.
# Only need to supply the initial values of A and B matrix's parameters.
# At times, it leads to situations where Cholesky decomposition cannot be performed.
C = t(chol(matrix((diag(4)-kronecker(A,A)-kronecker(B,B))%*%c(sigma0),2)))
parms[1]=C[1,1]
parms[2]=C[2,1]
parms[3]=C[2,2]
logl <- function(theta) {
  C = matrix(c(theta[3:4],0,theta[5]),2)
  A = matrix(theta[6:9],2)
  B = matrix(theta[10:13],2)
  H = array(0,c(2,2,N))
  a = rtn-matrix(1,N,1)%*%matrix(theta[1:2],ncol=2)
  H[,,1] = sigma0
  for (i in 2:N) {
    H[,,i] <- tcrossprod(C) + A%*%tcrossprod(a[i-1,])%*%t(A) + B%*%H[,,i-1]%*%t(B)
  }
  llv = numeric(N)
  for (i in 1:N) {
    llv[i] = c(t(a[i,])%*%solve(H[,,i])%*%a[i,])
  }
  llv = -0.5*(2*log(2*pi) + log(sapply(seq(dim(H)[3]), \(x) det(H[,,x]))) + llv)
  llv
}
mm=maxLik(logLik = logl, start = parms, method = "BHHH")
summary(mm)
