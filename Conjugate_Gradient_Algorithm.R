# Conjugate Gradient Algorithm ------------------------------------------------
cat("\014")
rm(list=ls())


Q <- matrix(c(
  3,0,1,
  0,4,2,
  1,2,3), 3, byrow=TRUE)

isSymmetric(Q)
eigen(Q)$values
b <- c(3,0,1)
x0 <- c(0, 0, 0)

cg <- function(Q, b, x0, max_iter = 1000) {
  x <- x0
  g <- Q %*% x - b
  d <- -g
  for (k in 1:max_iter) {
    dQd <- t(d) %*% Q %*% d
    alpha <- as.numeric(   -t(g)%*%d / dQd  )  # alpha_k
    x <- x + alpha*d                           # x_k+1
    g_new <- Q %*% x - b                       # g_k+1
    if (sqrt(sum(g^2)) < 1e-6) {
      return(list(x = as.vector(x), iter = k))
    }
    # beta <- c(   t(g_new)%*%Q%*%d / dQd   )  # beta_k
    beta <- as.numeric(   t(g_new)%*%g_new / t(g)%*%g   )   # beta_k
    d <- -g_new + beta*d                       # d_k+1
    g <- g_new
  }
  warnings("Not converged.")
  return(list(x = as.vector(x), iter = max_iter))
}
res_1=cg(Q, b, x0)
res_1$x
round(res_1$x, 4)
res_1$iter

f <- function(x) as.numeric(0.5 * t(x) %*% Q %*% x - x %*% b)
g <- function(x) as.vector(Q %*% x - b)
res_2=optim(x0, f, g, method = "CG")
res_2$par
round(res_2$par, 4)
res_2$convergence

solve(Q, b)
library(quadprog)
s=solve.QP(Dmat=Q, dvec=b, Amat=diag(3), bvec=rep(-1e6, 3))
round(s$unconstrained.solution, 2)

