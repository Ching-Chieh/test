# Constant Conditional Correlation GARCH(1,1) -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
da = unname(as.matrix(read.table('d-spcscointc.txt', header = TRUE)))
T = nrow(da)  # number of timepoints
N = ncol(da)  # dimension of vector, number of assets

start_time <- proc.time()

nlogl <- function(params) {
  cat('...', cnt, '...........\n')
  u = da - matrix(1,T,1)%*%matrix(params[1:N],1,N)
  # vcv = matrix(params[(N+1):(2*N)],N,1)
  # vav = matrix(params[(2*N+1):(3*N)],N,1)
  # vbv = matrix(params[(3*N+1):(4*N)],N,1)
  
  vcv = params[(N+1):(2*N)]
  vav = params[(2*N+1):(3*N)]
  vbv = params[(3*N+1):(4*N)]
  
  qc = diag(params[(4*N+1):(5*N-1)]) # correlation matrix
  qc[lower.tri(qc)] = params[(5*N):(5*N+(N-1)*(N-2)/2-1)]
  for (t in 2:T) {
    # fill matrix h's diagonal
    for (i in 1:N) {
      # h[i,i,t] = vcv[i,1] + vav[i,1]*tcrossprod(u[t-1,])[i,i] + vbv[i,1]*h[i,i,t-1]
      h[i,i,t] = vcv[i] + vav[i]*tcrossprod(u[t-1,])[i,i] + vbv[i]*h[i,i,t-1]
    }
    # fill matrix h's entries below diagonal
    for (i in 2:N) {
      for (j in 1:(i-1)) {
        h[i,j,t] = qc[i-1,j]*sqrt(h[i,i,t]*h[j,j,t])
      }
    }
    # fill matrix h's entries above diagonal 
    
    # method 1  
    # tmp = h[,,t]
    # tmp[lower.tri(tmp)] = t(tmp)[lower.tri(tmp)]  # tmp[upper.tri(tmp)] = tmp[lower.tri(tmp)]  # This is wrong.
    # h[,,t] = tmp
    
    # method 2
    for (ii in 1:(N-1)) {
      for (jj in (ii+1):N) {
        h[ii,jj,t] = h[jj,ii,t]
      }
    }
  }
  llv = sapply(1:T, \(t) c(t(u[t,])%*%solve(h[,,t])%*%u[t,]))
  # llv = sum(-N/2*log(2*pi) - 0.5*(log(sapply(seq(dim(h)[3]), \(t) det(h[,,t]))) + llv))
  llv = sum(-0.5*(log(sapply(seq(dim(h)[3]), \(t) det(h[,,t]))) + llv))
  # llv = sum(-(log(sapply(seq(dim(h)[3]), \(t) det(h[,,t]))) + llv))
  cnt <<- cnt + 1
  return(-llv)
}
# set initial values
# da - matrix(1,T,1)%*%matrix(apply(da,2,mean),1,N)
# scale(da, scale = FALSE)
h = array(0, c(N,N,T))
h[,,1] = cov(da)
start_values = c(
  apply(da,2,mean),  # mean
  diag(cov(da)),     # vcv
  rep(0.05, N),      # vav
  rep(0.8, N),       # vbv
  rep(0,(N-1)*N/2)   # correlations  (2,1) (3,2) (3,1)
  )
cnt = 1
S = 1e-6
mm = nlminb(start_values, nlogl,
            lower = c(
              -20*abs(apply(da,2,mean)),  # mean
              rep(S,N),                   # vcv
              rep(S,N),                   # vav
              rep(S,N),                   # vbv
              rep(-1+S,(N-1)*N/2)         # correlations  (2,1) (3,2) (3,1)
            ),
            upper = c(
              20*abs(apply(da,2,mean)),   # mean
              20*diag(cov(da)),           # vcv
              rep(1-S,N),                 # vav
              rep(1-S,N),                 # vbv
              rep(1-S,(N-1)*N/2)          # correlations  (2,1) (3,2) (3,1)
            )
)

proc.time() - start_time
mm$convergence  # 0 stands for successful convergence
mm$message
pars = mm$par
names(pars) = c(
  'mean_1', 'mean_2', 'mean_3',
  'c1', 'c2', 'c3',
  'a1', 'a2', 'a3',
  'b1', 'b2', 'b3',
  'rho(1,2)','rho(2,3)', 'rho(1,3)'
)
pars
# Use SAS' estimates to replicate SAS' log likelihood -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
da=unname(as.matrix(read.table('d-spcscointc.txt', header = TRUE)))
T = nrow(da)
N = ncol(da)
h = array(0, c(N,N,T))
h[,,1] = cov(da)
params = c(
  0.07074, 0.33455, 0.20797, # mean
  0.00818, 0.18336, 0.04149, # vcv
  0.04320, 0.06187, 0.01178, # vav
  0.94428, 0.91661, 0.98135, # vbc
  0.51954, 0.47771, 0.48626
)
u = da - matrix(1,T,1)%*%matrix(params[1:N],1,N)
vcv = matrix(params[(N+1):(2*N)],N,1)
vav = matrix(params[(2*N+1):(3*N)],N,1)
vbv = matrix(params[(3*N+1):(4*N)],N,1)
qc = diag(params[(4*N+1):(5*N-1)]) # correlation matrix
qc[lower.tri(qc)] = params[(5*N):(5*N+(N-1)*(N-2)/2-1)]
for (t in 2:T) {
  # fill matrix h's diagonal
  for (i in 1:N) {
    h[i,i,t] = vcv[i,1] + vav[i,1]*tcrossprod(u[t-1,])[i,i] + vbv[i,1]*h[i,i,t-1]
  }
  # fill matrix h's entries below diagonal
  for (i in 2:N) {
    for (j in 1:(i-1)) {
      h[i,j,t] = qc[i-1,j]*sqrt(h[i,i,t]*h[j,j,t])
    }
  }
  # fill matrix h's entries above diagonal 
  
  # method 1
  # tmp = h[,,t]
  # tmp[upper.tri(tmp)] = tmp[lower.tri(tmp)]
  # h[,,t] = tmp
  
  # method 2
  for (ii in 1:(N-1)) {
    for (jj in (ii+1):N) {
      h[ii,jj,t] = h[jj,ii,t]
    }
  }
}
llv = sapply(1:T, \(t) c(t(u[t,])%*%solve(h[,,t])%*%u[t,]))
# sum(-N/2*log(2*pi) - 0.5*(log(sapply(seq(dim(h)[3]), \(t) det(h[,,t]))) + llv))
# sum(-(log(sapply(seq(dim(h)[3]), \(t) det(h[,,t]))) + llv))
sum(-0.5*(log(sapply(seq(dim(h)[3]), \(t) det(h[,,t]))) + llv))
