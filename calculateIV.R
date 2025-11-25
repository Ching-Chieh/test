# IV -----------------------------------------------------------------------
cat("\014")
rm(list=ls())

S = 42
K = 40
T = 0.5
# sigma = 0.2
r = 0.1
price = 4.759422
type = 'c'
BS <- function(type, S, K, T, sigma, r) {
  d1 = (log(S/K) + (r+0.5*sigma^2)*T)/(sigma*sqrt(T))
  d2 = d1 - sigma*sqrt(T)
  if (type == 'c')
    return(S*pnorm(d1) - K*exp(-r*T)*pnorm(d2))
  else if (type == 'p')
    return(K*exp(-r*T)*pnorm(-d2) - S0*pnorm(-d1))
  else return(-1)
}

# calulate_IV <- function(price, type, S, K, T, r) {
#   f1 <- function(sigma) price - BS(type, S, K, T, sigma, r)
#   uniroot(f1, interval = c(0.0001,0.9999))$root
# }

newton_solver <- function(f, x0, tol = 1e-8, max_iter = 100) {
  f_prime <- function(x, h = 1e-6) {
    (f(x + h) - f(x - h)) / (2 * h)
  }
  
  x <- x0
  for (i in 1:max_iter) {
    fx <- f(x)
    fpx <- f_prime(x)
    
    if (fpx == 0) {
      stop("Derivative is zero, cannot proceed")
    }
    
    x_new <- x - fx / fpx
    
    if (abs(x_new - x) < tol) {
      # cat("Converged at iteration", i, "\n")
      return(x_new)
    }
    
    x <- x_new
  }
  
  warning("Exceeded maximum number of iterations, did not converge")
  return(x)
}
calulate_IV <- function(sigma0, price, type, S, K, T, r) {
  f1 <- function(sigma) price - BS(type, S, K, T, sigma, r)
  newton_solver(f1, sigma0)
}

calulate_IV(0.1, price, type, S, K, T, r)
# newton --------------------------------------------------------------------
cat("\014")
rm(list=ls())
newton_solver <- function(expr, x0, tol = 1e-8, max_iter = 100) {
  f <- function(x) eval(expr)
  
  dexpr <- D(expr, "x")
  f_prime <- function(x) eval(dexpr)
  
  x <- x0
  for (i in 1:max_iter) {
    fx <- f(x)
    fpx <- f_prime(x)
    
    if (fpx == 0) {
      stop("Derivative is zero, cannot proceed")
    }
    
    x_new <- x - fx / fpx
    
    if (abs(x_new - x) < tol) {
      cat("Converged at iteration", i, "\n")
      return(x_new)
    }
    
    x <- x_new
  }
  
  warning("Exceeded maximum number of iterations, did not converge")
  return(x)
}
expr <- expression(x^3 - x - 2)
root <- newton_solver(expr, x0 = 1.5)
root

# newton numeric derivative --------------------------------------------
cat("\014")
rm(list=ls())
newton_solver <- function(expr, x0, tol = 1e-8, max_iter = 100) {
  f <- function(x) eval(expr)
  
  f_prime <- function(x, h = 1e-6) {
    (f(x + h) - f(x - h)) / (2 * h)
  }
  
  x <- x0
  for (i in 1:max_iter) {
    fx <- f(x)
    fpx <- f_prime(x)
    
    if (fpx == 0) {
      stop("Derivative is zero, cannot proceed")
    }
    
    x_new <- x - fx / fpx
    
    if (abs(x_new - x) < tol) {
      cat("Converged at iteration", i, "\n")
      return(x_new)
    }
    
    x <- x_new
  }
  
  warning("Exceeded maximum number of iterations, did not converge")
  return(x)
}
expr <- expression(x^3 - x - 2)
root <- newton_solver(expr, x0 = 1.5)
root
